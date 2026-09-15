import CoreML
import CoreVideo
import Foundation

final class RecognitionEngine {
    let modelRunner: ModelRunner
    let logicalFPS: Int
    let trace: Bool

    let shuffleMode: [Int]
    /// Physical pile layout, classifier choice and ROI deformation direction.
    let isCameraHorizon: Bool
    let allSingleFeatureIndex: [Int]
    let minSingleFeatureNum: Int
    let addCardMode: Int
    let singleROIAreaFactor: Float
    let forcedSingleEntrySide: CLIOptions.ForcedSingleEntrySide?
    let singlefeatureLabelDic = CardLabels.values

    let originSize: [Float] = [1920, 1080]
    let imageSize: [Float] = [569, 320]
    let inputSize = CGSize(width: 320, height: 320)
    let detectSize = CGSize(width: 640, height: 640)

    private(set) var state = "idle"
    private(set) var transitions: [StateTransition] = []
    private(set) var sessions: [RecognitionSession] = []

    var taskIndex = 0
    var stateCounter = 0
    var shuffleStartCounter = 0
    var shuffleResetCounter = 0
    var stateSingleFeature = [-1, -1]
    var centerPos: [Float] = [0.5, 0.5]
    var lastBoxes: [[Float]] = [[0.02, 0.02, 0.01, 0.01], [0.98, 0.98, 0.02, 0.02]]
    var targetArea: [Float] = [0, 0, 0, 0]
    var initTargetArea: [Float] = [0, 0, 0, 0]
    var isTargetArea = false
    var isDetect = false
    var activeTargetAreaScenario: TargetAreaScenario = .standard
    var detectSet = Set<Int>()
    // Offline replay starts from an empty deck and never enters the post-result cut-card path.
    var detectNeedToCut = false
    var detectResultList: [Int: [DetectionResult]] = [:]
    var laplacianDic: [[Int: Float]] = [[:], [:]]
    var reloadingFramesRemaining = 0

    init(
        modelRunner: ModelRunner,
        logicalFPS: Int,
        mode: ReplayMode,
        orientation: CameraOrientation,
        allowedCards: [Int],
        minimumCards: Int,
        addCardMode: Int,
        trace: Bool,
        singleROIAreaFactor: Float = 90,
        forcedSingleEntrySide: CLIOptions.ForcedSingleEntrySide? = nil
    ) {
        self.modelRunner = modelRunner
        self.logicalFPS = logicalFPS
        self.shuffleMode = mode.shuffleMode
        self.isCameraHorizon = orientation.isHorizontal
        self.allSingleFeatureIndex = allowedCards
        self.minSingleFeatureNum = minimumCards
        self.addCardMode = addCardMode
        self.trace = trace
        self.singleROIAreaFactor = singleROIAreaFactor
        self.forcedSingleEntrySide = forcedSingleEntrySide
        for card in allowedCards {
            self.laplacianDic[0][card] = 0
            self.laplacianDic[1][card] = 0
        }
    }

