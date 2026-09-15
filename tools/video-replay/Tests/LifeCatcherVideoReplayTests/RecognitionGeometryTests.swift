import XCTest
@testable import LifeCatcherVideoReplay

final class RecognitionGeometryTests: XCTestCase {
    func testSingleAreaAndOrientation() {
        for horizontal in [true, false] {
            let roi = HorizontalShuffleROIGeometry.compute(
                stateResult: [[0.5, 0.5, 0.02, 0.05]], isCameraHorizon: horizontal)
            let width = roi[2] * 1920
            let height = roi[3] * 1080
            XCTAssertEqual(width * height, 38.4 * 54 * 90, accuracy: 0.1)
            XCTAssertEqual(width / height, horizontal ? 16.0 / 9 : 9.0 / 16, accuracy: 0.00001)
        }
    }

    func testSingleAreaCanBeOverriddenToNinetyForReplayComparison() {
        let roi = HorizontalShuffleROIGeometry.compute(
            stateResult: [[0.5, 0.5, 0.02, 0.05]],
            isCameraHorizon: true,
            areaFactor: 90
        )
        let width = roi[2] * 1920
        let height = roi[3] * 1080
        XCTAssertEqual(width * height, 38.4 * 54 * 90, accuracy: 0.1)
        XCTAssertEqual(width / height, 16.0 / 9, accuracy: 0.00001)
    }

    func testPairOuterSpanAndCenterMidpointWithUnequalBoxes() {
        // Outer X edges are 270 and 740, centers are 300 and 700.
        // Midpoint is 500, whereas the union bounding box center is 505.
        let boxes: [[Float]] = [[0.3, 0.5, 0.06, 0.04], [0.7, 0.52, 0.08, 0.06]]
        let roi = HorizontalShuffleROIGeometry.compute(
            stateResult: boxes, originSize: [1000, 1000], isCameraHorizon: true)
        XCTAssertEqual(roi[0], 0.5, accuracy: 0.000001)
        XCTAssertEqual(roi[1], 0.51, accuracy: 0.000001)
        XCTAssertEqual(roi[2] * 1000, 705, accuracy: 0.001)
        XCTAssertEqual(roi[3] * 1000, 396.5625, accuracy: 0.001)
        XCTAssertEqual(roi, HorizontalShuffleROIGeometry.compute(
            stateResult: boxes.reversed(), originSize: [1000, 1000], isCameraHorizon: true))
        let swapped = boxes.map { [$0[1], $0[0], $0[3], $0[2]] }
        let portrait = HorizontalShuffleROIGeometry.compute(
            stateResult: swapped, originSize: [1000, 1000], isCameraHorizon: false)
        XCTAssertEqual(portrait, [roi[1], roi[0], roi[3], roi[2]])
    }

    func testBoundaryTranslationDoesNotResizeAndOverflowCanBePadded() {
        let boxes: [[Float]] = [[0.05, 0.5, 0.04, 0.04], [0.4, 0.5, 0.04, 0.04]]
        let roi = HorizontalShuffleROIGeometry.compute(
            stateResult: boxes, originSize: [1000, 1000], isCameraHorizon: true)
        XCTAssertEqual(roi[2], 0.585, accuracy: 0.000001)
        XCTAssertEqual(roi[0] - roi[2] / 2, 0, accuracy: 0.000001)
        let overflow = HorizontalShuffleROIGeometry.compute(
            stateResult: [[0.1, 0.5, 0.05, 0.05], [0.9, 0.5, 0.05, 0.05]],
            originSize: [1000, 1000], isCameraHorizon: true)
        XCTAssertEqual(overflow[2], 1.275, accuracy: 0.000001)
        XCTAssertEqual(overflow[2] / overflow[3], 16.0 / 9, accuracy: 0.000001)
    }

    func testOutOfDistributionPairDoesNotSilentlyEnlargeTrainingROI() {
        let roi = HorizontalShuffleROIGeometry.compute(
            stateResult: [[0.45, 0.2, 0.05, 0.05], [0.55, 0.8, 0.05, 0.05]],
            isCameraHorizon: true)
        XCTAssertEqual(roi, [0, 0, 0, 0])
    }

