import CoreMedia
import CoreImage
import CoreVideo
import Foundation
import LiveKit

private final class RemotePixelBufferBox: @unchecked Sendable {
    let value: CVPixelBuffer

    init(_ value: CVPixelBuffer) {
        self.value = value
    }
}

private final class RemoteFrameProcessor: @unchecked Sendable {
    private let queue = DispatchQueue(label: "lifecatcher.remote.media", qos: .utility)
    private let context = CIContext(options: [.cacheIntermediates: false])
    private let pixelBufferPool: CVPixelBufferPool?

    init() {
        var pool: CVPixelBufferPool?
        let poolAttributes = [kCVPixelBufferPoolMinimumBufferCountKey as String: 3]
        let pixelAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String: 1280,
            kCVPixelBufferHeightKey as String: 720,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:]
        ]
        CVPixelBufferPoolCreate(nil, poolAttributes as CFDictionary, pixelAttributes as CFDictionary, &pool)
        pixelBufferPool = pool
    }

    func process(
        source: RemotePixelBufferBox,
        capturer: BufferCapturer,
        completion: @escaping @MainActor @Sendable () -> Void
    ) {
        queue.async { [self] in
            defer { Task { @MainActor in completion() } }
            var outputBuffer: CVPixelBuffer?
            guard let pixelBufferPool,
                  CVPixelBufferPoolCreatePixelBuffer(nil, pixelBufferPool, &outputBuffer) == kCVReturnSuccess,
                  let output = outputBuffer else { return }
            let input = CIImage(cvPixelBuffer: source.value)
            let scale = CGAffineTransform(
                scaleX: CGFloat(1280) / input.extent.width,
                y: CGFloat(720) / input.extent.height
            )
            context.render(input.transformed(by: scale), to: output)
            capturer.capture(output)
        }
    }
}

@MainActor
final class RemoteVideoPublisher {
    private let client: RemoteBusinessClient
    private let room = Room()
    private let frameProcessor = RemoteFrameProcessor()
    private var track: LocalVideoTrack?
    private var capturer: BufferCapturer?
    private var publication: LocalTrackPublication?
    private var wanted = false
    private var connecting = false
    private var lastFrameTime = CMTime.invalid
    private var isProcessingFrame = false
    private var retryAttempt = 0
    private var nextConnectAttemptAt = Date.distantPast
    private var resettingSession = false
    private var lastReportedError = ""
    init(client: RemoteBusinessClient) {
        self.client = client
        AudioManager.shared.audioSession.isAutomaticConfigurationEnabled = false
    }

    func setWanted(_ wanted: Bool) {
        self.wanted = wanted
        if wanted { Task { await connectIfNeeded() } }
        else { stopPublishing() }
    }

    func offer(sampleBuffer: CMSampleBuffer) {
        guard wanted else { return }
        guard let capturer else {
            if !connecting { Task { await connectIfNeeded() } }
            return
        }
        guard let source = CMSampleBufferGetImageBuffer(sampleBuffer), !isProcessingFrame else { return }
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        if lastFrameTime.isValid, CMTimeSubtract(timestamp, lastFrameTime).seconds < (1.0 / 30.0) { return }
        lastFrameTime = timestamp
        isProcessingFrame = true
        frameProcessor.process(source: RemotePixelBufferBox(source), capturer: capturer) { [weak self] in
            self?.isProcessingFrame = false
        }
    }

    func stop() {
        wanted = false
        stopPublishing()
        Task { await room.disconnect() }
    }

    func resetSession(wanted: Bool) {
        self.wanted = wanted
        resettingSession = true
        stopPublishing()
        Task { [weak self] in
            guard let self else { return }
            await self.room.disconnect()
            self.resettingSession = false
            if self.wanted { await self.connectIfNeeded() }
        }
    }

    private func connectIfNeeded() async {
        guard wanted, track == nil, !connecting, !resettingSession, Date() >= nextConnectAttemptAt else { return }
        connecting = true
        defer { connecting = false }
        do {
            if room.connectionState == .disconnected {
                RemoteDiagnostics.record(.info, category: "video", message: "手机1正在连接媒体服务器")
                let credentials = try await client.requestMediaToken()
                try await room.connect(url: credentials.serverUrl.absoluteString, token: credentials.participantToken)
            }
            let track = LocalVideoTrack.createBufferTrack(
                name: "camera",
                source: .camera,
                options: BufferCaptureOptions(dimensions: .h720_169, fps: 30)
            )
            guard let capturer = track.capturer as? BufferCapturer else { return }
            self.track = track
            self.capturer = capturer
            let publication = try await room.localParticipant.publish(videoTrack: track, options: VideoPublishOptions(
                encoding: VideoEncoding(maxBitrate: 1_800_000, maxFps: 30)
            ))
            self.publication = publication
            retryAttempt = 0
            nextConnectAttemptAt = .distantPast
            lastReportedError = ""
            RemoteDiagnostics.record(.success, category: "video", message: "手机1实时画面已开始发送", toast: true)
        } catch {
            stopPublishing()
            let message = RemoteDiagnostics.userMessage(for: error)
            let delay = min(30.0, 0.5 * pow(2.0, Double(retryAttempt))) + Double.random(in: 0...0.3)
            retryAttempt += 1
            nextConnectAttemptAt = Date().addingTimeInterval(delay)
            RemoteDiagnostics.record(.warning, category: "video", message: "视频发送失败：\(message)，\(String(format: "%.1f", delay)) 秒后重试", toast: message != lastReportedError)
            lastReportedError = message
        }
    }

    private func stopPublishing() {
        let publication = publication
        self.track = nil
        capturer = nil
        self.publication = nil
        lastFrameTime = .invalid
        isProcessingFrame = false
        if !wanted {
            retryAttempt = 0
            nextConnectAttemptAt = .distantPast
        }
        if let publication { Task { try? await room.localParticipant.unpublish(publication: publication) } }
    }
}
