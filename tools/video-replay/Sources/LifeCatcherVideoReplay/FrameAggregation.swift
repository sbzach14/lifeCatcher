import Foundation

// Exact cross-frame ordering algorithm from CurrentVisionObjectRecognitionViewModel.
extension RecognitionEngine {
    func handleDetecResultList(targetDetecResultList: [Int : [DetectionResult]]) -> DetectionState{

        var confidenceDic : [Int:Float] = [:]
        for key in self.allSingleFeatureIndex {
            confidenceDic[key] = 0
        }

        var sortedKeys = targetDetecResultList.keys.sorted()
        let blurThreshold : Float = 0.75
        let longHeadIndex = 2

        // print("检测sortedKeys \(sortedKeys)")

        if sortedKeys.count <= 1{
            let result = DetectionState(detectionResult: [], isSingle: true, isShort: true, longestIndex: -1)
            return result
        }

        var longestIndex: Int = -1

        var deleteKeys:[Int] = []
        //去除重复帧
        for keyIndex in 0..<sortedKeys.count-1{

            let detectResultListIndex = sortedKeys[keyIndex]
            let nextDetectResultListIndex = sortedKeys[keyIndex+1]
            for numIndex in 0..<targetDetecResultList[detectResultListIndex]!.count{
                let nowLaplacian = targetDetecResultList[detectResultListIndex]![numIndex].laplacianVariance
                let nextLaplacian = targetDetecResultList[nextDetectResultListIndex]![numIndex].laplacianVariance
                let nowNum = targetDetecResultList[detectResultListIndex]![numIndex].singlefeatureIndex[0]
                let nextNum = targetDetecResultList[nextDetectResultListIndex]![numIndex].singlefeatureIndex[0]

                if abs(nowLaplacian - nextLaplacian) <= 0.000000001 && nowNum == nextNum{
                    deleteKeys.append(detectResultListIndex)
                }
            }

//            let nowConfidence0 = targetDetecResultList[detectResultListIndex]![0].confidence[0]
//            let nowConfidence1 = targetDetecResultList[detectResultListIndex]![1].confidence[0]
//            if nowConfidence0 < 0.1 && nowConfidence1 < 0.1{
//                deleteKeys.append(detectResultListIndex)
//            }



            let dRNode0 = targetDetecResultList[detectResultListIndex]![0]
            let dRNode1 = targetDetecResultList[detectResultListIndex]![1]

            let nowN0 = dRNode0.singlefeatureIndex[0]
            let nowN1 = dRNode1.singlefeatureIndex[0]

//                        print("index ", detectResultListIndex,
//                              singlefeatureLabelDic[nowN0] ?? "none", dRNode0.nodeType, dRNode0.laplacianVariance, dRNode0.confidence[0], detectResultListIndex,
//                              singlefeatureLabelDic[nowN1] ?? "none", dRNode1.nodeType, dRNode1.laplacianVariance, dRNode1.confidence[0])
        }

        sortedKeys = sortedKeys.filter { !deleteKeys.contains($0) }

        var beginIndex = 2
        var endIndex = sortedKeys.count-3


        if beginIndex >= endIndex{
            print("return1")
            let result = DetectionState(detectionResult: [], isSingle: true, isShort: true, longestIndex: -1)
            return result
        }

        for keyIndex in beginIndex..<endIndex{
            let detectResultListIndex = sortedKeys[keyIndex]
            let nextDetectResultListIndex = sortedKeys[keyIndex+1]
            for numIndex in 0..<targetDetecResultList[detectResultListIndex]!.count{
                let nowNum = targetDetecResultList[detectResultListIndex]![numIndex].singlefeatureIndex[0]
                if nowNum != -1
                    && targetDetecResultList[nextDetectResultListIndex]![numIndex].singlefeatureIndex[0] == nowNum
                    && confidenceDic.keys.contains(nowNum){
                    targetDetecResultList[detectResultListIndex]![numIndex].nodeType += 1
                    targetDetecResultList[nextDetectResultListIndex]![numIndex].nodeType += 2
                }
            }
        }

        var leftSideSet = Set<Int>()
        var rightSideSet = Set<Int>()

        var leftFirstHead = -1
        var rightFirstHead = -1

        var leftLastTail = -1
        var rightLastTail = -1

        var leftTailCnt = 0
        var rightTailCnt = 0

        var leftTailLong = -1
        var rightTailLong = -1

        var singleCnt = 0
        var doubleCnt = 0

        endIndex += 1

        for keyIndex in beginIndex..<endIndex{
            let detectResultListIndex = sortedKeys[keyIndex]
            let lastDetectResultListIndex = sortedKeys[keyIndex-1]
            let nextDetectResultListIndex = sortedKeys[keyIndex+1]
            let nextnextDetectResultListIndex = sortedKeys[keyIndex+2]

            let detectResultNode0 = targetDetecResultList[detectResultListIndex]![0]
            let detectResultNode1 = targetDetecResultList[detectResultListIndex]![1]

            let lastDetectResultNode0 = targetDetecResultList[lastDetectResultListIndex]![0]
            let lastDetectResultNode1 = targetDetecResultList[lastDetectResultListIndex]![1]

            let nextDetectResultNode0 = targetDetecResultList[nextDetectResultListIndex]![0]
            let nextDetectResultNode1 = targetDetecResultList[nextDetectResultListIndex]![1]

            let nextnextDetectResultNode0 = targetDetecResultList[nextnextDetectResultListIndex]![0]
            let nextnextDetectResultNode1 = targetDetecResultList[nextnextDetectResultListIndex]![1]

            let nowNum0 = targetDetecResultList[detectResultListIndex]![0].singlefeatureIndex[0]
            let nodeType0 = targetDetecResultList[detectResultListIndex]![0].nodeType
            let nowNum1 = targetDetecResultList[detectResultListIndex]![1].singlefeatureIndex[0]
            let nodeType1 = targetDetecResultList[detectResultListIndex]![1].nodeType

            //            print("index ", keyIndex,
            //                  singlefeatureLabelDic[nowNum0] ?? "none", detectResultNode0.nodeType, detectResultNode0.laplacianVariance, detectResultNode0.confidence[0], detectResultListIndex,
            //                  singlefeatureLabelDic[nowNum1] ?? "none", detectResultNode1.nodeType, detectResultNode1.laplacianVariance, detectResultNode1.confidence[0])

            if targetDetecResultList[detectResultListIndex]![0].singlefeatureIndex[0] != -1
                && targetDetecResultList[detectResultListIndex]![1].singlefeatureIndex[0] != -1{
                doubleCnt += 1
            }
            else{
                singleCnt += 1
            }

            for numIndex in 0..<targetDetecResultList[detectResultListIndex]!.count{
                let detectResultNode = targetDetecResultList[detectResultListIndex]![numIndex]

                if detectResultNode.nodeType == 1{
                    if numIndex == 0{
                        leftSideSet.insert(detectResultNode.singlefeatureIndex[0])
                    }
                    else{
                        rightSideSet.insert(detectResultNode.singlefeatureIndex[0])
                    }
                }

                if detectResultNode.nodeType == 3{
                    if numIndex == 0{
                        if leftFirstHead == -1 && keyIndex > longHeadIndex{
                            leftFirstHead = keyIndex
                        }
                        leftTailCnt += 1
                    }
                    if numIndex == 1{
                        if rightFirstHead == -1 && keyIndex > longHeadIndex{
                            rightFirstHead = keyIndex
                        }
                        rightTailCnt += 1
                    }
                }

                if detectResultNode.nodeType == 2{
                    if numIndex == 0{
                        leftLastTail = keyIndex
                        if leftTailCnt >= 3{
                            leftTailLong = keyIndex
                        }
                        leftTailCnt = 0
                    }
                    if numIndex == 1{
                        rightLastTail = keyIndex
                        if rightTailCnt >= 2{
                            rightTailLong = keyIndex
                        }
                        rightTailCnt = 0
                    }
                }
            }
        }

        var leftSideCnt = leftSideSet.count
        var rightSideCnt = rightSideSet.count

        var isSingle = true
        if  doubleCnt > singleCnt{
            isSingle = false
        }

        var isShort = true
        if leftSideCnt + rightSideCnt >= min(minSingleFeatureNum, 15){
            isShort = false
        }

        if !isShort{
            //如果两侧都有 则要找到两侧都是链的时候开始 即两侧都是3
            //Mod add targetDetecResultList[detectResultListIndex]![0].confidence[0] >= 0.8
            if !isSingle
            {
                beginIndex = longHeadIndex
                for keyIndex in beginIndex..<endIndex{
                    let detectResultListIndex = sortedKeys[keyIndex]
                    if targetDetecResultList[detectResultListIndex]![0].nodeType == 3
                        && targetDetecResultList[detectResultListIndex]![1].nodeType == 3
                        && targetDetecResultList[detectResultListIndex]![0].confidence[0] >= 0.8
                        && targetDetecResultList[detectResultListIndex]![1].confidence[0] >= 0.8{
                        beginIndex = keyIndex
                        break
                    }
                }

                print("tail \(leftLastTail) \(rightLastTail)")
                endIndex = max(leftLastTail, rightLastTail) + 1
            }
            else if leftSideCnt > rightSideCnt && leftFirstHead != -1{
                beginIndex = leftFirstHead
                endIndex = leftTailLong + 1
            }
            else if leftSideCnt < rightSideCnt && rightFirstHead != -1{
                beginIndex = rightFirstHead
                endIndex = rightTailLong + 1
            }
        }

        if beginIndex >= endIndex{
            print("return2")
            let result = DetectionState(detectionResult: [], isSingle: true, isShort: true, longestIndex: -1)
            return result
        }

        for keyIndex in beginIndex..<endIndex{
            let detectResultListIndex = sortedKeys[keyIndex]
            for numIndex in 0..<targetDetecResultList[detectResultListIndex]!.count{
                let detectResultNode = targetDetecResultList[detectResultListIndex]![numIndex]
                if (detectResultNode.nodeType == 1 ||
                    detectResultNode.nodeType == 2 ||
                    detectResultNode.nodeType == 3)
                    && detectResultNode.confidence[0] > 0.7{
                    confidenceDic[detectResultNode.singlefeatureIndex[0]] = 100
                }
            }
        }

        for _ in 0..<3{
            for key in confidenceDic.keys{

                if confidenceDic[key] == 100{
                    for numIndex in 0..<2{

                        var end = -1
                        var head = -1

                        for keyIndex in beginIndex..<endIndex{
                            let detectResultListIndex = sortedKeys[keyIndex]
                            let nowNum = targetDetecResultList[detectResultListIndex]![numIndex].singlefeatureIndex[0]
                            if nowNum == key && targetDetecResultList[detectResultListIndex]![numIndex].nodeType == 2{
                                end = keyIndex
                            }
                            else if nowNum == key
                                        && targetDetecResultList[detectResultListIndex]![numIndex].nodeType == 1
                                        && end != -1{
                                head = keyIndex

                                let isClose = head - end <= 3

                                var isSameNum = head - end <= 5
                                var middleNum = -1
                                for updateIndex in end+1...head-1{
                                    let updateNodeIndex = sortedKeys[updateIndex]
                                    let currentMiddleNum = targetDetecResultList[updateNodeIndex]![numIndex].singlefeatureIndex[0]
                                    if currentMiddleNum != -1{
                                        middleNum = currentMiddleNum
                                        break
                                    }
                                }
                                for updateIndex in end+1...head-1{
                                    let updateNodeIndex = sortedKeys[updateIndex]
                                    let currentMiddleNum = targetDetecResultList[updateNodeIndex]![numIndex].singlefeatureIndex[0]
                                    if currentMiddleNum != -1 && currentMiddleNum != middleNum{
                                        isSameNum = false
                                        break
                                    }
                                }

                                if isClose || isSameNum{
                                    for updateIndex in end...head{
                                        let updateNodeIndex = sortedKeys[updateIndex]
                                        targetDetecResultList[updateNodeIndex]![numIndex].singlefeatureIndex[0] = nowNum
                                        targetDetecResultList[updateNodeIndex]![numIndex].nodeType = 3
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        for key in confidenceDic.keys{
            if confidenceDic[key] == 100{
                var isChain = false
                for keyIndex in beginIndex..<endIndex{
                    let detectResultListIndex = sortedKeys[keyIndex]
                    for numIndex in 0..<targetDetecResultList[detectResultListIndex]!.count{
                        let nowNum = targetDetecResultList[detectResultListIndex]![numIndex].singlefeatureIndex[0]
                        let nodeType = targetDetecResultList[detectResultListIndex]![numIndex].nodeType
                        if nowNum == key && nodeType == 2 {
                            isChain = true
                        }
                    }
                    if isChain{
                        break
                    }
                }
                if !isChain{
                    confidenceDic[key] = 0
                }
            }
        }

        for keyIndex in beginIndex..<endIndex{
            let detectResultListIndex = sortedKeys[keyIndex]
            for numIndex in 0..<targetDetecResultList[detectResultListIndex]!.count{
                let detectResultNode = targetDetecResultList[detectResultListIndex]![numIndex]

                if detectResultNode.nodeType == 0
                    && detectResultNode.singlefeatureIndex[0] != -1{

                    var newSingleFeatureIndex : [Int] = []
                    var newConfidence : [Float] = []
                    for i in 0..<detectResultNode.singlefeatureIndex.count{
                        let currentNum = detectResultNode.singlefeatureIndex[i]
                        if confidenceDic.keys.contains(currentNum){
                            if confidenceDic[currentNum] == 0{
                                newSingleFeatureIndex.append(detectResultNode.singlefeatureIndex[i])
                                newConfidence.append(detectResultNode.confidence[i])
                            }
                        }
                    }

                    if newSingleFeatureIndex.count == 0{
                        newSingleFeatureIndex.append(-1)
                        newConfidence.append(1)
                        detectResultNode.nodeType = 5
                    }

                    detectResultNode.singlefeatureIndex = newSingleFeatureIndex
                    detectResultNode.confidence = newConfidence
                }
            }
        }

        leftLastTail = -1
        rightLastTail = -1

        leftTailCnt = 0
        rightTailCnt = 0

        for keyIndex in beginIndex..<endIndex{
            let detectResultListIndex = sortedKeys[keyIndex]
            for numIndex in 0..<targetDetecResultList[detectResultListIndex]!.count{
                let detectResultNode = targetDetecResultList[detectResultListIndex]![numIndex]

                if detectResultNode.nodeType == 2{
                    if numIndex == 0{
                        leftLastTail = keyIndex
                    }
                    if numIndex == 1{
                        rightLastTail = keyIndex
                    }
                }
            }
        }

        var addEndIndex = 0

        if !isSingle{
            endIndex = max(leftLastTail, rightLastTail) + 1
            addEndIndex = min(leftLastTail, rightLastTail)
        }
        else if leftSideCnt > rightSideCnt{
            endIndex = leftTailLong + 1
            addEndIndex = leftTailLong
        }
        else if leftSideCnt < rightSideCnt{
            endIndex = rightTailLong + 1
            addEndIndex = rightTailLong
        }

        if beginIndex >= endIndex{
            print("return3")
            let result = DetectionState(detectionResult: [], isSingle: true, isShort: true, longestIndex: -1)
            return result
        }

        if addEndIndex <= beginIndex{
            addEndIndex = beginIndex + 1
        }

        for key in confidenceDic.keys{
            if confidenceDic[key] == 0{
                var nodeIndex : [Int] = []
                for keyIndex in beginIndex..<addEndIndex{
                    let detectResultListIndex = sortedKeys[keyIndex]

                    for numIndex in 0..<targetDetecResultList[detectResultListIndex]!.count{
                        let nowNum = targetDetecResultList[detectResultListIndex]![numIndex].singlefeatureIndex[0]
                        let confidence = targetDetecResultList[detectResultListIndex]![numIndex].confidence[0]
                        if nowNum == key && confidence > confidenceDic[nowNum]! {
                            confidenceDic[nowNum] = confidence
                            nodeIndex = [detectResultListIndex, numIndex]
                        }
                    }
                }
                if nodeIndex.count > 0 && (addCardMode==1 || confidenceDic[key]! > 0.7){
                    targetDetecResultList[nodeIndex[0]]![nodeIndex[1]].nodeType = 4
                }
            }
        }

        for keyIndex in beginIndex..<endIndex{
            let detectResultListIndex = sortedKeys[keyIndex]
            for numIndex in 0..<targetDetecResultList[detectResultListIndex]!.count{
                let detectResultNode = targetDetecResultList[detectResultListIndex]![numIndex]

                if detectResultNode.nodeType == 0
                    && detectResultNode.singlefeatureIndex[0] != -1{

                    var newSingleFeatureIndex : [Int] = []
                    var newConfidence : [Float] = []
                    for i in 0..<detectResultNode.singlefeatureIndex.count{
                        if confidenceDic[i] == 0{
                            newSingleFeatureIndex.append(detectResultNode.singlefeatureIndex[i])
                            newConfidence.append(detectResultNode.confidence[i])
                        }
                    }

                    if newSingleFeatureIndex.count == 0{
                        newSingleFeatureIndex.append(-1)
                        newConfidence.append(1)
                        detectResultNode.nodeType = 5//所有可能的数字去除，标记为融合牌
                    }

                    detectResultNode.singlefeatureIndex = newSingleFeatureIndex
                    detectResultNode.confidence = newConfidence
                }
            }
        }

        for key in confidenceDic.keys{
            if confidenceDic[key] == 0{
                var nodeIndex : [Int] = []
                for keyIndex in beginIndex..<addEndIndex{
                    let detectResultListIndex = sortedKeys[keyIndex]

                    for numIndex in 0..<targetDetecResultList[detectResultListIndex]!.count{
                        let nowNum = targetDetecResultList[detectResultListIndex]![numIndex].singlefeatureIndex[0]
                        let confidence = targetDetecResultList[detectResultListIndex]![numIndex].confidence[0]
                        if nowNum == key && confidence > confidenceDic[nowNum]! {
                            confidenceDic[nowNum] = confidence
                            nodeIndex = [detectResultListIndex, numIndex]
                        }
                    }
                }
                if nodeIndex.count > 0 && (addCardMode==1 || confidenceDic[key]! > 0.7){
                    targetDetecResultList[nodeIndex[0]]![nodeIndex[1]].nodeType = 4
                }
            }
        }

        let isCut = isShort && isSingle

        //统计标准模糊度(非切牌下）
        if !isCut{
            for keyIndex in beginIndex..<endIndex{
                let detectResultListIndex = sortedKeys[keyIndex]
                for numIndex in 0..<targetDetecResultList[detectResultListIndex]!.count{
                    let detectResultNode = targetDetecResultList[detectResultListIndex]![numIndex]
                    if detectResultNode.nodeType == 3{
                        if self.laplacianDic[numIndex][detectResultNode.singlefeatureIndex[0]] == 0{
                            self.laplacianDic[numIndex][detectResultNode.singlefeatureIndex[0]] = detectResultNode.laplacianVariance
                        }
                        else{
                            self.laplacianDic[numIndex][detectResultNode.singlefeatureIndex[0]]! += detectResultNode.laplacianVariance
                            self.laplacianDic[numIndex][detectResultNode.singlefeatureIndex[0]]! /= 2
                        }
                    }
                }
            }
        }

        let isShuffle = self.shuffleMode[0] != 0 && !isSingle && !isShort

        var lostNum = 0
        var addNum = 0

        for key in confidenceDic.keys{
            if confidenceDic[key] == 0{
                lostNum += 1
            }
        }

        //补牌
        if addCardMode==1 && isShuffle && beginIndex < addEndIndex && lostNum <= 2{

            let numIndexList : [Int] = [0, 1]

            for key in confidenceDic.keys{
                if confidenceDic[key] == 0{

                    for keyIndex in beginIndex..<addEndIndex{
                        let detectResultListIndex = sortedKeys[keyIndex]
                        let nextDetectResultListIndex = sortedKeys[keyIndex+1]
                        for numIndex in numIndexList{
                            let detectResultNode = targetDetecResultList[detectResultListIndex]![numIndex]
                            let nextDetectResultNode = targetDetecResultList[nextDetectResultListIndex]![numIndex]
                            if detectResultNode.nodeType == 5 && nextDetectResultNode.nodeType == 5{
                                detectResultNode.singlefeatureIndex[0] = key
                                nextDetectResultNode.singlefeatureIndex[0] = key
                                detectResultNode.nodeType = 1
                                nextDetectResultNode.nodeType = 2
                                confidenceDic[key] = 1
                                break
                            }
                        }

                        if confidenceDic[key] != 0{
                            break
                        }
                    }

                    if confidenceDic[key] != 0{
                        addNum += 1
                        continue
                    }

                    for keyIndex in beginIndex..<addEndIndex{
                        let detectResultListIndex = sortedKeys[keyIndex]
                        let nextDetectResultListIndex = sortedKeys[keyIndex+1]
                        for numIndex in numIndexList{
                            let detectResultNode = targetDetecResultList[detectResultListIndex]![numIndex]
                            let nextDetectResultNode = targetDetecResultList[nextDetectResultListIndex]![numIndex]
                            if (detectResultNode.nodeType == 0 || nextDetectResultNode.nodeType == 5)
                                && (detectResultNode.nodeType == 5 || nextDetectResultNode.nodeType == 0){
                                detectResultNode.singlefeatureIndex[0] = key
                                nextDetectResultNode.singlefeatureIndex[0] = key
                                detectResultNode.nodeType = 1
                                nextDetectResultNode.nodeType = 2
                                confidenceDic[key] = 1
                                break
                            }
                        }

                        if confidenceDic[key] != 0{
                            break
                        }
                    }

                    if confidenceDic[key] != 0{
                        addNum += 1
                        continue
                    }

                    for keyIndex in beginIndex..<addEndIndex{
                        let detectResultListIndex = sortedKeys[keyIndex]
                        let nextDetectResultListIndex = sortedKeys[keyIndex+1]
                        for numIndex in numIndexList{
                            let detectResultNode = targetDetecResultList[detectResultListIndex]![numIndex]
                            let nextDetectResultNode = targetDetecResultList[nextDetectResultListIndex]![numIndex]
                            if detectResultNode.nodeType == 5{
                                detectResultNode.singlefeatureIndex[0] = key
                                detectResultNode.nodeType = 4
                                confidenceDic[key] = 1
                                break
                            }
                        }

                        if confidenceDic[key] != 0{
                            break
                        }
                    }

                    if confidenceDic[key] != 0{
                        addNum += 1
                        continue
                    }

                    for keyIndex in beginIndex..<addEndIndex{
                        let detectResultListIndex = sortedKeys[keyIndex]
                        let nextDetectResultListIndex = sortedKeys[keyIndex+1]
                        for numIndex in numIndexList{
                            let detectResultNode = targetDetecResultList[detectResultListIndex]![numIndex]
                            let nextDetectResultNode = targetDetecResultList[nextDetectResultListIndex]![numIndex]
                            if detectResultNode.nodeType == 0{
                                detectResultNode.singlefeatureIndex[0] = key
                                detectResultNode.nodeType = 4
                                confidenceDic[key] = 1
                                break
                            }
                        }

                        if confidenceDic[key] != 0{
                            break
                        }
                    }

                    if confidenceDic[key] != 0{
                        addNum += 1
                        continue
                    }
                }
            }
        }

        //补链头尾
        for keyIndex in beginIndex..<addEndIndex{
            let detectResultListIndex = sortedKeys[keyIndex]
            let lastDetectResultListIndex = sortedKeys[keyIndex-1]
            let lastlastDetectResultListIndex = sortedKeys[keyIndex-2]
            let nextDetectResultListIndex = sortedKeys[keyIndex+1]
            let nextnextDetectResultListIndex = sortedKeys[keyIndex+2]

            for numIndex in 0..<targetDetecResultList[detectResultListIndex]!.count{
                let detectResultNode = targetDetecResultList[detectResultListIndex]![numIndex]
                let sideDetectResultNode = targetDetecResultList[detectResultListIndex]![1-numIndex]
                let lastDetectResultNode = targetDetecResultList[lastDetectResultListIndex]![numIndex]
                let lastlastDetectResultNode = targetDetecResultList[lastlastDetectResultListIndex]![numIndex]
                let nextDetectResultNode = targetDetecResultList[nextDetectResultListIndex]![numIndex]
                let nextnextDetectResultNode = targetDetecResultList[nextnextDetectResultListIndex]![numIndex]

                if (detectResultNode.nodeType == 5 || detectResultNode.nodeType == 0)
                    && sideDetectResultNode.nodeType == 2
                    && detectResultNode.laplacianVariance < lastDetectResultNode.laplacianVariance{

                    if lastDetectResultNode.nodeType == 2
                        && lastDetectResultNode.laplacianVariance / lastlastDetectResultNode.laplacianVariance > blurThreshold
                        && detectResultNode.laplacianVariance / lastDetectResultNode.laplacianVariance < blurThreshold{
                        lastDetectResultNode.nodeType = 3
                        detectResultNode.nodeType = 2
                        detectResultNode.singlefeatureIndex[0] = lastDetectResultNode.singlefeatureIndex[0]

                    }

                    else if lastDetectResultNode.nodeType == 4{
                        lastDetectResultNode.nodeType = 1
                        detectResultNode.nodeType = 2
                        detectResultNode.singlefeatureIndex[0] = lastDetectResultNode.singlefeatureIndex[0]
                    }

                }

                if (detectResultNode.nodeType == 5 || detectResultNode.nodeType == 0)
                    && sideDetectResultNode.nodeType == 1
                    && detectResultNode.laplacianVariance < nextDetectResultNode.laplacianVariance{

                    if nextDetectResultNode.nodeType == 1
                        && nextDetectResultNode.laplacianVariance / nextnextDetectResultNode.laplacianVariance > blurThreshold
                        && detectResultNode.laplacianVariance / nextDetectResultNode.laplacianVariance < blurThreshold{
                        nextDetectResultNode.nodeType = 3
                        detectResultNode.nodeType = 1
                        detectResultNode.singlefeatureIndex[0] = nextDetectResultNode.singlefeatureIndex[0]

                    }

                    else if nextDetectResultNode.nodeType == 4{
                        nextDetectResultNode.nodeType = 2
                        detectResultNode.nodeType = 1
                        detectResultNode.singlefeatureIndex[0] = nextDetectResultNode.singlefeatureIndex[0]
                    }

                }
            }
        }

        var detectSingleFeatureArray : [InsertCard] = []

        var noneCnt = 0
        var headCnt = 0
        var tailCnt = 0

        // print("isSingle:\(isSingle) isShort:\(isShort) leftHead:\(leftFirstHead) rightHead:\(rightFirstHead)  leftTail:\(leftLastTail) rightTail:\(rightLastTail) endIndex:\(endIndex)")

        var chainConfidence0:Float = 0
        var chainConfidence1:Float = 0

        for keyIndex in beginIndex..<endIndex{
            let detectResultListIndex = sortedKeys[keyIndex]
            let lastDetectResultListIndex = sortedKeys[keyIndex-1]
            let nextDetectResultListIndex = sortedKeys[keyIndex+1]
            let nextnextDetectResultListIndex = sortedKeys[keyIndex+2]
            if targetDetecResultList[detectResultListIndex]!.count == 2{


                let detectResultNode0 = targetDetecResultList[detectResultListIndex]![0]
                let detectResultNode1 = targetDetecResultList[detectResultListIndex]![1]

                let lastDetectResultNode0 = targetDetecResultList[lastDetectResultListIndex]![0]
                let lastDetectResultNode1 = targetDetecResultList[lastDetectResultListIndex]![1]

                let nextDetectResultNode0 = targetDetecResultList[nextDetectResultListIndex]![0]
                let nextDetectResultNode1 = targetDetecResultList[nextDetectResultListIndex]![1]

                let nextnextDetectResultNode0 = targetDetecResultList[nextnextDetectResultListIndex]![0]
                let nextnextDetectResultNode1 = targetDetecResultList[nextnextDetectResultListIndex]![1]

                let nowNum0 = targetDetecResultList[detectResultListIndex]![0].singlefeatureIndex[0]
                let nodeType0 = targetDetecResultList[detectResultListIndex]![0].nodeType
                let nowNum1 = targetDetecResultList[detectResultListIndex]![1].singlefeatureIndex[0]
                let nodeType1 = targetDetecResultList[detectResultListIndex]![1].nodeType

                print("index ", detectResultListIndex,
                      singlefeatureLabelDic[nowNum0] ?? "none", "type\(detectResultNode0.nodeType)", detectResultNode0.laplacianVariance, detectResultNode0.confidence[0], detectResultNode0.singlefeatureIndex.count, "     ",
                      singlefeatureLabelDic[nowNum1] ?? "none", "type\(detectResultNode1.nodeType)", detectResultNode1.laplacianVariance, detectResultNode1.confidence[0], detectResultNode1.singlefeatureIndex.count)

                chainConfidence0 = max(chainConfidence0, detectResultNode0.confidence[0])
                chainConfidence1 = max(chainConfidence1, detectResultNode1.confidence[0])

                var insertCard0 = InsertCard(cardIndex: nowNum0, confidence: chainConfidence0)
                var insertCard1 = InsertCard(cardIndex: nowNum1, confidence: chainConfidence1)

                if nodeType0 != 1 && nodeType0 != 3{
                    chainConfidence0 = 0
                }

                if nodeType1 != 1 && nodeType1 != 3{
                    chainConfidence1 = 0
                }

                if isSingle{
                    if nodeType0 == 2{
                        detectSingleFeatureArray.insert(insertCard0, at: 0)
                    }
                    else if nodeType0 == 4
                            && nowNum0 != -1
                            && detectResultNode0.confidence[0] > 0.75
                            && detectResultNode0.confidence.count <= 6
                    {
                        detectSingleFeatureArray.insert(insertCard0, at: 0)
                    }
//                    else if (nodeType0 == 0 || nodeType0 == 4)
//                                && nowNum0 != -1
//                                && detectResultNode0.confidence[0] > 0.7
//                    {
//                        var confidenceFlag = 0
//                        var blurFlag = 0
//
//                        if detectResultNode0.laplacianVariance < lastDetectResultNode0.laplacianVariance * 0.5
//                            && detectResultNode0.laplacianVariance < nextDetectResultNode0.laplacianVariance * 0.5{
//                            blurFlag += 1
//                        }
//
//                        if detectResultNode0.confidence[0] > lastDetectResultNode0.confidence[0] && detectResultNode0.laplacianVariance > lastDetectResultNode0.laplacianVariance{
//                            confidenceFlag += 1
//                        }
//                        if detectResultNode0.confidence[0] > nextDetectResultNode0.confidence[0]
//                            && detectResultNode0.laplacianVariance > nextDetectResultNode0.laplacianVariance{
//                            confidenceFlag += 1
//                        }
//                        if lastDetectResultNode0.confidence[0] < 0.7 && lastDetectResultNode0.nodeType != 2{
//                            confidenceFlag += 1
//                        }
//                        if nextDetectResultNode0.confidence[0] < 0.7 && nextDetectResultNode0.nodeType != 1{
//                            confidenceFlag += 1
//                        }
//                        if detectResultNode0.laplacianVariance > lastDetectResultNode0.laplacianVariance
//                            && detectResultNode0.laplacianVariance > nextDetectResultNode0.laplacianVariance{
//                            confidenceFlag += 1
//                        }
//                        if detectResultNode0.confidence[0] > lastDetectResultNode0.confidence[0]
//                            && detectResultNode0.confidence[0] > nextDetectResultNode0.confidence[0]
//                            && blurFlag == 0{
//                            confidenceFlag += 1
//                        }
//
//                        if confidenceFlag >= 1{
//                            detectSingleFeatureArray.insert(insertCard0, at: 0)
//                        }
//                    }

                    if nodeType1 == 2 || nodeType1 == 4{
                        detectSingleFeatureArray.insert(insertCard1, at: 0)
                    }
                    else if nodeType1 == 4
                            && nowNum1 != -1
                            && detectResultNode1.confidence[0] > 0.7
                            && detectResultNode1.confidence.count <= 10
                    {
                        detectSingleFeatureArray.insert(insertCard1, at: 0)
                    }
//                    else if (nodeType1 == 0 || nodeType1 == 4)
//                                && nowNum1 != -1
//                                && detectResultNode1.confidence[0] > 0.7
//                    {
//                        var confidenceFlag = 0
//                        var blurFlag = 0
//
//                        if detectResultNode1.laplacianVariance < lastDetectResultNode1.laplacianVariance * 0.5
//                            && detectResultNode1.laplacianVariance < nextDetectResultNode1.laplacianVariance * 0.5{
//                            blurFlag += 1
//                        }
//
//                        if detectResultNode1.confidence[0] > lastDetectResultNode1.confidence[0] && detectResultNode1.laplacianVariance > lastDetectResultNode1.laplacianVariance{
//                            confidenceFlag += 1
//                        }
//                        if detectResultNode1.confidence[0] > nextDetectResultNode1.confidence[0]
//                            && detectResultNode1.laplacianVariance > nextDetectResultNode1.laplacianVariance{
//                            confidenceFlag += 1
//                        }
//                        if lastDetectResultNode1.confidence[0] < 0.7 && lastDetectResultNode1.nodeType != 2{
//                            confidenceFlag += 1
//                        }
//                        if nextDetectResultNode1.confidence[0] < 0.7 && nextDetectResultNode1.nodeType != 1{
//                            confidenceFlag += 1
//                        }
//                        if detectResultNode1.laplacianVariance > lastDetectResultNode1.laplacianVariance
//                            && detectResultNode1.laplacianVariance > nextDetectResultNode1.laplacianVariance{
//                            confidenceFlag += 1
//                        }
//                        if detectResultNode1.confidence[0] > lastDetectResultNode1.confidence[0]
//                            && detectResultNode1.confidence[0] > nextDetectResultNode1.confidence[0]
//                            && blurFlag == 0{
//                            confidenceFlag += 1
//                        }
//
//                        if confidenceFlag >= 1{
//                            detectSingleFeatureArray.insert(insertCard1, at: 0)
//                        }
//                    }
                }
                else{
                    if (nodeType0 == 2 || nodeType0 == 4)
                        && (nodeType1 == 2 || nodeType1 == 4){

                        var leftLaplacianPercent : Float = 1
                        var rightLaplacianPercent : Float = 1

                        if nodeType0 == 2{
                            leftLaplacianPercent = detectResultNode0.laplacianVariance / lastDetectResultNode0.laplacianVariance
                        }
                        else if nodeType0 == 4 && self.laplacianDic[0][nowNum0] != 0{
                            leftLaplacianPercent = detectResultNode0.laplacianVariance / self.laplacianDic[0][nowNum0]!
                        }

                        if nodeType1 == 2{
                            rightLaplacianPercent = detectResultNode1.laplacianVariance / lastDetectResultNode1.laplacianVariance
                        }
                        else if nodeType1 == 4 && self.laplacianDic[1][nowNum1] != 0{
                            rightLaplacianPercent = detectResultNode1.laplacianVariance / self.laplacianDic[1][nowNum1]!
                        }

                        if nextDetectResultNode0.nodeType == 5 && nextDetectResultNode1.nodeType != 5{
                            detectSingleFeatureArray.insert(insertCard1, at: 0)
                            detectSingleFeatureArray.insert(insertCard0, at: 0)
                        }
                        else if nextDetectResultNode0.nodeType != 5 && nextDetectResultNode1.nodeType == 5{
                            detectSingleFeatureArray.insert(insertCard0, at: 0)
                            detectSingleFeatureArray.insert(insertCard1, at: 0)
                        }
                        else if nextDetectResultNode0.nodeType == 0 && nextDetectResultNode1.nodeType != 0{
                            detectSingleFeatureArray.insert(insertCard1, at: 0)
                            detectSingleFeatureArray.insert(insertCard0, at: 0)
                        }
                        else if nextDetectResultNode0.nodeType != 0 && nextDetectResultNode1.nodeType == 0{
                            detectSingleFeatureArray.insert(insertCard0, at: 0)
                            detectSingleFeatureArray.insert(insertCard1, at: 0)
                        }
                        else if leftLaplacianPercent < blurThreshold && rightLaplacianPercent >= blurThreshold{
                            detectSingleFeatureArray.insert(insertCard0, at: 0)
                            detectSingleFeatureArray.insert(insertCard1, at: 0)
                        }
                        else if rightLaplacianPercent < blurThreshold && leftLaplacianPercent >= blurThreshold{
                            detectSingleFeatureArray.insert(insertCard1, at: 0)
                            detectSingleFeatureArray.insert(insertCard0, at: 0)
                        }
                        else{
                            var leftNextLaplacianPercent : Float = 1
                            var rightNextLaplacianPercent : Float = 1

                            if nextDetectResultNode0.nodeType == 1{
                                leftNextLaplacianPercent = nextDetectResultNode0.laplacianVariance / nextnextDetectResultNode0.laplacianVariance
                            }
                            else if nextDetectResultNode0.nodeType == 0{
                                leftNextLaplacianPercent = nextDetectResultNode0.laplacianVariance / nextnextDetectResultNode0.laplacianVariance
                            }
                            else if nextDetectResultNode0.nodeType == 4 && self.laplacianDic[0][nextDetectResultNode0.singlefeatureIndex[0]] != 0{
                                leftNextLaplacianPercent = nextDetectResultNode0.laplacianVariance / self.laplacianDic[0][nextDetectResultNode0.singlefeatureIndex[0]]!
                            }

                            if nextDetectResultNode1.nodeType == 1{
                                rightNextLaplacianPercent = nextDetectResultNode1.laplacianVariance / nextnextDetectResultNode1.laplacianVariance
                            }
                            else if nextDetectResultNode1.nodeType == 0{
                                rightNextLaplacianPercent = nextDetectResultNode1.laplacianVariance / nextnextDetectResultNode1.laplacianVariance
                            }
                            else if nextDetectResultNode1.nodeType == 4 && self.laplacianDic[1][nextDetectResultNode1.singlefeatureIndex[0]] != 0{
                                rightNextLaplacianPercent = nextDetectResultNode1.laplacianVariance / self.laplacianDic[1][nextDetectResultNode1.singlefeatureIndex[0]]!
                            }

                            if leftNextLaplacianPercent < blurThreshold && rightNextLaplacianPercent >= blurThreshold{
                                detectSingleFeatureArray.insert(insertCard1, at: 0)
                                detectSingleFeatureArray.insert(insertCard0, at: 0)
                            }
                            else if rightNextLaplacianPercent < blurThreshold && leftNextLaplacianPercent >= blurThreshold{
                                detectSingleFeatureArray.insert(insertCard0, at: 0)
                                detectSingleFeatureArray.insert(insertCard1, at: 0)
                            }
                            //上一张和下一张两边都不模糊 直接比较上一张两边模糊程度
                            else if leftLaplacianPercent < blurThreshold && rightLaplacianPercent < blurThreshold{
                                if leftLaplacianPercent < rightLaplacianPercent{
                                    detectSingleFeatureArray.insert(insertCard0, at: 0)
                                    detectSingleFeatureArray.insert(insertCard1, at: 0)
                                }
                                else{
                                    detectSingleFeatureArray.insert(insertCard1, at: 0)
                                    detectSingleFeatureArray.insert(insertCard0, at: 0)
                                }
                            }
                            else{
                                if leftNextLaplacianPercent < rightNextLaplacianPercent{
                                    detectSingleFeatureArray.insert(insertCard1, at: 0)
                                    detectSingleFeatureArray.insert(insertCard0, at: 0)
                                }
                                else{
                                    detectSingleFeatureArray.insert(insertCard0, at: 0)
                                    detectSingleFeatureArray.insert(insertCard1, at: 0)
                                }
                            }

                        }
                    }

                    else{
                        if nodeType0 == 4 || nodeType0 == 2{
                            detectSingleFeatureArray.insert(insertCard0, at: 0)
                        }
                        if nodeType1 == 4 || nodeType1 == 2{
                            detectSingleFeatureArray.insert(insertCard1, at: 0)
                        }
                    }
                }
            }
        }

        var uniqueArray: [Int] = []
        for singlefeature in detectSingleFeatureArray {
            if let existIndex = uniqueArray.firstIndex(of: singlefeature.cardIndex){
                if singlefeature.confidence > confidenceDic[singlefeature.cardIndex] ?? 0{
                    confidenceDic[singlefeature.cardIndex] = singlefeature.confidence
                    uniqueArray.append(singlefeature.cardIndex)
                    uniqueArray.remove(at: existIndex)
                    let chainIndex = detectSingleFeatureArray.firstIndex { $0 === singlefeature } ?? -1
                    print("delete chain \(chainIndex) \(existIndex)/\(uniqueArray.count) \(singlefeatureLabelDic[singlefeature.cardIndex]!)")
                }
            }
            else if singlefeature.confidence >= 0.5{
                confidenceDic[singlefeature.cardIndex] = singlefeature.confidence
                uniqueArray.append(singlefeature.cardIndex)
            }
        }

        isShort = uniqueArray.count < min(minSingleFeatureNum,10)

        print("handle result \(uniqueArray.count) \(minSingleFeatureNum) isShort\(isShort)")

        let result = DetectionState(detectionResult: uniqueArray, isSingle: isSingle, isShort: isShort, longestIndex: longestIndex)
        return result
    }
}
