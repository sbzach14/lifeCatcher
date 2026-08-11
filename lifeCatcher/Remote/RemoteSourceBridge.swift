import CoreMedia
import CoreVideo
import Foundation

@MainActor
final class RemoteSourceBridge: ObservableObject {
    @Published private(set) var state: RemoteBusinessClient.State = .idle
    @Published private(set) var videoWanted = false
    @Published private(set) var receiverPresence: RemotePresenceState = .offline
    @Published private(set) var desktopPresence: RemotePresenceState = .offline

    var onStatusChange: ((RemoteBusinessClient.State, RemotePresenceState, RemotePresenceState) -> Void)?

    private struct AssignedEvent {
        let requestId: UUID
        let event: RemoteSourceEvent
    }

    private let client = RemoteBusinessClient()
    private let videoPublisher: RemoteVideoPublisher
    private let outboxStore = RemoteOutboxStore()
    private var pending: [RemotePendingSourceEvent]
    private var assigned: AssignedEvent?
    private var sourceSessionId: UUID?
    private var nextSequence = 1
    private var currentOperationId: UUID?
    private var activeRegion: RemoteRegion?
    private var activeSerial: String?

    init() {
        pending = outboxStore.load()
        videoPublisher = RemoteVideoPublisher(client: client)
        client.onMessage = { [weak self] message in self?.handle(message) }
        client.onStateChange = { [weak self] state in
            guard let self else { return }
            self.state = state
            if state == .reconnecting {
                self.assigned = nil
            }
            self.publishStatus()
        }
    }

    func startIfEnabled() {
        guard RemotePreferences.sourceEnabled else { return }
        let serial = AuthManager.retrieveUUID()
        guard !serial.isEmpty else {
            RemoteDiagnostics.record(.error, category: "source", message: "无法读取本机序列号，远程连接未启动", toast: true)
            return
        }
        let region = RemotePreferences.sourceRegion
        guard region.isConfigured else {
            RemoteDiagnostics.record(.error, category: "source", message: "\(region.title) IP 尚未配置", toast: true)
            return
        }
        activeRegion = region
        activeSerial = serial
        Task {
            do {
                try await client.connect(role: .source, region: region, serial: serial)
            } catch {
                RemoteDiagnostics.record(.error, category: "source", message: RemoteDiagnostics.userMessage(for: error), toast: true)
                state = .reconnecting
                client.maintainConnectionAfterFailure()
            }
        }
    }

    func stop() {
        videoPublisher.stop()
        client.disconnect()
        state = .idle
        videoWanted = false
        receiverPresence = .offline
        desktopPresence = .offline
        activeRegion = nil
        activeSerial = nil
        currentOperationId = nil
        publishStatus()
        RemoteDiagnostics.record(.info, category: "source", message: "手机1远程发送已停止")
    }

    func offerVideoFrame(_ sampleBuffer: CMSampleBuffer) {
        guard videoWanted else { return }
        videoPublisher.offer(sampleBuffer: sampleBuffer)
    }

    func emitPrompt(_ prompt: RemotePromptKind) {
        guard let activeRegion, let activeSerial else { return }
        if prompt == .start || currentOperationId == nil { currentOperationId = UUID() }
        let now = Int64(Date().timeIntervalSince1970 * 1_000)
        enqueue(RemotePendingSourceEvent(
            region: activeRegion,
            serial: activeSerial,
            eventId: UUID(),
            operationId: currentOperationId!,
            createdAtMs: now,
            expiresAtMs: now + 5_000,
            payload: .prompt(prompt)
        ))
    }

    func emitPresentation(_ presentation: RemotePresentationSnapshot) {
        guard let activeRegion, let activeSerial else { return }
        if currentOperationId == nil { currentOperationId = UUID() }
        enqueue(RemotePendingSourceEvent(
            region: activeRegion,
            serial: activeSerial,
            eventId: UUID(),
            operationId: currentOperationId!,
            createdAtMs: Int64(Date().timeIntervalSince1970 * 1_000),
            expiresAtMs: nil,
            payload: .presentation(presentation)
        ))
    }

    private func enqueue(_ pendingEvent: RemotePendingSourceEvent) {
        pending.append(pendingEvent)
        let now = Int64(Date().timeIntervalSince1970 * 1_000)
        pending.removeAll { $0.expiresAtMs.map { $0 <= now } ?? false }
        outboxStore.save(pending)
        RemoteDiagnostics.record(.info, category: "outbox", message: "远程事件已入队，待发送 \(pending.count) 条")
        flush()
    }

