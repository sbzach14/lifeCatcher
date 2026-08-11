import Foundation

private enum RemoteClientError: LocalizedError {
    case serverNotConfigured(String)
    case invalidSerial
    case invalidResponse
    case protocolMismatch
    case server(status: Int, code: String?, message: String?)
    case unexpectedWelcome

    var errorDescription: String? {
        switch self {
        case .serverNotConfigured(let region): return "\(region) IP 尚未配置"
        case .invalidSerial: return "序列号长度必须为 8～128 个字符"
        case .invalidResponse: return "服务器响应无法解析，请检查服务版本"
        case .protocolMismatch: return "客户端与服务器协议版本不一致"
        case .server(_, let code, let message): return RemoteDiagnostics.serverMessage(code: code, fallback: message)
        case .unexpectedWelcome: return "服务器未返回有效的连接确认"
        }
    }
}

private struct RemoteErrorResponse: Decodable {
    let code: String?
    let message: String?
}

@MainActor
final class RemoteBusinessClient: ObservableObject {
    enum State: Equatable {
        case idle
        case connecting
        case connected
        case reconnecting
        case failed(String)
    }

    @Published private(set) var state: State = .idle {
        didSet {
            guard oldValue != state else { return }
            onStateChange?(state)
            announce(state)
        }
    }
    @Published private(set) var sourceOnline = false

    var onMessage: ((RemoteServerMessage) -> Void)?
    var onStateChange: ((State) -> Void)?

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var sessionToken: String?
    private var resumeToken: String?
    private var webSocketTask: URLSessionWebSocketTask?
    private var receiveTask: Task<Void, Never>?
    private var reconnectTask: Task<Void, Never>?
    private var heartbeatTask: Task<Void, Never>?
    private var lastPongAt = Date.distantPast
    private var role: RemoteRole?
    private var region: RemoteRegion?
    private var serial = ""
    private var intentionalDisconnect = false
    private var reconnectAttempt = 0

    func connect(role: RemoteRole, region: RemoteRegion, serial: String) async throws {
        let normalizedSerial = serial.trimmingCharacters(in: .whitespacesAndNewlines)
        guard region.isConfigured else { throw RemoteClientError.serverNotConfigured(region.title) }
        guard (8...128).contains(normalizedSerial.count) else { throw RemoteClientError.invalidSerial }

        self.role = role
        self.region = region
        self.serial = normalizedSerial
        intentionalDisconnect = false
        state = reconnectTask == nil ? .connecting : .reconnecting
        RemoteDiagnostics.record(.info, category: "business", message: "请求连接 \(region.title) \(region.endpointDescription)")

        var request = URLRequest(url: region.apiBaseURL.appendingPathComponent("v1/connect"))
        request.timeoutInterval = 10
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(RemoteConnectRequest(
            region: region,
            role: role,
            serial: normalizedSerial,
            clientInstanceId: RemotePreferences.clientInstanceId,
            resumeToken: resumeToken
        ))

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            RemoteDiagnostics.record(.error, category: "admission", message: RemoteDiagnostics.userMessage(for: error))
            throw error
        }
        guard let http = response as? HTTPURLResponse else { throw RemoteClientError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else {
            let body = try? decoder.decode(RemoteErrorResponse.self, from: data)
            if body?.code == "invalid_resume", resumeToken != nil {
                RemoteDiagnostics.record(.warning, category: "admission", message: "恢复凭证失效，改用序列号重新连接")
                resumeToken = nil
                sessionToken = nil
                return try await connect(role: role, region: region, serial: normalizedSerial)
            }
            throw RemoteClientError.server(status: http.statusCode, code: body?.code, message: body?.message)
        }
        guard let connect = try? decoder.decode(RemoteConnectResponse.self, from: data) else {
            throw RemoteClientError.invalidResponse
        }
        guard connect.protocolVersion == RemoteProtocolVersion.current, connect.region == region.rawValue else {
            throw RemoteClientError.protocolMismatch
        }
        sessionToken = connect.sessionToken
        try await openWebSocket(url: connect.wsUrl, token: connect.sessionToken)
    }

