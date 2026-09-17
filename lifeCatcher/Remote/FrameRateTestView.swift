import AVFoundation
import CoreImage
import CoreML
import SwiftUI

/// A separate camera/CLS workload: never enters the recognition state machine or writes config.json.
private final class FrameRateTestCapture: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, @unchecked Sendable {
    let session = AVCaptureSession()
    var onRates: ((Double, Double, Int) -> Void)?
    var onVideo: ((RemoteVideoFrame) -> Void)?
    var onStatus: ((String) -> Void)?
    private let queue = DispatchQueue(label: "lifecatcher.fps.camera", qos: .userInitiated)
    private let inferenceQueue = DispatchQueue(label: "lifecatcher.fps.cls", qos: .userInitiated, attributes: .concurrent)
    private let context = CIContext(options: [.cacheIntermediates: false])
    private let stopLock = NSLock()
    private var cancelled = false
    private var stopped: Bool { stopLock.lock(); defer { stopLock.unlock() }; return cancelled }
    // Counters belong to queue. Inference submission mirrors the production concurrent detectionQueue.
    private var model: cls_20260917_texas?
    private var inFlight = 0
    private var captured = 0
    private var completed = 0
    private var remoteVideoFPS = 30
    private var lastVideo = CMTime.invalid
    private var tick: DispatchSourceTimer?
    private var lastTick = ProcessInfo.processInfo.systemUptime

