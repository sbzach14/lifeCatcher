import Foundation

enum TargetAreaScenario {
    case standard
    case horizontalShuffle
    case horizontalShuffleCut
}

struct HorizontalShuffleROIGeometry {
    static let aspect: Float = 16.0 / 9.0
    static let pairSpanFactor: Float = 1.5
    /// 1,631 reviewed 0813/0814 pairs have
    /// cross-centre-offset/mean-cross-box-size <= 1.3247 after axis mapping.
    static let postureCrossOffsetLimit: Float = 1.5

    private struct PixelBox {
        let centerAlong: Float
        let centerCross: Float
        let sizeAlong: Float
        let sizeCross: Float
    }

    static func shouldPreserveCurrentROI(
        scenario: TargetAreaScenario,
        detectedBoxCount: Int,
        state: String
    ) -> Bool {
        switch scenario {
        case .horizontalShuffle, .horizontalShuffleCut:
            return detectedBoxCount == 0 || (detectedBoxCount == 1 && state != "riffle")
        case .standard:
            return false
        }
    }

    static func compute(
        stateResult: [[Float]],
        originSize: [Float] = [1920, 1080],
        isCameraHorizon: Bool,
        areaFactor: Float = 70
    ) -> [Float] {
        let sourceBoxes = Array(stateResult.prefix(2))
        guard !sourceBoxes.isEmpty else {
            return [0, 0, 0, 0]
        }

        let boxes = sourceBoxes.map { box -> PixelBox in
            if isCameraHorizon {
                return PixelBox(
                    centerAlong: box[0] * originSize[0],
                    centerCross: box[1] * originSize[1],
                    sizeAlong: box[2] * originSize[0],
                    sizeCross: box[3] * originSize[1]
                )
            }
            return PixelBox(
                centerAlong: box[1] * originSize[1],
                centerCross: box[0] * originSize[0],
                sizeAlong: box[3] * originSize[1],
                sizeCross: box[2] * originSize[0]
            )
        }

        let centerAlong: Float
        let centerCross: Float
        if boxes.count == 1 {
            centerAlong = boxes[0].centerAlong
            centerCross = boxes[0].centerCross
        } else {
            centerAlong = (boxes[0].centerAlong + boxes[1].centerAlong) / 2
            centerCross = (boxes[0].centerCross + boxes[1].centerCross) / 2
        }

        let alongLength: Float
        if boxes.count == 1 {
            let box = boxes[0]
            alongLength = sqrt(areaFactor * box.sizeAlong * box.sizeCross * aspect)
        } else {
            let minAlong = boxes.map { $0.centerAlong - $0.sizeAlong / 2 }.min()!
            let maxAlong = boxes.map { $0.centerAlong + $0.sizeAlong / 2 }.max()!
            alongLength = (maxAlong - minAlong) * pairSpanFactor
        }
        let crossLength = alongLength / aspect

        guard alongLength > 0, crossLength > 0 else {
            return [0, 0, 0, 0]
        }

        let result = makeArea(
            centerAlong: centerAlong,
            centerCross: centerCross,
            alongLength: alongLength,
            crossLength: crossLength,
            originSize: originSize,
            isCameraHorizon: isCameraHorizon
        )
        if !containsAll(result, boxes: sourceBoxes) {
            return [0, 0, 0, 0]
        }
        return result
    }

    private static func makeArea(
        centerAlong: Float,
        centerCross: Float,
        alongLength: Float,
        crossLength: Float,
        originSize: [Float],
        isCameraHorizon: Bool
    ) -> [Float] {
        let targetWidth = isCameraHorizon ? alongLength : crossLength
        let targetHeight = isCameraHorizon ? crossLength : alongLength
        let centerX = isCameraHorizon ? centerAlong : centerCross
        let centerY = isCameraHorizon ? centerCross : centerAlong
        let originX = fittedOrigin(
            desired: centerX - targetWidth / 2,
            roiSize: targetWidth,
            frameSize: originSize[0]
        )
        let originY = fittedOrigin(
            desired: centerY - targetHeight / 2,
            roiSize: targetHeight,
            frameSize: originSize[1]
        )
        return [
            (originX + targetWidth / 2) / originSize[0],
            (originY + targetHeight / 2) / originSize[1],
            targetWidth / originSize[0],
            targetHeight / originSize[1]
        ]
    }