    func disconnect() {
        intentionalDisconnect = true
        reconnectTask?.cancel()
        reconnectTask = nil
        receiveTask?.cancel()
        receiveTask = nil
        heartbeatTask?.cancel()
        heartbeatTask = nil
        Task { try? await send(RemoteGoodbyeMessage()) }
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        sessionToken = nil
        resumeToken = nil
        sourceOnline = false
        reconnectAttempt = 0
        state = .idle
        RemoteDiagnostics.record(.info, category: "business", message: "远程连接已主动断开")
    }

    func markFailed(_ error: Error) {
        let message = RemoteDiagnostics.userMessage(for: error)
        state = .failed(message)
    }

    func maintainConnectionAfterFailure() {
        guard !intentionalDisconnect else { return }
        state = .reconnecting
        scheduleReconnect()
    }

    func reconnectNow(reason: String? = nil) {
        guard !intentionalDisconnect else { return }
        if let reason { RemoteDiagnostics.record(.warning, category: "business", message: reason) }
        state = .reconnecting
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        scheduleReconnect()
    }

    func send<T: Encodable>(_ message: T) async throws {
        guard let webSocketTask, webSocketTask.state == .running else { throw URLError(.notConnectedToInternet) }
        let data = try encoder.encode(message)
        try await webSocketTask.send(.string(String(decoding: data, as: UTF8.self)))
    }

    func requestMediaToken() async throws -> RemoteMediaTokenResponse {
        guard let region, let sessionToken else { throw URLError(.userAuthenticationRequired) }
        var request = URLRequest(url: region.apiBaseURL.appendingPathComponent("v1/media-token"))
        request.timeoutInterval = 10
        request.httpMethod = "POST"
        request.setValue("Bearer \(sessionToken)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw RemoteClientError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else {
            let body = try? decoder.decode(RemoteErrorResponse.self, from: data)
            throw RemoteClientError.server(status: http.statusCode, code: body?.code, message: body?.message)
        }
        guard let token = try? decoder.decode(RemoteMediaTokenResponse.self, from: data) else {
            throw RemoteClientError.invalidResponse
        }
        return token
    }

    private func openWebSocket(url: URL, token: String) async throws {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw RemoteClientError.invalidResponse
        }
        components.queryItems = (components.queryItems ?? []) + [URLQueryItem(name: "token", value: token)]
        guard let authenticatedURL = components.url else { throw RemoteClientError.invalidResponse }
        let task = URLSession.shared.webSocketTask(with: authenticatedURL)
        webSocketTask = task
        task.resume()