    @discardableResult
    func process(cameraFrame: CVPixelBuffer, logicalFrame: Int) throws -> FrameInference {
        let stateBefore = state
        if state == "reloading" {
            reloadingFramesRemaining -= 1
            if reloadingFramesRemaining <= 0 {
                transition(to: "idle", logicalFrame: logicalFrame)
            }
        }

        if state != "idle" {
            taskIndex += 1
        } else {
            taskIndex = -1
        }
        let frameTaskIndex = taskIndex
        let frameUsesTargetArea = isTargetArea
        let frameTargetArea = targetArea
        let modelBuffer = try ImagePipeline.modelInput(
            cameraFrame: cameraFrame,
            targetSize: frameUsesTargetArea ? inputSize : detectSize,
            targetArea: frameTargetArea
        )
        let output = try modelRunner.predict(pixelBuffer: modelBuffer, isTargetArea: frameUsesTargetArea)
        var (detections, uniqueCount) = getSingleFeature(
            from: output.confidence,
            from: output.coordinates,
            from: modelBuffer,
            from: frameUsesTargetArea
        )
        if !frameUsesTargetArea, state == "idle", let forcedSingleEntrySide {
            let validIndices = detections.indices.filter { detections[$0].singlefeatureIndex[0] != -1 }
            if validIndices.count == 2 {
                let selectedIndex = forcedSingleEntrySide == .left ? validIndices[0] : validIndices[1]
                let selected = detections[selectedIndex]
                detections = [
                    selected,
                    DetectionResult(
                        singlefeatureIndex: [-1],
                        confidence: [0.001],
                        confidencePercent: 0,
                        coordinate: selected.coordinate,
                        laplacianVariance: 0
                    )
                ]
                uniqueCount = 1
            }
        }
        let frameROI: [Float] = frameUsesTargetArea ? frameTargetArea : [0.5, 0.5, 1, 1]
        let frameDetections = detections.compactMap { detection -> FrameDetection? in
            guard let classIndex = detection.singlefeatureIndex.first,
                  classIndex != -1,
                  let confidence = detection.confidence.first else {
                return nil
            }
            let label = frameUsesTargetArea
                ? (CardDisplayLabels.values[classIndex] ?? "class-\(classIndex)")
                : (classIndex == 0 ? "target" : "target-\(classIndex)")
            return FrameDetection(
                classIndex: classIndex,
                label: label,
                confidence: confidence,
                cameraBox: Self.cameraBox(from: detection.coordinate, roi: frameROI)
            )
        }
        reduce(
            detections: detections,
            uniqueCount: uniqueCount,
            taskIndex: frameTaskIndex,
            frameUsesTargetArea: frameUsesTargetArea,
            frameTargetArea: frameTargetArea,
            logicalFrame: logicalFrame
        )

        if trace {
            let cards = detections.map { $0.singlefeatureIndex[0] }
            let confidences = detections.map { String(format: "%.3f", $0.confidence[0]) }
            print("frame=\(logicalFrame) t=\(String(format: "%.6f", Double(logicalFrame) / Double(logicalFPS))) state=\(state) roi=\(isTargetArea) cards=\(cards) confidence=\(confidences)")
        }
        return FrameInference(
            logicalFrame: logicalFrame,
            logicalFPS: logicalFPS,
            stage: frameUsesTargetArea ? .cls : .detect,
            stateBefore: stateBefore,
            stateAfter: state,
            cameraROI: frameROI,
            detections: frameDetections
        )
    }

    private static func cameraBox(from modelBox: [Float], roi: [Float]) -> [Float] {
        guard modelBox.count == 4, roi.count == 4 else { return modelBox }
        return [
            roi[0] - roi[2] / 2 + modelBox[0] * roi[2],
            roi[1] - roi[3] / 2 + modelBox[1] * roi[3],
            modelBox[2] * roi[2],
            modelBox[3] * roi[3]
        ]
    }