    private static func fittedOrigin(
        desired: Float,
        roiSize: Float,
        frameSize: Float
    ) -> Float {
        if roiSize <= frameSize {
            return max(0, min(desired, frameSize - roiSize))
        }
        return max(frameSize - roiSize, min(desired, 0))
    }

    private static func containsAll(_ targetArea: [Float], boxes: [[Float]]) -> Bool {
        let epsilon: Float = 0.000_01
        let minX = targetArea[0] - targetArea[2] / 2
        let maxX = targetArea[0] + targetArea[2] / 2
        let minY = targetArea[1] - targetArea[3] / 2
        let maxY = targetArea[1] + targetArea[3] / 2
        return boxes.allSatisfy { box in
            minX <= box[0] - box[2] / 2 + epsilon
                && maxX + epsilon >= box[0] + box[2] / 2
                && minY <= box[1] - box[3] / 2 + epsilon
                && maxY + epsilon >= box[1] + box[3] / 2
        }
    }

    static func hasTargetAreaMoved(
        initial: [Float],
        current: [Float],
        isCameraHorizon: Bool
    ) -> Bool {
        if isCameraHorizon {
            return abs(initial[0] - current[0]) > (initial[2] + current[2]) / 5
                || abs(initial[1] - current[1]) > (initial[3] + current[3]) / 2.5
                || current[2] / initial[2] > 1.5
                || initial[2] / current[2] > 1.5
        }
        return abs(initial[0] - current[0]) > (initial[2] + current[2]) / 2.5
            || abs(initial[1] - current[1]) > (initial[3] + current[3]) / 5
            || current[3] / initial[3] > 1.5
            || initial[3] / current[3] > 1.5
    }

    static func postureAccepts(
        coordinates: [[Float]],
        coordinateTargetArea: [Float],
        originSize: [Float] = [1920, 1080],
        isCameraHorizon: Bool
    ) -> Bool {
        guard coordinates.count == 2, coordinateTargetArea.count == 4 else {
            return false
        }
        let xScale = coordinateTargetArea[2] * originSize[0]
        let yScale = coordinateTargetArea[3] * originSize[1]
        if isCameraHorizon {
            let alongGap = abs(coordinates[0][0] - coordinates[1][0]) * xScale
            let minimumAlongGap = max(
                (coordinates[0][2] + coordinates[1][2]) * xScale * 1.1 / 2,
                coordinates[0][3] * yScale,
                coordinates[1][3] * yScale
            )
            let crossGap = abs(coordinates[0][1] - coordinates[1][1]) * yScale
            let meanCrossSize = (coordinates[0][3] + coordinates[1][3]) * yScale / 2
            return alongGap > minimumAlongGap
                && crossGap < meanCrossSize * postureCrossOffsetLimit
        }

        let alongGap = abs(coordinates[0][1] - coordinates[1][1]) * yScale
        let minimumAlongGap = max(
            (coordinates[0][3] + coordinates[1][3]) * yScale * 1.1 / 2,
            coordinates[0][2] * xScale,
            coordinates[1][2] * xScale
        )
        let crossGap = abs(coordinates[0][0] - coordinates[1][0]) * xScale
        let meanCrossSize = (coordinates[0][2] + coordinates[1][2]) * xScale / 2
        return alongGap > minimumAlongGap
            && crossGap < meanCrossSize * postureCrossOffsetLimit
    }
}

