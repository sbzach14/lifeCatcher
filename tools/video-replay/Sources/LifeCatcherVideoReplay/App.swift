import Foundation

@main
enum LifeCatcherVideoReplayApp {
    static func main() async {
        do {
            let currentDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
            let arguments = Array(CommandLine.arguments.dropFirst())
            if arguments.contains("--help") || arguments.contains("-h") {
                print(CLIOptions.usage())
                return
            }
            let options = try CLIOptions.parse(arguments: arguments, currentDirectory: currentDirectory)
            try await run(options: options)
        } catch {
            fputs("错误：\(error)\n\n\(CLIOptions.usage())\n", stderr)
            exit(2)
        }
    }

    private static func run(options: CLIOptions) async throws {
        print("加载正式 Core ML 模型……")
        let models = try ModelRunner(
            modelsDirectory: options.modelsDirectory,
            mode: options.mode,
            orientation: options.orientation
        )
        let engine = RecognitionEngine(
            modelRunner: models,
            logicalFPS: options.logicalFPS,
            mode: options.mode,
            orientation: options.orientation,
            allowedCards: options.allowedCards,
            minimumCards: options.minimumCards,
            addCardMode: options.addCardMode,
            trace: options.trace,
            singleROIAreaFactor: options.singleROIAreaFactor,
            forcedSingleEntrySide: options.forcedSingleEntrySide
        )
        let reader = try await VideoFrameReader(url: options.videoURL)
        try reader.start()
        let annotationWriter = try options.annotatedFramesDirectory.map {
            try FrameAnnotationWriter(directory: $0)
        }

        print("逐帧解码并按逻辑 \(options.logicalFPS) FPS 推进识别状态机……")
        var sourceFrameIndex = 0
        var processedFrameCount = 0
        while options.maximumFrames.map({ processedFrameCount < $0 }) ?? true,
              let sourceFrame = try reader.nextPixelBuffer() {
            if sourceFrameIndex < options.skipFrames {
                sourceFrameIndex += 1
                continue
            }
            let exportedFrame = try annotationWriter.map { _ in
                try ImagePipeline.rotatedFramePreservingSize(sourceFrame, rotation: options.rotation)
            }
            let cameraFrame = try ImagePipeline.normalizeCameraFrame(sourceFrame, rotation: options.rotation)
            let inference = try engine.process(cameraFrame: cameraFrame, logicalFrame: sourceFrameIndex)
            if let annotationWriter, let exportedFrame {
                try annotationWriter.write(exportedFrame: exportedFrame, inference: inference)
            }
            sourceFrameIndex += 1
            processedFrameCount += 1
            if !options.trace && processedFrameCount.isMultiple(of: 100) {
                print("已处理 \(processedFrameCount) 帧，当前源帧 \(sourceFrameIndex)")
            }
        }

        if options.flushFrames > 0 {
            let blackFrame = try ImagePipeline.blackCameraFrame()
            for offset in 0..<options.flushFrames {
                try engine.process(cameraFrame: blackFrame, logicalFrame: sourceFrameIndex + offset)
            }
        }

        let totalLogicalFrames = sourceFrameIndex + options.flushFrames
        let metadata = reader.metadata
        let report = ReplayReport(
            video: ReplayReport.Video(
                path: options.videoURL.path,
                decodedFrameCount: sourceFrameIndex,
                processedFrameCount: processedFrameCount,
                width: metadata.width,
                height: metadata.height,
                sourceNominalFPS: metadata.nominalFPS,
                sourceDurationSeconds: metadata.durationSeconds
            ),
            configuration: ReplayReport.Configuration(
                logicalFPS: options.logicalFPS,
                mode: options.mode,
                orientation: options.orientation,
                rotation: options.rotation,
                minimumCards: options.minimumCards,
                addCardMode: options.addCardMode,
                allowedCards: options.allowedCards,
                flushFrames: options.flushFrames,
                skipFrames: options.skipFrames,
                maximumFrames: options.maximumFrames,
                singleROIAreaFactor: options.singleROIAreaFactor,
                forcedSingleEntrySide: options.forcedSingleEntrySide?.rawValue,
                annotatedFramesDirectory: options.annotatedFramesDirectory?.path
            ),
            logicalDurationSeconds: Double(totalLogicalFrames) / Double(options.logicalFPS),
            stateTransitions: engine.transitions,
            sessions: engine.sessions,
            finalState: engine.state
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let data = try encoder.encode(report)
        let parent = options.outputURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: parent, withIntermediateDirectories: true)
        try data.write(to: options.outputURL, options: .atomic)

        print("完成：已解码源帧 \(sourceFrameIndex)，已处理 \(processedFrameCount)，逻辑帧 \(totalLogicalFrames)，识别批次 \(engine.sessions.count)")
        for (index, session) in engine.sessions.enumerated() {
            print("批次 \(index + 1)：\(session.kind)，\(session.cards.count) 张，accepted=\(session.acceptedByConfiguredMode)")
            print(session.cardLabels.joined(separator: " "))
        }
        print("JSON：\(options.outputURL.path)")
    }
}
