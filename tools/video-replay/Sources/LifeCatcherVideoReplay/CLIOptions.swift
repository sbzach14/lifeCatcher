import Foundation

struct CLIOptions {
    enum ForcedSingleEntrySide: String {
        case left
        case right
    }

    let videoURL: URL
    let modelsDirectory: URL
    let outputURL: URL
    let logicalFPS: Int
    let mode: ReplayMode
    let orientation: CameraOrientation
    let rotation: FrameRotation
    let minimumCards: Int
    let addCardMode: Int
    let allowedCards: [Int]
    let flushFrames: Int
    let skipFrames: Int
    let maximumFrames: Int?
    let singleROIAreaFactor: Float
    let forcedSingleEntrySide: ForcedSingleEntrySide?
    let annotatedFramesDirectory: URL?
    let trace: Bool

    static func parse(arguments: [String], currentDirectory: URL) throws -> CLIOptions {
        var values: [String: String] = [:]
        var flags = Set<String>()
        var index = 0
        while index < arguments.count {
            let argument = arguments[index]
            guard argument.hasPrefix("--") else {
                throw ReplayError.invalidArguments("无法识别的位置参数：\(argument)")
            }
            if argument == "--trace" {
                flags.insert(argument)
                index += 1
                continue
            }
            guard index + 1 < arguments.count else {
                throw ReplayError.invalidArguments("参数 \(argument) 缺少值")
            }
            values[argument] = arguments[index + 1]
            index += 2
        }

        guard let videoPath = values["--video"] else {
            throw ReplayError.invalidArguments("必须提供 --video <path>")
        }
        let fps = Int(values["--fps"] ?? "120") ?? -1
        guard fps == 120 || fps == 240 else {
            throw ReplayError.invalidArguments("--fps 只允许 120 或 240")
        }
        guard let mode = ReplayMode(rawValue: values["--mode"] ?? "horizontal-shuffle") else {
            throw ReplayError.invalidArguments("--mode 只允许 horizontal-shuffle、shuffle、riffle 或 both")
        }
        guard let orientation = CameraOrientation(rawValue: values["--orientation"] ?? "horizontal") else {
            throw ReplayError.invalidArguments("--orientation 只允许 horizontal 或 vertical")
        }
        guard let rotation = FrameRotation(rawValue: values["--rotation"] ?? "none") else {
            throw ReplayError.invalidArguments("--rotation 只允许 auto、none、clockwise 或 counterclockwise")
        }
        let minimumCards = Int(values["--min-cards"] ?? "10") ?? -1
        guard minimumCards >= 0 else {
            throw ReplayError.invalidArguments("--min-cards 必须是非负整数")
        }
        let addCardMode = Int(values["--add-card-mode"] ?? "1") ?? -1
        guard (0...2).contains(addCardMode) else {
            throw ReplayError.invalidArguments("--add-card-mode 只允许 0、1、2")
        }
        let flushFrames = Int(values["--flush-frames"] ?? "16") ?? -1
        guard flushFrames >= 0 else {
            throw ReplayError.invalidArguments("--flush-frames 必须是非负整数")
        }
        let skipFrames = Int(values["--skip-frames"] ?? "0") ?? -1
        guard skipFrames >= 0 else {
            throw ReplayError.invalidArguments("--skip-frames 必须是非负整数")
        }
        let maximumFrames = values["--max-frames"].flatMap(Int.init)
        if values["--max-frames"] != nil && (maximumFrames == nil || maximumFrames! <= 0) {
            throw ReplayError.invalidArguments("--max-frames 必须是正整数")
        }
        let singleROIAreaFactor = Float(values["--single-roi-area-factor"] ?? "90") ?? -1
        guard singleROIAreaFactor > 0 else {
            throw ReplayError.invalidArguments("--single-roi-area-factor 必须是正数")
        }
        let forcedSingleEntrySide: ForcedSingleEntrySide?
        if let value = values["--force-single-entry"] {
            guard let side = ForcedSingleEntrySide(rawValue: value) else {
                throw ReplayError.invalidArguments("--force-single-entry 只允许 left 或 right")
            }
            forcedSingleEntrySide = side
        } else {
            forcedSingleEntrySide = nil
        }

        let videoURL = resolve(path: videoPath, relativeTo: currentDirectory)
        guard FileManager.default.fileExists(atPath: videoURL.path) else {
            throw ReplayError.invalidArguments("视频不存在：\(videoURL.path)")
        }

        let modelsURL = values["--models-dir"].map { resolve(path: $0, relativeTo: currentDirectory) }
            ?? findDefaultModelsDirectory(startingAt: currentDirectory)
        guard FileManager.default.fileExists(atPath: modelsURL.path) else {
            throw ReplayError.invalidArguments("模型目录不存在：\(modelsURL.path)，请使用 --models-dir 指定")
        }

        let defaultOutput = currentDirectory.appendingPathComponent("video-replay-result.json")
        let outputURL = values["--output"].map { resolve(path: $0, relativeTo: currentDirectory) } ?? defaultOutput
        let annotatedFramesDirectory = values["--frames-output"].map { resolve(path: $0, relativeTo: currentDirectory) }
        let allowedCards = try parseAllowedCards(values["--allowed-cards"] ?? "0-51")

        return CLIOptions(
            videoURL: videoURL,
            modelsDirectory: modelsURL,
            outputURL: outputURL,
            logicalFPS: fps,
            mode: mode,
            orientation: orientation,
            rotation: rotation,
            minimumCards: minimumCards,
            addCardMode: addCardMode,
            allowedCards: allowedCards,
            flushFrames: flushFrames,
            skipFrames: skipFrames,
            maximumFrames: maximumFrames,
            singleROIAreaFactor: singleROIAreaFactor,
            forcedSingleEntrySide: forcedSingleEntrySide,
            annotatedFramesDirectory: annotatedFramesDirectory,
            trace: flags.contains("--trace")
        )
    }

