import Accelerate
import CoreImage
import CoreML
import CoreVideo
import Foundation

// Copied from the production frame normalizer; only the CIContext owner differs.
extension RecognitionEngine {
    func getSingleFeature(from singlefeatureArray: MLMultiArray, from boxArray : MLMultiArray, from pixelBuffer : CVPixelBuffer, from iscls : Bool) -> ([DetectionResult], Int) {
        let cnt : Int = Int(singlefeatureArray.shape[0])
        let n : Int = Int(singlefeatureArray.shape[1])
        var result : [DetectionResult] = []


        if !iscls{
            for i in 0..<cnt {
                var maxVal: Float32 = singlefeatureArray[i * n].floatValue
                var confidenceSum : Float = 0
                var singlefeatureIndex : [Int] = []
                var confidence : [Float] = []
                for j in 0..<n {
                    let index = i * n + j
                    let value = singlefeatureArray[index].floatValue
                    confidenceSum += value
                }
                for j in 0..<n {
                    let index = i * n + j
                    let value = singlefeatureArray[index].floatValue

                    let trueIndex = j == 52 ? 54 : j

                    if value > 0{

                        if (value/confidenceSum>=0) {
                            singlefeatureIndex.append(j)
                            confidence.append(value)
                        }

                        if value > maxVal {
                            maxVal = value
                        }
                    }
                }

                singlefeatureIndex.sort{singlefeatureArray[$0 + i*n].floatValue > singlefeatureArray[$1 + i*n].floatValue}
                confidence.sort{ $0 > $1 }

                let centerX = boxArray[i*4].floatValue
                let centerY = boxArray[i*4+1].floatValue
                let widthX = boxArray[i*4+2].floatValue
                let heightY = boxArray[i*4+3].floatValue

                let coordinate = [centerX, centerY, widthX, heightY]

                if singlefeatureIndex.count > 0{
                    if let index = result.firstIndex(where: {
                        abs($0.coordinate[0] - coordinate[0]) < ($0.coordinate[2] + coordinate[2]) / 2
                         && abs($0.coordinate[1] - coordinate[1]) < ($0.coordinate[3] + coordinate[3]) / 2
                    }) {

                        if maxVal > result[index].confidence[0] {
                            result[index].singlefeatureIndex = singlefeatureIndex + result[index].singlefeatureIndex
                            result[index].confidence = confidence + result[index].confidence
                        }
                        else{
                            result[index].singlefeatureIndex = result[index].singlefeatureIndex + singlefeatureIndex
                            result[index].confidence = result[index].confidence + confidence
                        }
                    }
                    else{
                        result.append(DetectionResult(singlefeatureIndex: singlefeatureIndex, confidence: confidence, confidencePercent: maxVal/confidenceSum, coordinate: coordinate, laplacianVariance: 0))
                    }
                }
            }

            var uniqueNum = result.count

            if result.count > 2{
                result.sort{$0.confidence[0] > $1.confidence[0]}
                result.removeLast(result.count - 2)
            }


            if result.count == 2{
                if self.isCameraHorizon && result[0].coordinate[0] > result[1].coordinate[0]{
                        result.swapAt(0, 1)
                    }
            else if !self.isCameraHorizon && result[0].coordinate[1] > result[1].coordinate[1]{
                        result.swapAt(0, 1)
                    }
            }
            else if result.count == 1{
                result.insert(DetectionResult(singlefeatureIndex: [-1], confidence: [0.001], confidencePercent: 0, coordinate: result[0].coordinate, laplacianVariance: 0), at: 1)
            }
            else if result.count == 0{
                result.append(DetectionResult(singlefeatureIndex: [-1], confidence: [0.001], confidencePercent: 0, coordinate: lastBoxes[0], laplacianVariance: 0))
                result.append(DetectionResult(singlefeatureIndex: [-1], confidence: [0.001], confidencePercent: 0, coordinate: lastBoxes[1], laplacianVariance: 0))
            }

            for resultIndex in 0..<result.count{
                result[resultIndex].singlefeatureIndex = result[resultIndex].singlefeatureIndex.map { $0 == 52 ? 54 : $0 }
            }
            return (result, uniqueNum)
        }

        else{

            let newCIImage = CIImage(cvImageBuffer: pixelBuffer)
            let cgImage = ImagePipeline.context.createCGImage(newCIImage, from: newCIImage.extent)!

            /// The 8-bit-per-channel, 4-channel source pixel buffer.
            let sourceBuffer8 = try! vImage.PixelBuffer<vImage.Interleaved8x4>(
                cgImage: cgImage,
                cgImageFormat: &BlurDetector_8.sourceFormat8)


            /// The 8-bit planar destination pixel buffer.
            let destinationBuffer8 = vImage.PixelBuffer<vImage.Planar8>(width: sourceBuffer8.width,
                                                                        height: sourceBuffer8.height)

            let divisor: Int = 0x1000
            let fDivisor = Float(divisor)

            sourceBuffer8.multiply(by: (0,
                                        Int(BlurDetector_8.defaultRedCoefficient * fDivisor),
                                        Int(BlurDetector_8.defaultGreenCoefficient * fDivisor),
                                        Int(BlurDetector_8.defaultBlueCoefficient * fDivisor)),
                                   divisor: divisor,
                                   preBias: (0, 0, 0, 0),
                                   postBias: 0,
                                   destination: destinationBuffer8)

            for i in 0..<cnt {
                var maxVal: Float32 = singlefeatureArray[i * n].floatValue
                var confidenceSum : Float = 0
                var singlefeatureIndex : [Int] = []
                var confidence : [Float] = []
                for j in 0..<n {
                    let index = i * n + j
                    let value = singlefeatureArray[index].floatValue
                    confidenceSum += value
                }
                for j in 0..<n {
                    let index = i * n + j
                    let value = singlefeatureArray[index].floatValue

                    let trueIndex = j == 52 ? 54 : j

                    if value > 0 && self.allSingleFeatureIndex.contains(trueIndex){

                        if (value/confidenceSum>=0) {
                            singlefeatureIndex.append(j)
                            confidence.append(value)
                        }

                        if value > maxVal {
                            maxVal = value
                        }
                    }
                }

                singlefeatureIndex.sort{singlefeatureArray[$0 + i*n].floatValue > singlefeatureArray[$1 + i*n].floatValue}
                confidence.sort{ $0 > $1 }

                let centerX = boxArray[i*4].floatValue
                let centerY = boxArray[i*4+1].floatValue
                let widthX = boxArray[i*4+2].floatValue
                let heightY = boxArray[i*4+3].floatValue

                let coordinate = [centerX, centerY, widthX, heightY]

                if singlefeatureIndex.count > 0{
                    if self.state == "shuffle" || self.state == "riffle"{
                        if let index = result.firstIndex(where: {
                            abs($0.coordinate[0] - coordinate[0]) < ($0.coordinate[2] + coordinate[2]) / 2
                            && abs($0.coordinate[1] - coordinate[1]) < ($0.coordinate[3] + coordinate[3]) / 2
                        }) {

                            if maxVal > result[index].confidence[0] {
                                result[index].singlefeatureIndex = singlefeatureIndex + result[index].singlefeatureIndex
                                result[index].confidence = confidence + result[index].confidence
                            }
                            else{
                                result[index].singlefeatureIndex = result[index].singlefeatureIndex + singlefeatureIndex
                                result[index].confidence = result[index].confidence + confidence
                            }
                        }
                        else{
                            result.append(DetectionResult(singlefeatureIndex: singlefeatureIndex, confidence: confidence, confidencePercent: maxVal/confidenceSum, coordinate: coordinate, laplacianVariance: 0))
                        }
                    }
                    else{
                        result.append(DetectionResult(singlefeatureIndex: singlefeatureIndex, confidence: confidence, confidencePercent: maxVal/confidenceSum, coordinate: coordinate, laplacianVariance: 0))
                    }
                }
            }

            if result.count > 2{
                var uniqueSingleFeatureIndexes = Set<Int>()

                result = result.filter {
                    let singlefeatureIndex0 = $0.singlefeatureIndex[0]
                    if uniqueSingleFeatureIndexes.contains(singlefeatureIndex0) {
                        return false
                    } else {
                        uniqueSingleFeatureIndexes.insert(singlefeatureIndex0)
                        return true
                    }
                }
            }

            let uniqueNum = result.count

            if result.count > 2{
                result.sort{$0.confidence[0] > $1.confidence[0]}
                result.removeLast(result.count - 2)
            }


            if result.count == 2{
                //横向排列
                if self.isCameraHorizon && result[0].coordinate[0] > result[1].coordinate[0]{
                        result.swapAt(0, 1)
                    }
                //纵向排列
                else if !self.isCameraHorizon && result[0].coordinate[1] > result[1].coordinate[1]{
                        result.swapAt(0, 1)
                    }
            }
            else if result.count == 1{
                if self.state == "shuffle"{
                    if self.isCameraHorizon{
                        if result[0].coordinate[0] > self.centerPos[0]{
                            result.insert(DetectionResult(singlefeatureIndex: [-1], confidence: [0.001], confidencePercent: 0, coordinate: lastBoxes[0], laplacianVariance: 0), at: 0)
                        }
                        else{
                            result.insert(DetectionResult(singlefeatureIndex: [-1], confidence: [0.001], confidencePercent: 0, coordinate: lastBoxes[1], laplacianVariance: 0), at: 1)
                        }
                    }
                    else{
                        if result[0].coordinate[1] > self.centerPos[1]{
                            result.insert(DetectionResult(singlefeatureIndex: [-1], confidence: [0.001], confidencePercent: 0, coordinate: lastBoxes[0], laplacianVariance: 0), at: 0)
                        }
                        else{
                            result.insert(DetectionResult(singlefeatureIndex: [-1], confidence: [0.001], confidencePercent: 0, coordinate: lastBoxes[1], laplacianVariance: 0), at: 1)
                        }
                    }
                }
                else{
                    result.insert(DetectionResult(singlefeatureIndex: [-1], confidence: [0.001], confidencePercent: 0, coordinate: result[0].coordinate, laplacianVariance: 0), at: 1)
                }
            }
            else if result.count == 0{
                result.append(DetectionResult(singlefeatureIndex: [-1], confidence: [0.001], confidencePercent: 0, coordinate: lastBoxes[0], laplacianVariance: 0))
                result.append(DetectionResult(singlefeatureIndex: [-1], confidence: [0.001], confidencePercent: 0, coordinate: lastBoxes[1], laplacianVariance: 0))
            }



            for resultIndex in 0..<result.count{
                result[resultIndex].singlefeatureIndex = result[resultIndex].singlefeatureIndex.map { $0 == 52 ? 54 : $0 }
            }

            for resultIndex in 0..<result.count{
                result[resultIndex].laplacianVariance = ComputeROILaplacianVariance(box: result[resultIndex].coordinate, destinationBuffer8: destinationBuffer8)
            }
            return (result, uniqueNum)
        }
    }
}