    // Internal for deterministic state-machine regression using recorded detections.
    func reduce(
        detections: [DetectionResult],
        uniqueCount: Int,
        taskIndex: Int,
        frameUsesTargetArea: Bool,
        frameTargetArea: [Float],
        logicalFrame: Int
    ) {
        let detectionConfidenceThreshold: Float = 0.8
        let detectionConfidenceMinimum: Float = 0.5
        let classificationPresenceThreshold: Float = 0.3

        if state == "idle" {
            if detections[0].singlefeatureIndex[0] == stateSingleFeature[0]
                && detections[1].singlefeatureIndex[0] == stateSingleFeature[1] {
                stateCounter += 1
            } else {
                stateCounter = 0
            }
        }

        stateSingleFeature[0] = detections[0].singlefeatureIndex[0]
        stateSingleFeature[1] = detections[1].singlefeatureIndex[0]

        if detections[0].singlefeatureIndex[0] != -1 && detections[1].singlefeatureIndex[0] != -1 {
            centerPos = [
                (detections[0].coordinate[0] + detections[1].coordinate[0]) / 2,
                (detections[0].coordinate[1] + detections[1].coordinate[1]) / 2
            ]
        }
        lastBoxes = [detections[0].coordinate, detections[1].coordinate]

        let detectCount = detections.reduce(0) { count, detection in
            count + (detection.singlefeatureIndex[0] == -1 ? 0 : 1)
        }

        if state == "reloading" {
            return
        }

        if state == "idle" && !isTargetArea && !frameUsesTargetArea {
            let canEnter = (detectCount == 1 && (shuffleMode[1] != 0 || shuffleMode[0] == 2))
                || (detectCount == 2 && shuffleMode[0] != 0)
            if canEnter && stateCounter >= 1 {
                stateCounter = 0
                var boxes: [[Float]] = []
                if detections[0].singlefeatureIndex[0] != -1 { boxes.append(detections[0].coordinate) }
                if detections[1].singlefeatureIndex[0] != -1 { boxes.append(detections[1].coordinate) }
                activeTargetAreaScenario = resolveTargetAreaScenario(boxCount: boxes.count)
                targetArea = computeTargetArea(
                    stateResult: boxes,
                    scenario: activeTargetAreaScenario
                )
                if targetArea[2] > 0 && targetArea[3] > 0 {
                    isTargetArea = true
                    if detectCount == 2 && shuffleMode[0] != 0 && !judgeCutRange(stateResult: boxes) {
                        initTargetArea = targetArea
                    }
                    transition(to: "detecting", logicalFrame: logicalFrame)
                } else {
                    activeTargetAreaScenario = .standard
                }
            }
            return
        }

        if frameUsesTargetArea && isTargetArea {
            reduceTargetAreaFrame(
                detections: detections,
                uniqueCount: uniqueCount,
                taskIndex: taskIndex,
                frameTargetArea: frameTargetArea,
                detectCount: detectCount,
                detectionConfidenceThreshold: detectionConfidenceThreshold,
                detectionConfidenceMinimum: detectionConfidenceMinimum,
                classificationPresenceThreshold: classificationPresenceThreshold,
                logicalFrame: logicalFrame
            )
            return
        }

        if !isTargetArea && !frameUsesTargetArea {
            reduceFullFrameAfterDetection(
                detections: detections,
                detectCount: detectCount,
                logicalFrame: logicalFrame
            )
        }
    }