    func start(back: Bool, remoteVideoFPS: Int) {
        queue.async { [self] in
            do {
                self.remoteVideoFPS = remoteVideoFPS == 60 ? 60 : 30
                model = try cls_20260917_texas(configuration: MLModelConfiguration())
                guard !stopped else { return }
                let fps: Double = back ? 240 : 120
                guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: back ? .back : .front) else {
                    throw TestError.message("找不到所选摄像头")
                }
                let formats = device.formats.filter { format in
                    format.videoSupportedFrameRateRanges.contains { $0.minFrameRate <= fps && $0.maxFrameRate >= fps }
                }
                // Match the regular camera's 1080p format when available, then fall back to a supported resolution.
                guard let format = formats.first(where: { CMVideoFormatDescriptionGetDimensions($0.formatDescription).width == 1920 }) ?? formats.last else {
                    let maximum = device.formats.flatMap(\.videoSupportedFrameRateRanges).map(\.maxFrameRate).max() ?? 0
                    throw TestError.message("此摄像头不支持 \(Int(fps)) FPS（最高 \(Int(maximum)) FPS），请切换摄像头")
                }
                let input = try AVCaptureDeviceInput(device: device)
                let output = AVCaptureVideoDataOutput()
                output.alwaysDiscardsLateVideoFrames = true
                output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
                output.setSampleBufferDelegate(self, queue: queue)
                session.beginConfiguration()
                guard session.canAddInput(input), session.canAddOutput(output) else {
                    session.commitConfiguration()
                    throw TestError.message("无法创建摄像头测试会话")
                }
                session.addInput(input)
                session.addOutput(output)
                session.sessionPreset = .inputPriority
                do {
                    try device.lockForConfiguration()
                    device.activeFormat = format
                    device.activeVideoMinFrameDuration = CMTime(value: 1, timescale: Int32(fps))
                    device.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: Int32(fps))
                    device.unlockForConfiguration()
                } catch {
                    session.commitConfiguration()
                    throw error
                }
                session.commitConfiguration()
                guard !stopped else { return }
                session.startRunning()
                let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
                onStatus?("\(back ? "后置" : "前置") · \(dimensions.width)×\(dimensions.height) · 目标 \(Int(fps)) FPS")
                lastTick = ProcessInfo.processInfo.systemUptime
                let timer = DispatchSource.makeTimerSource(queue: queue)
                timer.schedule(deadline: .now() + 1, repeating: 1)
                timer.setEventHandler { [weak self] in
                    guard let self, !self.stopped else { return }
                    let now = ProcessInfo.processInfo.systemUptime
                    let elapsed = now - self.lastTick
                    self.onRates?(Double(self.captured) / elapsed, Double(self.completed) / elapsed, self.inFlight)
                    self.captured = 0; self.completed = 0; self.lastTick = now
                }
                tick = timer
                timer.resume()
            } catch {
                if !stopped { onStatus?(error.localizedDescription) }
            }
        }
    }

    func stop() {
        stopLock.lock(); cancelled = true; stopLock.unlock()
        queue.async { [self] in
            tick?.cancel(); tick = nil
            session.stopRunning()
            for output in session.outputs {
                (output as? AVCaptureVideoDataOutput)?.setSampleBufferDelegate(nil, queue: nil)
            }
            model = nil
        }
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard !stopped else { return }
        captured += 1
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        if !lastVideo.isValid || CMTimeCompare(CMTimeSubtract(timestamp, lastVideo), CMTime(value: 1, timescale: CMTimeScale(remoteVideoFPS))) >= 0 {
            lastVideo = timestamp
            if let source = CMSampleBufferGetImageBuffer(sampleBuffer) {
                onVideo?(RemoteVideoFrame(pixelBuffer: source, timestamp: timestamp))
            }
        }
        guard let model, let source = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let retainedSource = RemoteVideoFrame(pixelBuffer: source, timestamp: timestamp)
        inFlight += 1
        inferenceQueue.async { [self] in
            let succeeded = autoreleasepool { () -> Bool in
                guard !stopped else { return false }
                do {
                    var buffer: CVPixelBuffer?
                    let attributes = [kCVPixelBufferIOSurfacePropertiesKey as String: [:]] as CFDictionary
                    guard CVPixelBufferCreate(nil, 320, 320, kCVPixelFormatType_32BGRA, attributes, &buffer) == kCVReturnSuccess,
                          let buffer else { throw TestError.message("无法创建 CLS 输入图像") }
                    let image = CIImage(cvPixelBuffer: retainedSource.pixelBuffer)
                    context.render(image.transformed(by: CGAffineTransform(scaleX: 320 / image.extent.width, y: 320 / image.extent.height)), to: buffer)
                    _ = try model.prediction(image: buffer, iouThreshold: 0.2, confidenceThreshold: 0.05)
                    return true
                } catch {
                    if !stopped { onStatus?("CLS 推理失败：\(error.localizedDescription)") }
                    return false
                }
            }
            queue.async { [self] in
                inFlight -= 1
                if succeeded && !stopped { completed += 1 }
            }
        }
    }

    private enum TestError: LocalizedError {
        case message(String)
        var errorDescription: String? { if case .message(let text) = self { return text }; return nil }
    }
}

@MainActor
private final class FrameRateTestModel: ObservableObject {
    @Published var session: AVCaptureSession?
    @Published var cameraStatus = "准备测试"
    @Published var networkStatus = "尚未连接"
    @Published var cameraFPS = 0.0
    @Published var clsFPS = 0.0
    @Published var clsPending = 0
    @Published var videoFPS = 0.0
    @Published var encodedFPS: Double?
    private var capture: FrameRateTestCapture?
    private var client: RemoteBusinessClient?
    private var publisher: RemoteVideoPublisher?
    private var connectionTask: Task<Void, Never>?
    private var meter: Timer?
    private var generation = UUID()
    private var isRunning = false
    private var activeBackCamera = false
    private var activeRemoteMode = false