    private func flush() {
        let now = Int64(Date().timeIntervalSince1970 * 1_000)
        pending.removeAll { $0.expiresAtMs.map { $0 <= now } ?? false }
        outboxStore.save(pending)
        guard case .connected = client.state, let sourceSessionId, assigned == nil else { return }
        guard let activeRegion, let activeSerial,
              let item = pending.first(where: { $0.region == activeRegion && $0.serial == activeSerial }) else { return }
        let event = RemoteSourceEvent(
            schemaVersion: RemoteProtocolVersion.current,
            eventId: item.eventId,
            operationId: item.operationId,
            sourceSessionId: sourceSessionId,
            sourceEventSeq: nextSequence,
            createdAtMs: item.createdAtMs,
            expiresAtMs: item.expiresAtMs,
            payload: item.payload
        )
        let assignedEvent = AssignedEvent(requestId: UUID(), event: event)
        assigned = assignedEvent
        Task {
            do { try await client.send(RemoteSourceEventMessage(requestId: assignedEvent.requestId, event: event)) }
            catch {
                assigned = nil
                client.reconnectNow(reason: "远程事件发送失败，保留队列并重连")
            }
        }
    }

    private func handle(_ message: RemoteServerMessage) {
        state = client.state
        switch message {
        case .welcome(let welcome):
            let mediaSessionChanged = sourceSessionId != nil && sourceSessionId != welcome.sourceSessionId
            if sourceSessionId != welcome.sourceSessionId {
                sourceSessionId = welcome.sourceSessionId
                assigned = nil
            }
            nextSequence = welcome.nextSourceEventSeq ?? 1
            receiverPresence = welcome.receiverPresence
            desktopPresence = welcome.desktopPresence
            videoWanted = welcome.videoWanted
            if welcome.videoWanted {
                RemoteDiagnostics.record(.info, category: "video", message: "接收端请求实时画面，开始建立 720p30 视频")
            }
            if mediaSessionChanged { videoPublisher.resetSession(wanted: welcome.videoWanted) }
            else { videoPublisher.setWanted(welcome.videoWanted) }
            publishStatus()
            flush()
        case .receiverPresence(let presence):
            let previous = receiverPresence
            receiverPresence = presence
            announcePresenceChange(label: "手机2", from: previous, to: presence)
            publishStatus()
        case .desktopPresence(let presence):
            let previous = desktopPresence
            desktopPresence = presence
            announcePresenceChange(label: "桌面端", from: previous, to: presence)
            publishStatus()
        case .acknowledgement(let requestId, _, let sourceEventSeq, _):
            guard let match = assigned, match.requestId == requestId else { return }
            assigned = nil
            pending.removeAll { $0.eventId == match.event.eventId }
            outboxStore.save(pending)
            nextSequence = (sourceEventSeq ?? match.event.sourceEventSeq) + 1
            RemoteDiagnostics.record(.success, category: "outbox", message: "远程事件 #\(match.event.sourceEventSeq) 已确认")
            flush()
        case .sourceControl(let wanted):
            if wanted != videoWanted {
                RemoteDiagnostics.record(.info, category: "video", message: wanted ? "接收端开始查看实时画面" : "接收端停止查看实时画面")
            }
            videoWanted = wanted
            videoPublisher.setWanted(wanted)
        case .error(let requestId, let code, let message):
            let readableMessage = RemoteDiagnostics.serverMessage(code: code, fallback: message)
            RemoteDiagnostics.record(.error, category: "server", message: readableMessage, toast: true)
            guard let requestId, let match = assigned, match.requestId == requestId else { return }
            assigned = nil
            if code == "invalid_message" {
                pending.removeAll { $0.eventId == match.event.eventId }
                outboxStore.save(pending)
                flush()
            } else {
                client.reconnectNow(reason: readableMessage)
            }
        default:
            break
        }
    }

    private func publishStatus() {
        onStatusChange?(state, receiverPresence, desktopPresence)
    }

    /// 手机1只产生可视日志/toast；这里绝不触发音频 API。
    private func announcePresenceChange(label: String, from previous: RemotePresenceState, to current: RemotePresenceState) {
        guard previous != current else { return }
        let level: RemoteDiagnosticLevel
        let message: String
        switch current {
        case .online:
            level = .success
            message = "\(label)已在线"
        case .reconnecting:
            level = .warning
            message = "\(label)网络波动，等待自动重连"
        case .offline:
            level = .warning
            message = "\(label)已离线"
        }
        RemoteDiagnostics.record(level, category: "presence", message: message, toast: true)
    }
}