        let first: URLSessionWebSocketTask.Message
        do {
            first = try await receiveFirstMessage(from: task)
        } catch {
            task.cancel(with: .goingAway, reason: nil)
            if webSocketTask === task { webSocketTask = nil }
            throw error
        }
        let welcome = try decode(first)
        guard case .welcome(let details) = welcome else { throw RemoteClientError.unexpectedWelcome }
        guard details.protocolVersion == RemoteProtocolVersion.current, details.region == region?.rawValue, details.role == role else {
            throw RemoteClientError.protocolMismatch
        }
        resumeToken = details.resumeToken
        sessionToken = details.resumeToken
        sourceOnline = details.sourceOnline
        reconnectAttempt = 0
        state = .connected
        onMessage?(welcome)
        receiveTask?.cancel()
        receiveTask = Task { [weak self] in await self?.receiveLoop(task: task) }
        startHeartbeat()
    }

    private func receiveLoop(task: URLSessionWebSocketTask) async {
        do {
            while !Task.isCancelled {
                let decoded = try decode(try await task.receive())
                if case .sourcePresence(let online, _) = decoded { sourceOnline = online }
                if case .pong(_, _, let refreshedToken) = decoded {
                    lastPongAt = Date()
                    if let refreshedToken {
                        resumeToken = refreshedToken
                        sessionToken = refreshedToken
                        RemoteDiagnostics.record(.info, category: "auth", message: "连接凭证已刷新")
                    }
                }
                onMessage?(decoded)
            }
        } catch {
            guard !intentionalDisconnect, webSocketTask === task else { return }
            let message = RemoteDiagnostics.userMessage(for: error)
            RemoteDiagnostics.record(.warning, category: "websocket", message: message)
            state = .reconnecting
            heartbeatTask?.cancel()
            heartbeatTask = nil
            scheduleReconnect()
        }
    }

    private func decode(_ message: URLSessionWebSocketTask.Message) throws -> RemoteServerMessage {
        switch message {
        case .data(let data): return try decoder.decode(RemoteServerMessage.self, from: data)
        case .string(let text): return try decoder.decode(RemoteServerMessage.self, from: Data(text.utf8))
        @unknown default: throw URLError(.cannotDecodeContentData)
        }
    }

    private func receiveFirstMessage(from task: URLSessionWebSocketTask) async throws -> URLSessionWebSocketTask.Message {
        try await withThrowingTaskGroup(of: URLSessionWebSocketTask.Message.self) { group in
            group.addTask { try await task.receive() }
            group.addTask {
                try await Task.sleep(for: .seconds(10))
                throw URLError(.timedOut)
            }
            guard let message = try await group.next() else { throw URLError(.cannotConnectToHost) }
            group.cancelAll()
            return message
        }
    }

    private func scheduleReconnect() {
        guard reconnectTask == nil, let role, let region, !serial.isEmpty else { return }
        reconnectTask = Task { [weak self] in
            while let self, !Task.isCancelled, !self.intentionalDisconnect {
                let delay = min(30.0, 0.5 * pow(2.0, Double(self.reconnectAttempt))) + Double.random(in: 0...0.3)
                self.reconnectAttempt += 1
                RemoteDiagnostics.record(.warning, category: "reconnect", message: "第 \(self.reconnectAttempt) 次重连将在 \(String(format: "%.1f", delay)) 秒后进行", toast: self.reconnectAttempt == 1)
                try? await Task.sleep(for: .seconds(delay))
                guard !Task.isCancelled else { return }
                do {
                    try await self.connect(role: role, region: region, serial: self.serial)
                    self.reconnectTask = nil
                    return
                } catch {
                    RemoteDiagnostics.record(.warning, category: "reconnect", message: RemoteDiagnostics.userMessage(for: error))
                    self.state = .reconnecting
                }
            }
            self?.reconnectTask = nil
        }
    }

    private func startHeartbeat() {
        heartbeatTask?.cancel()
        lastPongAt = Date()
        heartbeatTask = Task { [weak self] in
            while let self, !Task.isCancelled, !self.intentionalDisconnect {
                try? await Task.sleep(for: .seconds(15))
                guard !Task.isCancelled else { return }
                if Date().timeIntervalSince(self.lastPongAt) > 45 {
                    RemoteDiagnostics.record(.warning, category: "heartbeat", message: "45 秒未收到服务器心跳，触发重连")
                    self.webSocketTask?.cancel(with: .goingAway, reason: nil)
                    return
                }
                do {
                    try await self.send(RemotePingMessage(clientTimeMs: Int64(Date().timeIntervalSince1970 * 1_000)))
                } catch {
                    RemoteDiagnostics.record(.warning, category: "heartbeat", message: "心跳发送失败，触发重连")
                    self.webSocketTask?.cancel(with: .goingAway, reason: nil)
                    return
                }
            }
        }
    }

    private func announce(_ state: State) {
        switch state {
        case .idle: break
        case .connecting:
            RemoteDiagnostics.record(.info, category: "state", message: "正在连接远程服务器…", toast: true)
        case .connected:
            RemoteDiagnostics.record(.success, category: "state", message: "远程服务器连接成功", toast: true)
        case .reconnecting:
            RemoteDiagnostics.record(.warning, category: "state", message: "网络中断，正在自动重连", toast: true)
        case .failed(let message):
            RemoteDiagnostics.record(.error, category: "state", message: message, toast: true)
        }
    }
}