// Kept behaviorally aligned with CurrentVisionObjectRecognitionViewModel.
extension RecognitionEngine {
    func judgeCutRange(stateResult: [[Float]]) -> Bool{
        if self.isCameraHorizon{
            let xDistance = abs(stateResult[0][0] - stateResult[1][0]) - (stateResult[0][2] - stateResult[1][2])/2
            let maxX = max(stateResult[0][2], stateResult[1][2])
            if xDistance < 3 * maxX{
                return true
            }
            else{
                return false
            }
        }
        else{
            let yDistance = abs(stateResult[0][1] - stateResult[1][1]) - (stateResult[0][3] - stateResult[1][3])/2
            let maxY = max(stateResult[0][3], stateResult[1][3])

            if yDistance < 3 * maxY{
                return true
            }
            else{
                return false
            }
        }
    }

    // MARK: compute targetArea
    func resolveTargetAreaScenario(boxCount _: Int) -> TargetAreaScenario {
        guard shuffleMode[0] == 2 else {
            return .standard
        }
        if detectNeedToCut {
            return .horizontalShuffleCut
        }
        return .horizontalShuffle
    }

    func computeTargetArea(stateResult: [[Float]]) -> [Float] {
        computeTargetArea(
            stateResult: stateResult,
            scenario: resolveTargetAreaScenario(boxCount: stateResult.count)
        )
    }

    func computeTargetArea(
        stateResult: [[Float]],
        scenario: TargetAreaScenario
    ) -> [Float] {
        switch scenario {
        case .standard:
            return computeStandardTargetArea(stateResult: stateResult)
        case .horizontalShuffle, .horizontalShuffleCut:
            return HorizontalShuffleROIGeometry.compute(
                stateResult: stateResult,
                originSize: originSize,
                isCameraHorizon: isCameraHorizon,
                areaFactor: singleROIAreaFactor
            )
        }
    }

