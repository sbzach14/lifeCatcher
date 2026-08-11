import Foundation

@MainActor
final class RemoteReceiverViewModel: ObservableObject {
    enum DisplayMode: String {
        case video
        case black
        case time
        case result
    }

    @Published private(set) var connectionState: RemoteBusinessClient.State = .idle
    @Published private(set) var sourceOnline = false
    @Published private(set) var presentation = RemotePresentationSnapshot.empty
    @Published private(set) var timeText = ""
    @Published private(set) var currentDate = Date()
    @Published var displayMode: DisplayMode = .video
    @Published var errorMessage = ""

    let videoSubscriber = RemoteVideoSubscriber()
    let blackMode: Int
    let timeMode: Int
    let blackFactor: Float

    private let client = RemoteBusinessClient()
    private let audio = RemoteReceiverAudioCoordinator()
    private var timer: Timer?
    private var lastDeliverySeq = 0
    private var sourceSessionId: UUID?
    private var targetSerial = ""
    private var timeOverrideUntil: Date?

    init() {
        let config = readConfigJSON()
        let ints = config?["Int"] as? [String: Int]
        let floats = config?["Float"] as? [String: Float]
        blackMode = ints?["blackMode"] ?? 0
        timeMode = ints?["timeMode"] ?? 0
        blackFactor = floats?["blackFactor"] ?? 0.1
        client.onStateChange = { [weak self] state in
            self?.connectionState = state
            if case .failed(let message) = state { self?.errorMessage = message }
        }
        client.onMessage = { [weak self] message in self?.handle(message) }
        startTimer()
        updateClock()
    }

    func connect(region: RemoteRegion, serial: String) async {
        startTimer()
        audio.cancelAll()
        presentation = .empty
        sourceSessionId = nil
        lastDeliverySeq = 0
        sourceOnline = false
        displayMode = .video
        targetSerial = serial.trimmingCharacters(in: .whitespacesAndNewlines)
        errorMessage = ""
        do {
            try await client.connect(role: .receiver, region: region, serial: targetSerial)
        } catch {
            errorMessage = RemoteDiagnostics.userMessage(for: error)
            client.markFailed(error)
        }
    }

    func disconnect() {
        timer?.invalidate()
        timer = nil
        audio.cancelAll()
        videoSubscriber.disconnect()
        client.disconnect()
        sourceOnline = false
        sourceSessionId = nil
        lastDeliverySeq = 0
    }

    func setDisplayMode(_ mode: DisplayMode) {
        displayMode = mode
        let wantsVideo = mode == .video
        Task {
            do { try await client.send(RemotePresenceMessage(displayMode: mode.rawValue, videoWanted: wantsVideo)) }
            catch {
                RemoteDiagnostics.record(.warning, category: "presence", message: RemoteDiagnostics.userMessage(for: error), toast: true)
            }
        }
        if wantsVideo && sourceOnline {
            Task { await videoSubscriber.connect(using: client) }
        } else {
            videoSubscriber.disconnect()
        }
    }

    private func handle(_ message: RemoteServerMessage) {
        switch message {
        case .welcome(let welcome):
            let mediaSessionChanged = sourceSessionId != nil && sourceSessionId != welcome.sourceSessionId
            if sourceSessionId != welcome.sourceSessionId { lastDeliverySeq = 0 }
            sourceSessionId = welcome.sourceSessionId
            sourceOnline = welcome.sourceOnline
            if welcome.sourceOnline {
                RemoteDiagnostics.record(.success, category: "presence", message: "手机1已在线", toast: true)
            } else {
                RemoteDiagnostics.record(.warning, category: "presence", message: "已连接服务器，正在等待手机1上线", toast: true)
            }
            if displayMode == .video && sourceOnline {
                if mediaSessionChanged { Task { await videoSubscriber.resetSession(using: client) } }
                else { Task { await videoSubscriber.connect(using: client) } }
            }
            Task { try? await client.send(RemotePresenceMessage(displayMode: displayMode.rawValue, videoWanted: displayMode == .video)) }
        case .sourcePresence(let online, let sessionId):
            let wasOnline = sourceOnline
            let mediaSessionChanged = sourceSessionId != nil && sourceSessionId != sessionId
            if sourceSessionId != sessionId { lastDeliverySeq = 0 }
            sourceSessionId = sessionId
            sourceOnline = online
            if online != wasOnline {
                RemoteDiagnostics.record(
                    online ? .success : .warning,
                    category: "presence",
                    message: online ? "手机1已恢复在线" : "手机1已离线，等待自动恢复",
                    toast: true
                )
            }
            if online && displayMode == .video {
                if mediaSessionChanged { Task { await videoSubscriber.resetSession(using: client) } }
                else { Task { await videoSubscriber.connect(using: client) } }
            }
            if !online { videoSubscriber.disconnect() }
        case .receiverDelivery(let delivery):
            consume(delivery)
        case .error(_, let code, let message):
            errorMessage = RemoteDiagnostics.serverMessage(code: code, fallback: message)
            RemoteDiagnostics.record(.error, category: "server", message: errorMessage, toast: true)
        default:
            break
        }
    }

    private func consume(_ delivery: RemoteReceiverDelivery) {
        guard delivery.deliverySeq > lastDeliverySeq else {
            RemoteDiagnostics.record(.info, category: "delivery", message: "忽略重复投递 #\(delivery.deliverySeq)")
            acknowledge(delivery.deliverySeq)
            return
        }
        if lastDeliverySeq > 0, delivery.deliverySeq > lastDeliverySeq + 1 {
            RemoteDiagnostics.record(.warning, category: "delivery", message: "投递序号从 #\(lastDeliverySeq) 跳至 #\(delivery.deliverySeq)")
        }
        lastDeliverySeq = delivery.deliverySeq
        if case .presentation(let snapshot) = delivery.command {
            presentation = snapshot
            if let displayText = snapshot.timeDisplayCue?.displayText, !displayText.isEmpty {
                timeText = displayText
                timeOverrideUntil = Date().addingTimeInterval(5)
            }
        }
        audio.accept(delivery)
        acknowledge(delivery.deliverySeq)
    }

    private func acknowledge(_ deliverySeq: Int) {
        Task {
            do { try await client.send(RemoteDeliveryAckMessage(deliverySeq: deliverySeq)) }
            catch { RemoteDiagnostics.record(.warning, category: "delivery", message: "确认投递 #\(deliverySeq) 失败，将由服务器重发") }
        }
    }

    private func updateClock() {
        currentDate = Date()
        guard timeOverrideUntil.map({ $0 <= currentDate }) ?? true else { return }
        timeOverrideUntil = nil
        if timeMode == 1 { timeText = TimeModeFormatter.timeFormatter1.string(from: currentDate) }
        else if timeMode == 2 { timeText = TimeModeFormatter.timeFormatter2.string(from: currentDate) }
        else { timeText = "" }
    }

    private func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.updateClock() }
        }
    }
}
