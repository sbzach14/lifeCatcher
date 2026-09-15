import CoreVideo
import XCTest
@testable import LifeCatcherVideoReplay

final class HorizontalShuffleStateTests: XCTestCase {
    private static let runner: Result<ModelRunner, Error> = Result {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        return try ModelRunner(modelsDirectory: root.appendingPathComponent("lifeCatcher/Resources"),
                               mode: .horizontalShuffle, orientation: .horizontal)
    }

    private func engine() throws -> RecognitionEngine {
        try RecognitionEngine(modelRunner: Self.runner.get(), logicalFPS: 120,
                              mode: .horizontalShuffle, orientation: .horizontal,
                              allowedCards: Array(0...51), minimumCards: 10, addCardMode: 0, trace: false)
    }

    private func send(_ boxes: [[Float]], cards: [Int], to engine: RecognitionEngine) {
        let roi = engine.isTargetArea ? engine.targetArea : [0.5, 0.5, 1, 1]
        var detections = zip(boxes, cards).enumerated().map { index, item in
            DetectionResult(singlefeatureIndex: [item.1], confidence: [index == 0 ? 0.95 : 0.9],
                confidencePercent: 1,
                coordinate: [(item.0[0] - roi[0]) / roi[2] + 0.5,
                             (item.0[1] - roi[1]) / roi[3] + 0.5,
                             item.0[2] / roi[2], item.0[3] / roi[3]], laplacianVariance: 100)
        }
        while detections.count < 2 {
            detections.append(DetectionResult(singlefeatureIndex: [-1], confidence: [0],
                confidencePercent: 0, coordinate: [0, 0, 0, 0], laplacianVariance: 0))
        }
        engine.reduce(detections: detections, uniqueCount: cards.count, taskIndex: 1,
                      frameUsesTargetArea: engine.isTargetArea, frameTargetArea: engine.targetArea,
                      logicalFrame: 1)
    }

    func testSingleEntryPairAcquisitionOcclusionRecoveryAndExit() throws {
        let engine = try engine()
        let left: [Float] = [0.4, 0.5, 0.02, 0.05]
        let right: [Float] = [0.6, 0.5, 0.02, 0.05]
        send([left], cards: [1], to: engine)
        send([left], cards: [1], to: engine)
        XCTAssertEqual(engine.state, "detecting")
        let singleROI = engine.targetArea
        XCTAssertEqual(singleROI[2] * singleROI[3], 0.02 * 0.05 * 90, accuracy: 0.000001)
        send([[0.41, 0.5, 0.01, 0.03]], cards: [1], to: engine)
        XCTAssertEqual(engine.targetArea, singleROI)
        for _ in 0..<3 { send([left, right], cards: [1, 2], to: engine) }
        XCTAssertEqual(engine.state, "shuffle")
        XCTAssertEqual(engine.targetArea[2], 0.33, accuracy: 0.000001)
        engine.detectSet = Set(1...6) // Existing mature-shuffle branch.
        let pairROI = engine.targetArea
        for _ in 0..<8 { send([left], cards: [1], to: engine) }
        XCTAssertEqual(engine.state, "shuffle")
        XCTAssertEqual(engine.targetArea, pairROI)
        // Even an older concurrent frame must not roll the held crop back.
        XCTAssertEqual(engine.updateTargetArea(coordinates: [[0.5, 0.5, 0.01, 0.01]],
                                               targetArea: singleROI), pairROI)
        send([left, [0.65, 0.5, 0.02, 0.05]], cards: [1, 3], to: engine)
        XCTAssertEqual(engine.targetArea[2], 0.405, accuracy: 0.000001)
        let recoveredROI = engine.targetArea
        for _ in 0..<4 { send([], cards: [], to: engine) }
        XCTAssertTrue(engine.isTargetArea)
        XCTAssertEqual(engine.targetArea, recoveredROI)
        send([], cards: [], to: engine)
        XCTAssertFalse(engine.isTargetArea)
    }

    func testEarlyShuffleMissingPileStillUsesExistingResetCounter() throws {
        let engine = try engine()
        let pair: [[Float]] = [[0.4, 0.5, 0.02, 0.05], [0.6, 0.5, 0.02, 0.05]]
        for _ in 0..<5 { send(pair, cards: [1, 2], to: engine) }
        XCTAssertEqual(engine.state, "shuffle")
        let roi = engine.targetArea
        for _ in 0..<5 { send([pair[0]], cards: [1], to: engine) }
        XCTAssertEqual(engine.targetArea, roi)
        XCTAssertTrue(engine.isDetect)
        send([pair[0]], cards: [1], to: engine)
        XCTAssertFalse(engine.isDetect)
        XCTAssertEqual(engine.targetArea, roi)
    }

    func testNativeModelsLoadAndAcceptBothInputSizes() throws {
        let runner = try Self.runner.get()
        for classification in [false, true] {
            let side = classification ? 320 : 640
            var buffer: CVPixelBuffer?
            XCTAssertEqual(CVPixelBufferCreate(kCFAllocatorDefault, side, side,
                kCVPixelFormatType_32BGRA, nil, &buffer), kCVReturnSuccess)
            let input = try XCTUnwrap(buffer)
            CVPixelBufferLockBaseAddress(input, [])
            memset(CVPixelBufferGetBaseAddress(input), 114, CVPixelBufferGetDataSize(input))
            CVPixelBufferUnlockBaseAddress(input, [])
            let result = try runner.predict(pixelBuffer: input, isTargetArea: classification)
            XCTAssertEqual(result.coordinates.shape.last?.intValue, 4)
            if classification { XCTAssertEqual(result.confidence.shape.last?.intValue, 52) }
        }
    }
}