    private func computeStandardTargetArea(stateResult: [[Float]])-> [Float]{

        let originBoxes = stateResult
        var targetArea:[Float] = [0,0,0,0]

        let w = self.imageSize[0]
        let h = self.imageSize[1]

        var boxfactor:Float = 1.5

        if originBoxes.count == 1{

            let minX = self.originSize[0] * (originBoxes[0][0] - originBoxes[0][2] / 2)
            let maxX = self.originSize[0] * (originBoxes[0][0] + originBoxes[0][2] / 2)
            let minY = self.originSize[1] * (originBoxes[0][1] - originBoxes[0][3] / 2)
            let maxY = self.originSize[1] * (originBoxes[0][1] + originBoxes[0][3] / 2)

            var minW = (maxX - minX)
            var minH = (maxY - minY)

            if self.isCameraHorizon{

                //如果不洗牌 只拨牌
                if self.shuffleMode[0] == 0 && self.shuffleMode[1] != 0{
                    boxfactor = 2.5
                }
                //如果不拨牌 只洗牌
                else if self.shuffleMode[0] != 0 && self.shuffleMode[1] == 0{
                    if detectNeedToCut{
                        boxfactor = 5
                    }
                    else{
                        boxfactor = 7.5
                    }
                }
                //要洗或拨
                else{
                    boxfactor = 5
                }

                minW = max(minW,minH/h*w) * boxfactor
                minW = min(minW, self.originSize[0] - 10)

                targetArea[2] = minW
                targetArea[3] = minW / w * h

                let centerX = (minX + maxX)/2
                let centerY = (minY + maxY)/2

                if centerX + targetArea[2]/2 >= self.originSize[0]{
                    targetArea[0] = self.originSize[0] - targetArea[2] / 2 - 2
                }
                else if centerX - targetArea[2]/2 <= 0{
                    targetArea[0] = targetArea[2]/2 + 2
                }
                else{
                    targetArea[0] = centerX
                }

                if centerY + targetArea[3]/2 >= self.originSize[1]{
                    targetArea[1] = self.originSize[1] - targetArea[3] / 2 - 2
                }
                else if centerY - targetArea[3]/2 <= 0{
                    targetArea[1] = targetArea[3]/2 + 2
                }
                else{
                    targetArea[1] = centerY
                }
            }

            else{
                //如果不洗牌 只拨牌
                if self.shuffleMode[0] == 0 && self.shuffleMode[1] != 0{
                    boxfactor = 2.5
                }
                //如果不拨牌 只洗牌
                else if self.shuffleMode[0] != 0 && self.shuffleMode[1] == 0{
                    if detectNeedToCut{
                        boxfactor = 5
                    }
                    else{
                        boxfactor = 7.5
                    }
                }
                //要要洗或拨
                else{
                    boxfactor = 5
                }

                minH = max(minW/h*w,minH) * boxfactor
                minH = min(minH, self.originSize[1] - 10)

                targetArea[2] = minH / w * h
                targetArea[3] = minH

                let centerX = (minX + maxX)/2
                let centerY = (minY + maxY)/2

                if centerX + targetArea[2]/2 >= self.originSize[0]{
                    targetArea[0] = self.originSize[0] - targetArea[2] / 2 - 2
                }
                else if centerX - targetArea[2]/2 <= 0{
                    targetArea[0] = targetArea[2]/2 + 2
                }
                else{
                    targetArea[0] = centerX
                }

                if centerY + targetArea[3]/2 >= self.originSize[1]{
                    targetArea[1] = self.originSize[1] - targetArea[3] / 2 - 2
                }
                else if centerY - targetArea[3]/2 <= 0{
                    targetArea[1] = targetArea[3]/2 + 2
                }
                else{
                    targetArea[1] = centerY
                }
            }

        }

        else if originBoxes.count == 2{
            // The pair bounds are independent of left/right or top/bottom order.
            let minX = self.originSize[0] * min(originBoxes[0][0] - originBoxes[0][2] / 2, originBoxes[1][0] - originBoxes[1][2] / 2)
            let maxX = self.originSize[0] * max(originBoxes[0][0] + originBoxes[0][2] / 2, originBoxes[1][0] + originBoxes[1][2] / 2)
            let minY = self.originSize[1] * min(originBoxes[0][1] - originBoxes[0][3] / 2, originBoxes[1][1] - originBoxes[1][3] / 2)
            let maxY = self.originSize[1] * max(originBoxes[0][1] + originBoxes[0][3] / 2, originBoxes[1][1] + originBoxes[1][3] / 2)
            let centerX = (minX + maxX)/2
            let centerY = (minY + maxY)/2

            if self.isCameraHorizon{

                var minW = (maxX - minX)*boxfactor
                minW = min(minW, self.originSize[0] - 10)

                var minH = (maxY - minY)*boxfactor
                minH = min(minH, self.originSize[1] - 10)

                targetArea[2] = max(minW, minH / h * w)
                targetArea[3] = max(minH, minW / w * h)
            }
            else{
                var minW = (maxX - minX)*boxfactor
                var minH = (maxY - minY)*boxfactor

                minH = max(minH, minW)
                minH = min(minH, self.originSize[1] - 10)

                minW = max((maxX - minX), minH / w * h)

                targetArea[2] = minW
                targetArea[3] = minH
            }

            if centerX + targetArea[2]/2 >= self.originSize[0]{
                targetArea[0] = self.originSize[0] - targetArea[2] / 2 - 2
            }
            else if centerX - targetArea[2]/2 <= 0{
                targetArea[0] = targetArea[2]/2 + 2
            }
            else{
                targetArea[0] = centerX
            }

            if centerY + targetArea[3]/2 >= self.originSize[1]{
                targetArea[1] = self.originSize[1] - targetArea[3] / 2 - 2
            }
            else if centerY - targetArea[3]/2 <= 0{
                targetArea[1] = targetArea[3]/2 + 2
            }
            else{
                targetArea[1] = centerY
            }
        }


        targetArea[0] /= originSize[0]
        targetArea[1] /= originSize[1]
        targetArea[2] /= originSize[0]
        targetArea[3] /= originSize[1]

        return targetArea
    }