    func testSingleAndMissingTargetsPreserveSearchAndShuffleCrop() {
        for scenario: TargetAreaScenario in [.horizontalShuffle, .horizontalShuffleCut] {
            for state in ["detecting", "shuffle"] {
                for count in [0, 1] {
                    XCTAssertTrue(HorizontalShuffleROIGeometry.shouldPreserveCurrentROI(
                        scenario: scenario, detectedBoxCount: count, state: state))
                }
                XCTAssertFalse(HorizontalShuffleROIGeometry.shouldPreserveCurrentROI(
                    scenario: scenario, detectedBoxCount: 2, state: state))
            }
        }
        XCTAssertFalse(HorizontalShuffleROIGeometry.shouldPreserveCurrentROI(
            scenario: .standard, detectedBoxCount: 1, state: "shuffle"))
        XCTAssertFalse(HorizontalShuffleROIGeometry.shouldPreserveCurrentROI(
            scenario: .horizontalShuffle, detectedBoxCount: 1, state: "riffle"))
    }

    func testTargetAreaMovementUsesAlongDimensionInBothOrientations() {
        let initial: [Float] = [0.5, 0.5, 0.20, 0.20]
        let widthOnlyChange: [Float] = [0.5, 0.5, 0.40, 0.20]
        let heightOnlyChange: [Float] = [0.5, 0.5, 0.20, 0.40]

        XCTAssertTrue(HorizontalShuffleROIGeometry.hasTargetAreaMoved(
            initial: initial,
            current: widthOnlyChange,
            isCameraHorizon: true
        ))
        XCTAssertFalse(HorizontalShuffleROIGeometry.hasTargetAreaMoved(
            initial: initial,
            current: heightOnlyChange,
            isCameraHorizon: true
        ))
        XCTAssertFalse(HorizontalShuffleROIGeometry.hasTargetAreaMoved(
            initial: initial,
            current: widthOnlyChange,
            isCameraHorizon: false
        ))
        XCTAssertTrue(HorizontalShuffleROIGeometry.hasTargetAreaMoved(
            initial: initial,
            current: heightOnlyChange,
            isCameraHorizon: false
        ))
    }

    func testHorizontalPostureAcceptsObservedMaximumCrossOffsetWithHeadroom() {
        let observedMaximumRatio: Float = 1.3246123
        let halfOffset = observedMaximumRatio * 0.10 / 2
        let boxes: [[Float]] = [
            [0.20, 0.50 - halfOffset, 0.05, 0.10],
            [0.80, 0.50 + halfOffset, 0.05, 0.10],
        ]

        XCTAssertTrue(HorizontalShuffleROIGeometry.postureAccepts(
            coordinates: boxes,
            coordinateTargetArea: [0.5, 0.5, 1, 1],
            isCameraHorizon: true
        ))
    }

    func testHorizontalPostureCrossOffsetLimitHasStrictBoundary() {
        func boxes(crossRatio: Float) -> [[Float]] {
            // 0.125 and the 1.5 boundary are exactly representable in binary,
            // so this test exercises the production strict '<' comparison
            // without a decimal-rounding ambiguity.
            let crossSize: Float = 0.125
            let halfOffset = crossRatio * crossSize / 2
            return [
                [0.20, 0.50 - halfOffset, 0.05, crossSize],
                [0.80, 0.50 + halfOffset, 0.05, crossSize],
            ]
        }

        XCTAssertTrue(HorizontalShuffleROIGeometry.postureAccepts(
            coordinates: boxes(crossRatio: 1.499),
            coordinateTargetArea: [0.5, 0.5, 1, 1],
            isCameraHorizon: true
        ))
        XCTAssertFalse(HorizontalShuffleROIGeometry.postureAccepts(
            coordinates: boxes(crossRatio: HorizontalShuffleROIGeometry.postureCrossOffsetLimit),
            coordinateTargetArea: [0.5, 0.5, 1, 1],
            isCameraHorizon: true
        ))
    }

    func testVerticalPostureUsesTheSameCanonicalCrossOffsetLimit() {
        let observedMaximumRatio: Float = 1.3246123
        let halfOffset = observedMaximumRatio * 0.10 / 2
        let boxes: [[Float]] = [
            [0.50 - halfOffset, 0.20, 0.10, 0.05],
            [0.50 + halfOffset, 0.80, 0.10, 0.05],
        ]

        XCTAssertTrue(HorizontalShuffleROIGeometry.postureAccepts(
            coordinates: boxes,
            coordinateTargetArea: [0.5, 0.5, 1, 1],
            isCameraHorizon: false
        ))
    }

    func testHorizontalPostureStillRejectsPilesWithoutAlongSeparation() {
        let boxes: [[Float]] = [
            [0.45, 0.45, 0.10, 0.10],
            [0.55, 0.55, 0.10, 0.10],
        ]

        XCTAssertFalse(HorizontalShuffleROIGeometry.postureAccepts(
            coordinates: boxes,
            coordinateTargetArea: [0.5, 0.5, 1, 1],
            isCameraHorizon: true
        ))
    }
}
