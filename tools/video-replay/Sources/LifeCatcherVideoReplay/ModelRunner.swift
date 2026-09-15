import CoreML
import CoreVideo
import Foundation

final class DetectionInput: MLFeatureProvider {
    let image: CVPixelBuffer
    let iouThreshold: Double
    let confidenceThreshold: Double

    var featureNames: Set<String> { ["image", "iouThreshold", "confidenceThreshold"] }

    init(image: CVPixelBuffer, iouThreshold: Double, confidenceThreshold: Double) {
        self.image = image
        self.iouThreshold = iouThreshold
        self.confidenceThreshold = confidenceThreshold
    }

    func featureValue(for featureName: String) -> MLFeatureValue? {
        switch featureName {
        case "image": return MLFeatureValue(pixelBuffer: image)
        case "iouThreshold": return MLFeatureValue(double: iouThreshold)
        case "confidenceThreshold": return MLFeatureValue(double: confidenceThreshold)
        default: return nil
        }
    }
}

struct ModelOutput {
    let confidence: MLMultiArray
    let coordinates: MLMultiArray
}

final class ModelRunner {
    private let detector: MLModel
    private let classifier: MLModel

    init(modelsDirectory: URL, mode: ReplayMode, orientation: CameraOrientation) throws {
        let detectorName = Self.detectorName(mode: mode)
        let classifierName = Self.classifierName(mode: mode, orientation: orientation)
        detector = try Self.loadModel(named: detectorName, from: modelsDirectory)
        classifier = try Self.loadModel(named: classifierName, from: modelsDirectory)
    }

    static func detectorName(mode: ReplayMode) -> String {
        if mode == .horizontalShuffle {
            return "detect_20260915_texas"
        }
        return mode.usesShuffleModels ? "detect_0903" : "riffle_detect_1111"
    }

    static func classifierName(mode: ReplayMode, orientation: CameraOrientation) -> String {
        if mode == .horizontalShuffle {
            return "cls_20260915_texas"
        }
        if mode.usesShuffleModels {
            return orientation.isHorizontal ? "cls_1215_h" : "cls_1215_v"
        } else {
            return orientation.isHorizontal ? "riffle_cls_h_1107" : "riffle_cls_v_1107"
        }
    }

    func predict(pixelBuffer: CVPixelBuffer, isTargetArea: Bool) throws -> ModelOutput {
        let confidenceThreshold = isTargetArea ? 0.05 : 0.7
        let input = DetectionInput(
            image: pixelBuffer,
            iouThreshold: 0.2,
            confidenceThreshold: confidenceThreshold
        )
        let output = try (isTargetArea ? classifier : detector).prediction(from: input)
        guard let confidence = output.featureValue(for: "confidence")?.multiArrayValue,
              let coordinates = output.featureValue(for: "coordinates")?.multiArrayValue else {
            throw ReplayError.model("模型输出缺少 confidence 或 coordinates")
        }
        return ModelOutput(confidence: confidence, coordinates: coordinates)
    }

    private static func loadModel(named name: String, from directory: URL) throws -> MLModel {
        let sourceURL = directory.appendingPathComponent(name).appendingPathExtension("mlmodel")
        guard FileManager.default.fileExists(atPath: sourceURL.path) else {
            throw ReplayError.model("缺少模型：\(sourceURL.path)")
        }
        do {
            let compiledURL = try MLModel.compileModel(at: sourceURL)
            let configuration = MLModelConfiguration()
            configuration.computeUnits = .all
            return try MLModel(contentsOf: compiledURL, configuration: configuration)
        } catch {
            throw ReplayError.model("模型 \(name) 编译或加载失败：\(error.localizedDescription)")
        }
    }
}
