import Foundation

enum ReplayMode: String, Codable {
    case shuffle
    case horizontalShuffle = "horizontal-shuffle"
    case riffle
    case both

    var shuffleMode: [Int] {
        switch self {
        case .shuffle: return [1, 0]
        case .horizontalShuffle: return [2, 0]
        case .riffle: return [0, 1]
        case .both: return [1, 1]
        }
    }

    var usesShuffleModels: Bool { shuffleMode[0] != 0 }
}

enum CameraOrientation: String, Codable {
    case horizontal
    case vertical

    var isHorizontal: Bool { self == .horizontal }
}

enum FrameRotation: String, Codable {
    case auto
    case none
    case clockwise
    case counterclockwise
}

enum InferenceStage: String, Codable {
    case detect
    case cls
}

struct FrameDetection: Codable {
    let classIndex: Int
    let label: String
    let confidence: Float
    /// Normalized top-left coordinates in the normalized camera frame.
    let cameraBox: [Float]
}

struct FrameInference {
    let logicalFrame: Int
    let logicalFPS: Int
    let stage: InferenceStage
    let stateBefore: String
    let stateAfter: String
    /// Normalized top-left coordinates in the normalized camera frame.
    let cameraROI: [Float]
    let detections: [FrameDetection]
}

final class DetectionResult {
    var singlefeatureIndex: [Int]
    var confidence: [Float]
    var confidencePercent: Float
    var coordinate: [Float]
    var nodeType: Int
    var laplacianVariance: Float

    init(
        singlefeatureIndex: [Int],
        confidence: [Float],
        confidencePercent: Float,
        coordinate: [Float],
        laplacianVariance: Float
    ) {
        self.singlefeatureIndex = singlefeatureIndex
        self.confidence = confidence
        self.confidencePercent = confidencePercent
        self.coordinate = coordinate
        self.nodeType = 0
        self.laplacianVariance = laplacianVariance
    }

    func targetDistance(target: [Float]) -> Float {
        let dx = coordinate[0] - target[0]
        let dy = coordinate[1] - target[1]
        return dx * dx + dy * dy
    }
}

final class DetectionState {
    var detectionResult: [Int]
    var isSingle: Bool
    var isShort: Bool
    var longestIndex: Int

    init(detectionResult: [Int], isSingle: Bool, isShort: Bool, longestIndex: Int) {
        self.detectionResult = detectionResult
        self.isSingle = isSingle
        self.isShort = isShort
        self.longestIndex = longestIndex
    }
}

final class InsertCard {
    var cardIndex: Int
    var confidence: Float

    init(cardIndex: Int, confidence: Float) {
        self.cardIndex = cardIndex
        self.confidence = confidence
    }
}

struct StateTransition: Codable {
    let logicalFrame: Int
    let logicalTimeSeconds: Double
    let from: String
    let to: String
}

struct RecognitionSession: Codable {
    let endingLogicalFrame: Int
    let kind: String
    let acceptedByConfiguredMode: Bool
    let isSingle: Bool
    let isShort: Bool
    let longestIndex: Int
    let cards: [Int]
    let cardLabels: [String]
}

struct ReplayReport: Codable {
    struct Video: Codable {
        let path: String
        let decodedFrameCount: Int
        let processedFrameCount: Int
        let width: Int
        let height: Int
        let sourceNominalFPS: Float
        let sourceDurationSeconds: Double
    }

    struct Configuration: Codable {
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
        let forcedSingleEntrySide: String?
        let annotatedFramesDirectory: String?
    }

    let video: Video
    let configuration: Configuration
    let logicalDurationSeconds: Double
    let stateTransitions: [StateTransition]
    let sessions: [RecognitionSession]
    let finalState: String
}

enum CardLabels {
    static let values: [Int: String] = {
        let suits = ["S", "H", "C", "D"]
        let ranks = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
        var result: [Int: String] = [:]
        for suit in 0..<4 {
            for rank in 0..<13 {
                result[suit * 13 + rank] = suits[suit] + ranks[rank]
            }
        }
        result[52] = "none"
        result[53] = "small-joker"
        result[54] = "big-joker"
        result[-1] = "none"
        return result
    }()
}

enum CardDisplayLabels {
    static let values: [Int: String] = {
        let suits = ["♠️", "♥️", "♣️", "♦️"]
        let ranks = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
        var result: [Int: String] = [:]
        for suit in 0..<4 {
            for rank in 0..<13 {
                result[suit * 13 + rank] = suits[suit] + ranks[rank]
            }
        }
        result[52] = "none"
        result[53] = "小王"
        result[54] = "大王"
        result[-1] = "none"
        return result
    }()
}
