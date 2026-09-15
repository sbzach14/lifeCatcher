import CoreMedia
import CoreImage
import CoreVideo
import Foundation
import LiveKit

final class RemoteVideoFrame: @unchecked Sendable {
    let pixelBuffer: CVPixelBuffer
    let timestamp: CMTime

    init(pixelBuffer: CVPixelBuffer, timestamp: CMTime) {
        self.pixelBuffer = pixelBuffer
        self.timestamp = timestamp
    }

    convenience init?(sampleBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        self.init(pixelBuffer: pixelBuffer, timestamp: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
    }
}

private final class RemoteFrameProcessor: @unchecked Sendable {
    private let queue = DispatchQueue(label: "lifecatcher.remote.media", qos: .utility)
    private let context = CIContext(options: [.cacheIntermediates: false])
    private let pixelBufferPool: CVPixelBufferPool?

    private let width: Int
    private let height: Int

    init(resolution: Int) {
        width = resolution == 1080 ? 1920 : 1280
        height = resolution == 1080 ? 1080 : 720
        var pool: CVPixelBufferPool?
        let poolAttributes = [kCVPixelBufferPoolMinimumBufferCountKey as String: 3]
        let pixelAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String: width,
            kCVPixelBufferHeightKey as String: height,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:]
        ]
        CVPixelBufferPoolCreate(nil, poolAttributes as CFDictionary, pixelAttributes as CFDictionary, &pool)
        pixelBufferPool = pool
    }

    func process(
        source: RemoteVideoFrame,
        capturer: BufferCapturer,
        completion: @escaping @MainActor @Sendable (Bool) -> Void
    ) {
        queue.async { [self] in
            var submitted = false
            defer { let result = submitted; Task { @MainActor in completion(result) } }
            var outputBuffer: CVPixelBuffer?
            guard let pixelBufferPool,
                  CVPixelBufferPoolCreatePixelBuffer(nil, pixelBufferPool, &outputBuffer) == kCVReturnSuccess,
                  let output = outputBuffer else { return }
            let input = CIImage(cvPixelBuffer: source.pixelBuffer)
            let scale = CGAffineTransform(
                scaleX: CGFloat(width) / input.extent.width,
                y: CGFloat(height) / input.extent.height
            )
            context.render(input.transformed(by: scale), to: output)
            capturer.capture(output)
            submitted = true
        }
    }
}

@MainActor
final class RemoteVideoPublisher {
    private let client: RemoteBusinessClient
    private let reportStatistics: Bool
    let targetFPS: Int
    let targetResolution: Int
    private let room = Room()
    private let frameProcessor: RemoteFrameProcessor
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
    private var generation = UUID()
    private(set) var submittedFrameCount = 0
    var isPublishing: Bool { publication != nil && room.connectionState == .connected }
    var publishingError: String? { lastReportedError.isEmpty ? nil : lastReportedError }
    var encodedFramesPerSecond: Double? {
        guard isPublishing else { return nil }
        return track?.statistics?.outboundRtpStream.compactMap(\.framesPerSecond).max()
    }
    init(
        client: RemoteBusinessClient,
        reportStatistics: Bool = false,
        targetFPS: Int = RemotePreferences.videoFPS,
        targetResolution: Int = RemotePreferences.videoResolution
    ) {
        self.client = client
        self.reportStatistics = reportStatistics
        self.targetFPS = [30, 60].contains(targetFPS) ? targetFPS : 30
        self.targetResolution = targetResolution == 1080 ? 1080 : 720
        self.frameProcessor = RemoteFrameProcessor(resolution: self.targetResolution)
        AudioManager.shared.audioSession.isAutomaticConfigurationEnabled = false
    }

    func setWanted(_ wanted: Bool) {
        self.wanted = wanted
        if wanted { Task { await connectIfNeeded() } }
        else { stopPublishing() }
    }

    func offer(frame: RemoteVideoFrame) {
        guard wanted else { return }
        if room.connectionState == .disconnected, track != nil, !connecting, !resettingSession {
            stopPublishing()
        }
        guard let capturer else {
            if !connecting { Task { await connectIfNeeded() } }
            return
        }
        // Buffer tracks need a frame to resolve dimensions before publish() can finish.
        guard !isProcessingFrame else { return }
        let timestamp = frame.timestamp
        if lastFrameTime.isValid, CMTimeCompare(CMTimeSubtract(timestamp, lastFrameTime), CMTime(value: 1, timescale: CMTimeScale(targetFPS))) < 0 { return }
        lastFrameTime = timestamp
        isProcessingFrame = true
        let currentGeneration = generation
        frameProcessor.process(source: frame, capturer: capturer) { [weak self] submitted in
            guard let self, self.generation == currentGeneration else { return }
            self.isProcessingFrame = false
            if submitted && self.isPublishing { self.submittedFrameCount += 1 }
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
        let currentGeneration = generation
        defer { connecting = false }
        do {
            if room.connectionState == .disconnected {
                RemoteDiagnostics.record(.info, category: "video", message: "手机1正在连接媒体服务器")
                let credentials = try await client.requestMediaToken()
                guard wanted, generation == currentGeneration else { return }
                try await room.connect(url: credentials.serverUrl.absoluteString, token: credentials.participantToken)
            }
            guard wanted, generation == currentGeneration else {
                await room.disconnect()
                return
            }
            let track = LocalVideoTrack.createBufferTrack(
                name: "camera",
                source: .camera,
                options: BufferCaptureOptions(
                    dimensions: targetResolution == 1080 ? .h1080_169 : .h720_169,
                    fps: targetFPS
                ),
                reportStatistics: reportStatistics
            )
            guard let capturer = track.capturer as? BufferCapturer else { return }
            self.track = track
            self.capturer = capturer
            let publication = try await room.localParticipant.publish(videoTrack: track, options: VideoPublishOptions(
                encoding: VideoEncoding(maxBitrate: 1_800_000, maxFps: targetFPS)
            ))
            guard wanted, generation == currentGeneration else {
                try? await room.localParticipant.unpublish(publication: publication)
                return
            }
            self.publication = publication
            retryAttempt = 0
            nextConnectAttemptAt = .distantPast
            lastReportedError = ""
            RemoteDiagnostics.record(.success, category: "video", message: "手机1实时画面已开始发送（\(targetResolution)p\(targetFPS)）", toast: true)
        } catch {
            guard wanted, generation == currentGeneration else { return }
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
        generation = UUID()
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