    func updateTargetArea(coordinates:[[Float]], targetArea:[Float]) -> [Float]{
        let targetX = targetArea[0] * self.originSize[0]
        let targetY = targetArea[1] * self.originSize[1]
        let targetW = targetArea[2] * self.originSize[0]
        let targetH = targetArea[3] * self.originSize[1]

        var stateResult : [[Float]] = []

        if targetW != 0{
            for coordinate in coordinates {
                let x = (coordinate[0] * targetW + targetX - targetW / 2) / originSize[0]
                let y = (coordinate[1] * targetH + targetY - targetH / 2) / originSize[1]
                let w = (coordinate[2] * targetW) / originSize[0]
                let h = (coordinate[3] * targetH) / originSize[1]
                stateResult.append([x,y,w,h])
            }
        }
        else{
            for coordinate in coordinates {
                let x = coordinate[0]
                let y = coordinate[1]
                let w = coordinate[2]
                let h = coordinate[3]
                stateResult.append([x,y,w,h])
            }
        }

        if HorizontalShuffleROIGeometry.shouldPreserveCurrentROI(
            scenario: activeTargetAreaScenario,
            detectedBoxCount: stateResult.count,
            state: state
        ) {
            return self.targetArea
        }

        let nextTargetArea = computeTargetArea(
            stateResult: stateResult,
            scenario: activeTargetAreaScenario
        )
        if nextTargetArea[2] == 0 || nextTargetArea[3] == 0 {
            switch activeTargetAreaScenario {
            case .horizontalShuffle, .horizontalShuffleCut:
                return nextTargetArea
            case .standard:
                return targetArea
            }
        }
        return nextTargetArea
    }

    func targetAreaMove(initTargetArea: [Float], targetArea: [Float]) -> Bool{
        HorizontalShuffleROIGeometry.hasTargetAreaMoved(
            initial: initTargetArea,
            current: targetArea,
            isCameraHorizon: isCameraHorizon
        )
    }

    func shufflePostureJudge(
        coordinates:[[Float]],
        coordinateTargetArea: [Float]
    ) -> Bool{
        switch activeTargetAreaScenario {
        case .horizontalShuffle, .horizontalShuffleCut:
            return HorizontalShuffleROIGeometry.postureAccepts(
                coordinates: coordinates,
                coordinateTargetArea: coordinateTargetArea,
                originSize: originSize,
                isCameraHorizon: isCameraHorizon
            )
        case .standard:
            break
        }

        var isShuffle = false

        let w = self.imageSize[0]
        let h = self.imageSize[1]
        let xScale = isCameraHorizon ? w : h
        let yScale = isCameraHorizon ? h : w

        if self.isCameraHorizon{

            //x间距不能太小 大于最大宽度
            let xGap = abs(coordinates[0][0] - coordinates[1][0]) * xScale
            let maxW = max((coordinates[0][2] + coordinates[1][2]) * xScale * 1.1 / 2, coordinates[0][3] * yScale, coordinates[1][3] * yScale)

            //y间距不能太大 小于平均高度 / 2
            let yGap = abs(coordinates[0][1] - coordinates[1][1]) * yScale
            let minH = (coordinates[0][3] + coordinates[1][3]) / 4 * yScale

            if xGap > maxW && yGap < minH{
                isShuffle = true
            }
        }
        else{
            //y间距不能太小，大于目标沿 y 轴的最大尺寸
            let xGap = abs(coordinates[0][1] - coordinates[1][1]) * yScale
            let maxW = max((coordinates[0][3] + coordinates[1][3]) * yScale * 1.1 / 2, coordinates[0][2] * xScale, coordinates[1][2] * xScale)

            //x间距不能太大，小于平均宽度 / 2
            let yGap = abs(coordinates[0][0] - coordinates[1][0]) * xScale
            let minH = (coordinates[0][2] + coordinates[1][2]) / 4 * xScale

            if xGap > maxW && yGap < minH{
                isShuffle = true
            }
        }

        return isShuffle
    }
}
