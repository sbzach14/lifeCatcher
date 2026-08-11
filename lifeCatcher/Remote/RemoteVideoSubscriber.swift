import Foundation
import LiveKit
import SwiftUI

@MainActor
final class RemoteVideoSubscriber: NSObject, ObservableObject, RoomDelegate {
    @Published private(set) var track: VideoTrack?
    @Published private(set) var isConnected = false

    private lazy var room = Room(delegate: self)
    private var connecting = false
    private var wanted = false
    private var retryTask: Task<Void, Never>?
    private var retryAttempt = 0
    private weak var client: RemoteBusinessClient?
    private var resettingSession = false
    private var lastReportedError = ""

    func connect(using client: RemoteBusinessClient) async {
        self.client = client
        wanted = true
        guard !isConnected, !connecting else { return }
        connecting = true
        defer { connecting = false }
        do {
            let credentials = try await client.requestMediaToken()
            try await room.connect(url: credentials.serverUrl.absoluteString, token: credentials.participantToken)
            isConnected = true
            retryAttempt = 0
            lastReportedError = ""
            RemoteDiagnostics.record(.success, category: "video", message: "实时画面连接成功", toast: true)
        } catch {
            isConnected = false
            let message = RemoteDiagnostics.userMessage(for: error)
            RemoteDiagnostics.record(.warning, category: "video", message: "实时画面连接失败：\(message)", toast: message != lastReportedError)
            lastReportedError = message
            scheduleRetry(using: client)
        }
    }

    func disconnect() {
        wanted = false
        resettingSession = false
        retryTask?.cancel()
        retryTask = nil
        retryAttempt = 0
        client = nil
        track = nil
        isConnected = false
        Task { await room.disconnect() }
    }

    func resetSession(using client: RemoteBusinessClient) async {
        wanted = true
        resettingSession = true
        retryTask?.cancel()
        retryTask = nil
        retryAttempt = 0
        track = nil
        isConnected = false
        await room.disconnect()
        resettingSession = false
        await connect(using: client)
    }

    nonisolated func room(_: Room, participant _: RemoteParticipant, didSubscribeTrack publication: RemoteTrackPublication) {
        guard let track = publication.track as? VideoTrack else { return }
        Task { @MainActor [weak self] in self?.track = track }
    }

    nonisolated func room(_: Room, didDisconnectWithError _: LiveKitError?) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.track = nil
            self.isConnected = false
            RemoteDiagnostics.record(.warning, category: "video", message: "实时画面连接中断，正在重试", toast: true)
            if !self.resettingSession, let client = self.client { self.scheduleRetry(using: client) }
        }
    }

    private func scheduleRetry(using client: RemoteBusinessClient) {
        guard wanted, retryTask == nil else { return }
        let delay = min(30.0, 0.5 * pow(2.0, Double(retryAttempt))) + Double.random(in: 0...0.3)
        retryAttempt += 1
        retryTask = Task { [weak self, weak client] in
            try? await Task.sleep(for: .seconds(delay))
            guard let self, let client, !Task.isCancelled else { return }
            self.retryTask = nil
            await self.connect(using: client)
        }
    }
}

struct RemoteVideoSurface: UIViewRepresentable {
    @ObservedObject var subscriber: RemoteVideoSubscriber

    func makeUIView(context: Context) -> VideoView {
        let view = VideoView()
        view.layoutMode = .fill
        return view
    }

    func updateUIView(_ view: VideoView, context: Context) {
        view.track = subscriber.track
        view.isEnabled = subscriber.track != nil
    }
}