    private func reduceTargetAreaFrame(
        detections: [DetectionResult],
        uniqueCount: Int,
        taskIndex: Int,
        frameTargetArea: [Float],
        detectCount: Int,
        detectionConfidenceThreshold: Float,
        detectionConfidenceMinimum: Float,
        classificationPresenceThreshold: Float,
        logicalFrame: Int
    ) {
        var leftCard = -1
        var leftConfidence: Float = -1
        var rightCard = -1
        var rightConfidence: Float = -1
        var detectedCard = -1
        var detectedConfidence: Float = -1
        var minimumConfidence: Float = -1

        let isSame = detections[0].singlefeatureIndex[0] != -1
            && detections[0].singlefeatureIndex[0] == detections[1].singlefeatureIndex[0]
        if detections[0].singlefeatureIndex[0] != -1 {
            leftCard = detections[0].singlefeatureIndex[0]
            leftConfidence = detections[0].confidence[0]
        }
        if detections[1].singlefeatureIndex[0] != -1 {
            rightCard = detections[1].singlefeatureIndex[0]
            rightConfidence = detections[1].confidence[0]
        }
        if leftConfidence > rightConfidence {
            detectedConfidence = leftConfidence
            detectedCard = leftCard
            minimumConfidence = rightConfidence
        } else if leftConfidence < rightConfidence {
            detectedConfidence = rightConfidence
            detectedCard = rightCard
            minimumConfidence = leftConfidence
        }
        _ = detectedCard

        if case .horizontalShuffle = activeTargetAreaScenario,
            state == "detecting" {
            if detectCount == 0 || detectedConfidence < classificationPresenceThreshold {
                stateCounter += 1
            } else {
                stateCounter = 0
            }
        } else if shuffleMode[0] != 0
            && shuffleMode[1] == 0
            && (detectCount < 2 || minimumConfidence < classificationPresenceThreshold)
            && state == "detecting" {
            stateCounter += 1
        } else if shuffleMode[1] != 0
                    && (detectCount < 1 || detectedConfidence < classificationPresenceThreshold)
                    && state == "detecting" {
            stateCounter += 1
        } else if state != "detecting"
                    && (detectCount == 0 || detectedConfidence < classificationPresenceThreshold) {
            stateCounter += 1
        } else {
            stateCounter = 0
        }

        var boxes: [[Float]] = []
        if detections[0].singlefeatureIndex[0] != -1 { boxes.append(detections[0].coordinate) }
        if detections[1].singlefeatureIndex[0] != -1 { boxes.append(detections[1].coordinate) }
        let nextTargetArea = updateTargetArea(
            coordinates: boxes,
            targetArea: frameTargetArea
        )
        guard nextTargetArea[2] > 0, nextTargetArea[3] > 0 else {
            targetArea = [0, 0, 0, 0]
            isTargetArea = false
            activeTargetAreaScenario = .standard
            return
        }
        targetArea = nextTargetArea

        let isShuffle = detectCount == 2 && shuffleMode[0] != 0 && !isSame
        let isRiffle = detectCount == 1 && shuffleMode[1] != 0

        if !isDetect && detectedConfidence >= detectionConfidenceMinimum && isRiffle && uniqueCount == 1 {
            isDetect = true
            transition(to: "riffle", logicalFrame: logicalFrame)
        } else if !isDetect && minimumConfidence >= detectionConfidenceMinimum && isShuffle {
            if leftCard == stateSingleFeature[0]
                && rightCard == stateSingleFeature[1]
                && uniqueCount == 2
                && shufflePostureJudge(
                    coordinates: [detections[0].coordinate, detections[1].coordinate],
                    coordinateTargetArea: frameTargetArea
                ) {
                shuffleStartCounter += 1
            } else {
                shuffleStartCounter = 0
            }
            if shuffleStartCounter >= 3 {
                isDetect = true
                if shuffleMode[0] == 2 {
                    activeTargetAreaScenario = .horizontalShuffle
                }
                transition(to: "shuffle", logicalFrame: logicalFrame)
                initTargetArea = frameTargetArea
            }
        }

        if isDetect && state == "shuffle" && targetAreaMove(initTargetArea: initTargetArea, targetArea: frameTargetArea) && detectSet.count < 5 {
            shuffleResetCounter += 1
        } else if isDetect && state == "shuffle" && (detectCount != 2 || minimumConfidence < classificationPresenceThreshold) && detectSet.count < 5 {
            shuffleResetCounter += 1
        } else if isDetect && state == "shuffle" {
            shuffleResetCounter = 0
        }

        if stateCounter >= 5 {
            isTargetArea = false
            targetArea = [0, 0, 0, 0]
            stateCounter = 0
        } else if shuffleResetCounter > 5 {
            initDetectionResult()
        } else if taskIndex >= 0 && isDetect {
            if minimumConfidence >= detectionConfidenceThreshold
                && isShuffle
                && state == "riffle"
                && leftCard == stateSingleFeature[0]
                && rightCard == stateSingleFeature[1] {
                if shuffleMode[0] == 2 {
                    activeTargetAreaScenario = .horizontalShuffle
                }
                transition(to: "shuffle", logicalFrame: logicalFrame)
            }

            if (state == "riffle" && leftConfidence > 0.7 && detectCount == 1)
                || (state == "shuffle" && leftConfidence > 0.5) {
                detectSet.insert(leftCard)
            }
            if (state == "riffle" && rightConfidence > 0.7 && detectCount == 1)
                || (state == "shuffle" && rightConfidence > 0.5) {
                detectSet.insert(rightCard)
            }
            if detectSet.count >= 5 { initTargetArea = targetArea }
            detectResultList[taskIndex] = detections

            var detectedBoxes: [[Float]] = []
            if state == "shuffle" && leftCard != -1 && rightCard != -1 {
                detectedBoxes = [detections[0].coordinate, detections[1].coordinate]
                let nextTargetArea = updateTargetArea(
                    coordinates: detectedBoxes,
                    targetArea: frameTargetArea
                )
                guard nextTargetArea[2] > 0, nextTargetArea[3] > 0 else {
                    targetArea = [0, 0, 0, 0]
                    isTargetArea = false
                    activeTargetAreaScenario = .standard
                    return
                }
                targetArea = nextTargetArea
            } else if state == "riffle" && detectedConfidence >= detectionConfidenceMinimum {
                if leftCard != -1 { detectedBoxes.append(detections[0].coordinate) }
                if rightCard != -1 { detectedBoxes.append(detections[1].coordinate) }
                let nextTargetArea = updateTargetArea(
                    coordinates: detectedBoxes,
                    targetArea: frameTargetArea
                )
                guard nextTargetArea[2] > 0, nextTargetArea[3] > 0 else {
                    targetArea = [0, 0, 0, 0]
                    isTargetArea = false
                    activeTargetAreaScenario = .standard
                    return
                }
                targetArea = nextTargetArea
            }
        }
    }