    func start(back: Bool, remoteEnabled: Bool, remoteVideoFPS: Int, remoteVideoResolution: Int, force: Bool = false) async {
        if !force && isRunning && activeBackCamera == back && activeRemoteMode == remoteEnabled { return }
        stop()
        isRunning = true
        activeBackCamera = back
        activeRemoteMode = remoteEnabled
        let run = generation
        cameraStatus = "请求摄像头权限"
        let granted: Bool
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: granted = true
        case .notDetermined: granted = await AVCaptureDevice.requestAccess(for: .video)
        default: granted = false
        }
        guard run == generation, !Task.isCancelled else { return }
        guard granted else { cameraStatus = "未获摄像头权限，请在系统设置中允许访问"; return }
        cameraStatus = "加载 CLS 模型和高速相机…"
        let capture = FrameRateTestCapture()
        self.capture = capture
        session = capture.session
        capture.onRates = { [weak self] camera, cls, pending in
            Task { @MainActor in
                guard let self, self.generation == run else { return }
                self.cameraFPS = camera; self.clsFPS = cls; self.clsPending = pending
            }
        }
        capture.onStatus = { [weak self] text in
            Task { @MainActor in
                guard let self, self.generation == run else { return }
                self.cameraStatus = text
            }
        }
        if remoteEnabled {
            configureRemoteTest(capture: capture, run: run, remoteVideoFPS: remoteVideoFPS, remoteVideoResolution: remoteVideoResolution)
        } else {
            networkStatus = "本地模式不连接 LiveKit"
        }
        capture.start(back: back, remoteVideoFPS: remoteVideoFPS)
    }

    private func configureRemoteTest(capture: FrameRateTestCapture, run: UUID, remoteVideoFPS: Int, remoteVideoResolution: Int) {
        let client = RemoteBusinessClient()
        let publisher = RemoteVideoPublisher(
            client: client,
            reportStatistics: true,
            targetFPS: remoteVideoFPS,
            targetResolution: remoteVideoResolution
        )
        self.client = client
        self.publisher = publisher
        capture.onVideo = { [weak self] frame in
            Task { @MainActor in
                guard let self, self.generation == run else { return }
                self.publisher?.offer(frame: frame)
            }
        }
        client.onStateChange = { [weak self] state in
            guard let self, self.generation == run else { return }
            switch state {
            case .connected: self.networkStatus = "业务连接成功，正在建立 LiveKit 视频"
            case .connecting: self.networkStatus = "正在连接服务器"
            case .reconnecting: self.networkStatus = "网络重连中"
            case .idle: self.networkStatus = "已断开"
            case .failed(let text): self.networkStatus = text
            }
        }
        // The benchmark publishes even without a viewer and never touches the result outbox.
        client.onMessage = { [weak self] message in
            guard let self, self.generation == run else { return }
            if case .welcome = message { publisher.resetSession(wanted: true) }
        }
        var previousFrames = 0
        var previousTime = ProcessInfo.processInfo.systemUptime
        meter = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.generation == run else { return }
                let now = ProcessInfo.processInfo.systemUptime
                self.videoFPS = Double(max(0, publisher.submittedFrameCount - previousFrames)) / (now - previousTime)
                previousFrames = publisher.submittedFrameCount
                previousTime = now
                self.encodedFPS = publisher.encodedFramesPerSecond
                if publisher.isPublishing { self.networkStatus = "LiveKit 已发布 · \(publisher.targetResolution)p / \(publisher.targetFPS) FPS 上限" }
                else if let error = publisher.publishingError { self.networkStatus = "LiveKit 重试中：\(error)" }
                else if client.state == .connected { self.networkStatus = "LiveKit 正在连接或重连，尚未发送视频" }
            }
        }
        connectionTask = Task { [weak self] in
            do {
                try await client.connect(role: .source, region: RemotePreferences.sourceRegion, serial: AuthManager.retrieveUUID())
                guard let self, self.generation == run, !Task.isCancelled else { client.disconnect(); return }
            } catch {
                guard let self, self.generation == run, !Task.isCancelled else { return }
                self.networkStatus = "连接失败：\(error.localizedDescription)"
                client.maintainConnectionAfterFailure()
            }
        }
    }

    func stop() {
        isRunning = false
        generation = UUID()
        connectionTask?.cancel(); connectionTask = nil
        meter?.invalidate(); meter = nil
        capture?.stop(); capture = nil; session = nil
        publisher?.stop(); publisher = nil
        client?.disconnect(); client = nil
        cameraFPS = 0; clsFPS = 0; clsPending = 0; videoFPS = 0; encodedFPS = nil
        cameraStatus = "测试已停止"; networkStatus = "已断开"
    }
}