    static func usage() -> String {
        """
        用法：
          swift run --package-path tools/video-replay lifecatcher-video-replay \\
            --video /absolute/path/input.mp4 [选项]

        选项：
          --fps 120|240                     逻辑输入帧率，默认 120
          --mode horizontal-shuffle|shuffle|riffle|both
                                           识别方式，默认 horizontal-shuffle（横洗）
          --orientation horizontal|vertical 实际牌堆方向，默认 horizontal
          --rotation none|clockwise|counterclockwise|auto
                                           输入旋转，默认 none；auto 仅对竖屏源逆时针旋转
          --models-dir <path>                .mlmodel 目录，默认 lifeCatcher/Resources
          --output <path>                    JSON 结果，默认 video-replay-result.json
          --allowed-cards <ranges>           例如 0-51 或 0-51,53-54
          --min-cards <n>                    短结果阈值，默认 10
          --add-card-mode 0|1|2              与正式配置一致，默认 1
          --flush-frames <n>                 结尾追加的黑帧数，默认 16
          --skip-frames <n>                  诊断：解码但不处理前 n 帧
          --max-frames <n>                   诊断：最多处理 n 个视频帧
          --single-roi-area-factor <n>       横洗单框 ROI 面积倍数，默认 90
          --force-single-entry left|right    诊断：入口只保留指定侧单框，进入 ROI 后恢复正常
          --frames-output <directory>        保存逐帧标注；重跑前自动删除该目录的旧工具输出
          --trace                            输出逐帧状态摘要
        """
    }

    private static func resolve(path: String, relativeTo base: URL) -> URL {
        if path.hasPrefix("/") {
            return URL(fileURLWithPath: path).standardizedFileURL
        }
        return base.appendingPathComponent(path).standardizedFileURL
    }

    private static func findDefaultModelsDirectory(startingAt directory: URL) -> URL {
        var cursor = directory.standardizedFileURL
        for _ in 0..<8 {
            let candidate = cursor.appendingPathComponent("lifeCatcher/Resources", isDirectory: true)
            if FileManager.default.fileExists(atPath: candidate.path) {
                return candidate
            }
            let parent = cursor.deletingLastPathComponent()
            if parent.path == cursor.path { break }
            cursor = parent
        }
        return directory.appendingPathComponent("lifeCatcher/Resources", isDirectory: true)
    }

    private static func parseAllowedCards(_ value: String) throws -> [Int] {
        var cards = Set<Int>()
        for component in value.split(separator: ",") {
            let parts = component.split(separator: "-", omittingEmptySubsequences: false)
            if parts.count == 1, let card = Int(parts[0]), (0...54).contains(card), card != 52 {
                cards.insert(card)
            } else if parts.count == 2,
                      let lower = Int(parts[0]),
                      let upper = Int(parts[1]),
                      lower <= upper,
                      lower >= 0,
                      upper <= 54 {
                for card in lower...upper where card != 52 {
                    cards.insert(card)
                }
            } else {
                throw ReplayError.invalidArguments("非法牌范围：\(component)")
            }
        }
        guard !cards.isEmpty else {
            throw ReplayError.invalidArguments("--allowed-cards 不能为空")
        }
        return cards.sorted()
    }
}

enum ReplayError: Error, CustomStringConvertible {
    case invalidArguments(String)
    case video(String)
    case model(String)
    case image(String)

    var description: String {
        switch self {
        case .invalidArguments(let message), .video(let message), .model(let message), .image(let message):
            return message
        }
    }
}