    private func reduceFullFrameAfterDetection(
        detections: [DetectionResult],
        detectCount: Int,
        logicalFrame: Int
    ) {
        if stateCounter >= 5 {
            let result = handleDetecResultList(targetDetecResultList: detectResultList)
            let kind = result.isSingle ? "riffle" : "shuffle"
            let accepted = !result.isShort
                && ((result.isSingle && shuffleMode[1] != 0) || (!result.isSingle && shuffleMode[0] != 0))
            sessions.append(
                RecognitionSession(
                    endingLogicalFrame: logicalFrame,
                    kind: kind,
                    acceptedByConfiguredMode: accepted,
                    isSingle: result.isSingle,
                    isShort: result.isShort,
                    longestIndex: result.longestIndex,
                    cards: result.detectionResult,
                    cardLabels: result.detectionResult.map { CardLabels.values[$0] ?? "unknown-\($0)" }
                )
            )
            quitDetection(logicalFrame: logicalFrame)
        } else if ((detectCount == 1 && (shuffleMode[1] != 0 || shuffleMode[0] == 2))
                    || (detectCount == 2 && shuffleMode[0] != 0))
                    && state != "waitingEnd" {
            var boxes: [[Float]] = []
            if detections[0].singlefeatureIndex[0] != -1 { boxes.append(detections[0].coordinate) }
            if detections[1].singlefeatureIndex[0] != -1 { boxes.append(detections[1].coordinate) }
            activeTargetAreaScenario = resolveTargetAreaScenario(boxCount: boxes.count)
            targetArea = computeTargetArea(
                stateResult: boxes,
                scenario: activeTargetAreaScenario
            )
            guard targetArea[2] > 0, targetArea[3] > 0 else {
                activeTargetAreaScenario = .standard
                return
            }
            isTargetArea = true
            if detectCount == 2 && shuffleMode[0] != 0
                && targetAreaMove(initTargetArea: initTargetArea, targetArea: targetArea)
                && !judgeCutRange(stateResult: boxes) {
                initTargetArea = targetArea
            }
            initDetectionResult()
            transition(to: "detecting", logicalFrame: logicalFrame)
        } else {
            if detectCount == 0 { stateCounter += 1 } else { stateCounter = 0 }
        }
    }

    private func quitDetection(logicalFrame: Int) {
        stateCounter = 0
        initBoxes()
        initDetectionResult()
        reloadingFramesRemaining = max(1, Int(ceil(0.2 * Double(logicalFPS))))
        transition(to: "reloading", logicalFrame: logicalFrame)
    }

    private func initDetectionResult() {
        detectResultList.removeAll()
        stateCounter = 0
        shuffleStartCounter = 0
        shuffleResetCounter = 0
        isDetect = false
        detectSet.removeAll()
    }

    private func initBoxes() {
        centerPos = [0.5, 0.5]
        lastBoxes = [[0.02, 0.02, 0.01, 0.01], [0.98, 0.98, 0.02, 0.02]]
        targetArea = [0, 0, 0, 0]
        initTargetArea = [0, 0, 0, 0]
        activeTargetAreaScenario = .standard
        isTargetArea = false
    }

    private func transition(to newState: String, logicalFrame: Int) {
        guard state != newState else { return }
        transitions.append(
            StateTransition(
                logicalFrame: logicalFrame,
                logicalTimeSeconds: Double(logicalFrame) / Double(logicalFPS),
                from: state,
                to: newState
            )
        )
        state = newState
    }
}