private struct FrameRateCameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    final class Preview: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    }
    func makeUIView(context: Context) -> Preview { Preview() }
    func updateUIView(_ view: Preview, context: Context) {
        let layer = view.layer as! AVCaptureVideoPreviewLayer
        layer.session = session
        layer.videoGravity = .resizeAspect
    }
    static func dismantleUIView(_ view: Preview, coordinator: ()) {
        (view.layer as? AVCaptureVideoPreviewLayer)?.session = nil
    }
}

struct FrameRateTestView: View {
    @StateObject private var model = FrameRateTestModel()
    @State private var back: Bool
    @State private var restart = 0
    let remoteEnabled: Bool
    let remoteVideoFPS: Int
    let remoteVideoResolution: Int
    @Environment(\.scenePhase) private var scenePhase
    init(isBackCamera: Bool, remoteEnabled: Bool, remoteVideoFPS: Int = 30, remoteVideoResolution: Int = 720) {
        _back = State(initialValue: isBackCamera)
        self.remoteEnabled = remoteEnabled
        self.remoteVideoFPS = [30, 60].contains(remoteVideoFPS) ? remoteVideoFPS : 30
        self.remoteVideoResolution = remoteVideoResolution == 1080 ? 1080 : 720
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Picker("摄像头", selection: $back) {
                    Text("前置 · 120 FPS").tag(false)
                    Text("后置 · 240 FPS").tag(true)
                }.pickerStyle(.segmented)
                if let session = model.session {
                    FrameRateCameraPreview(session: session).frame(height: 200)
                }
                Button("重新开始测试") { restart += 1 }
                Text(model.cameraStatus).font(.subheadline)
                rate("相机采集", model.cameraFPS)
                rate("CLS 完成", model.clsFPS)
                HStack {
                    Text("CLS 待完成")
                    Spacer()
                    Text("\(model.clsPending) 帧").font(.title2).bold()
                }.monospacedDigit()
                if remoteEnabled {
                    rate("LiveKit 送帧", model.videoFPS)
                    HStack {
                        Text("LiveKit 编码")
                        Spacer()
                        Text(model.encodedFPS.map { String(format: "%.1f FPS", $0) } ?? "暂无统计")
                    }.monospacedDigit()
                    Text(model.networkStatus).font(.subheadline)
                }
                Text("CLS：cls-20260917-texas · 320×320\n每个相机回调都按正式识别链路提交到并发 CLS 队列；“完成”是每秒成功返回的推理数，“待完成”是当前积压。\(remoteEnabled ? "LiveKit 送帧不代表接收端帧率。" : "本地模式不创建网络连接。")返回或切到后台即停止测试。")
                    .font(.footnote).foregroundStyle(.secondary)
            }.padding()
        }
        .navigationTitle("帧率测试")
        .onAppear { Task { await model.start(back: back, remoteEnabled: remoteEnabled, remoteVideoFPS: remoteVideoFPS, remoteVideoResolution: remoteVideoResolution) } }
        .onChange(of: back) { _, value in
            Task { await model.start(back: value, remoteEnabled: remoteEnabled, remoteVideoFPS: remoteVideoFPS, remoteVideoResolution: remoteVideoResolution) }
        }
        .onChange(of: restart) { _, _ in
            Task { await model.start(back: back, remoteEnabled: remoteEnabled, remoteVideoFPS: remoteVideoFPS, remoteVideoResolution: remoteVideoResolution, force: true) }
        }
        .onDisappear { model.stop() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background { model.stop() }
        }
    }

    private func rate(_ title: String, _ fps: Double) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(String(format: "%.1f FPS", fps)).font(.title2).bold()
        }.monospacedDigit()
    }
}
