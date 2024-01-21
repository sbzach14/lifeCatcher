
import AVFoundation
import Accelerate
import UIKit
import SwiftUI
import Combine

func ComputeROILaplacianVariance(box: [Float], destinationBuffer8: vImage.PixelBuffer<vImage.Planar8>) -> Float{
    // 定义感兴趣区域
    let centerX = box[0] * Float(destinationBuffer8.width)
    let centerY = box[1] * Float(destinationBuffer8.height)
    let widthX = box[2] * Float(destinationBuffer8.width)
    let heightY = box[3] * Float(destinationBuffer8.height)
    
    let regionOfInterest = CGRect(x: CGFloat(centerX - widthX / 2), y: CGFloat(centerY - heightY / 2), width: CGFloat(widthX), height: CGFloat(heightY))
    var variance:Float = 0
    // 调用 withUnsafeRegionOfInterest 方法
    destinationBuffer8.withUnsafeRegionOfInterest(regionOfInterest) { roiBuffer in
        // 在闭包中执行对感兴趣区域的操作
        // roiBuffer 是感兴趣区域的 vImage.PixelBuffer
        
        var laplacianStorage = UnsafeMutableBufferPointer<Float>.allocate(capacity: roiBuffer.width * roiBuffer.height)
        let laplacianBuffer = vImage.PixelBuffer(data: laplacianStorage.baseAddress!,
                                                 width: roiBuffer.width,
                                                 height: roiBuffer.height,
                                                 byteCountPerRow: roiBuffer.width * MemoryLayout<Float>.stride,
                                                 pixelFormat: vImage.PlanarF.self)
        defer {
            laplacianStorage.deallocate()
        }
        
        roiBuffer.convert(to: laplacianBuffer)
        vDSP.convolve(laplacianStorage,
                      rowCount: roiBuffer.height,
                      columnCount: roiBuffer.width,
                      with3x3Kernel: BlurDetector_8.laplacian,
                      result: &laplacianStorage)
        
        variance = laplacianBuffer.variance
    }
    return variance
}

class BlurDetector_8{
    
    static var sourceFormat8 = vImage_CGImageFormat(
        bitsPerComponent: 8,
        bitsPerPixel: 8 * 4,
        colorSpace: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue))!
    
    static var sourceFormatF = vImage_CGImageFormat(
        bitsPerComponent: 32,
        bitsPerPixel: 32 * 4,
        colorSpace: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGBitmapInfo(
            rawValue: kCGBitmapByteOrder32Host.rawValue |
            CGBitmapInfo.floatComponents.rawValue |
            CGImageAlphaInfo.noneSkipFirst.rawValue))!
    
    static var destinationFormat8 = vImage_CGImageFormat(
        bitsPerComponent: 8,
        bitsPerPixel: 8,
        colorSpace: CGColorSpaceCreateDeviceGray(),
        bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue))!
    
    static var destinationFormatF = vImage_CGImageFormat(
        bitsPerComponent: 32,
        bitsPerPixel: 32,
        colorSpace: CGColorSpaceCreateDeviceGray(),
        bitmapInfo: CGBitmapInfo(
            rawValue: kCGBitmapByteOrder32Host.rawValue |
            CGBitmapInfo.floatComponents.rawValue |
            CGImageAlphaInfo.none.rawValue))!
    
    static let defaultRedCoefficient: Float = 0.2126
    static let defaultGreenCoefficient: Float = 0.7152
    static let defaultBlueCoefficient: Float = 0.0722
    static let laplacian: [Float] = [-1, -1, -1,
                                       -1,  8, -1,
                                       -1, -1, -1]
    
    let model = try! cardDetection_n_0121()
    @Published var cameraImage : CGImage?

    
    
    func BlurDetectSingleTest() -> Float {
        
        let imagePath = Bundle.main.path(forResource: "001522", ofType: "jpg")!
        let image = UIImage(contentsOfFile: imagePath)!
        let ciImage = CIImage(image: image)!
        //let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent)!
        let pixelBuffer = createCVPixelBuffer(ciImage:ciImage, targetSize: CGSize(width: 640, height: 480), targetArea: [0,0,0,0])!
        let newCIImage = CIImage(cvImageBuffer: pixelBuffer)
        let cgImage = CIContext().createCGImage(newCIImage, from: newCIImage.extent)!
        
        
        
        /// The 8-bit-per-channel, 4-channel source pixel buffer.
        let sourceBuffer8 = try! vImage.PixelBuffer<vImage.Interleaved8x4>(
            cgImage: cgImage,
            cgImageFormat: &BlurDetector_8.sourceFormat8)
        
        
        /// The 8-bit planar destination pixel buffer.
        var destinationBuffer8 = vImage.PixelBuffer<vImage.Planar8>(width: 640,
                                                                    height: 480)
        
        
        
//        cameraImage = rescaleBuffer8.makeCGImage(
//            cgImageFormat: BlurDetector_8.sourceFormat8)!
//        let savedUIImage = UIImage(cgImage: cameraImage!)
//        UIImageWriteToSavedPhotosAlbum(savedUIImage, self, nil, nil)
        
                
        
        
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
        
        
        
        let newresult = try! model.prediction(image: pixelBuffer, iouThreshold: 0.45, confidenceThreshold: 0.25)
        print(newresult.coordinates)
        
        let cnt = Int(newresult.coordinates.shape[0])
        var lapResult : [Float] = []
        for i in 0..<cnt {
            let centerX = CGFloat(newresult.coordinates[i*4]) * 640
            let centerY = CGFloat(newresult.coordinates[i*4+1]) * 480
            let widthX = CGFloat(newresult.coordinates[i*4+2]) * 640
            let heightY = CGFloat(newresult.coordinates[i*4+3]) * 480
            
            // 定义感兴趣区域
            let regionOfInterest = CGRect(x: centerX - widthX / 2, y: centerY - heightY / 2, width: widthX, height: heightY)

            // 调用 withUnsafeRegionOfInterest 方法
            destinationBuffer8.withUnsafeRegionOfInterest(regionOfInterest) { roiBuffer in
                // 在闭包中执行对感兴趣区域的操作
                // roiBuffer 是感兴趣区域的 vImage.PixelBuffer
                
                var laplacianStorage = UnsafeMutableBufferPointer<Float>.allocate(capacity: roiBuffer.width * roiBuffer.height)
                let laplacianBuffer = vImage.PixelBuffer(data: laplacianStorage.baseAddress!,
                                                         width: roiBuffer.width,
                                                         height: roiBuffer.height,
                                                         byteCountPerRow: roiBuffer.width * MemoryLayout<Float>.stride,
                                                         pixelFormat: vImage.PlanarF.self)
                defer {
                    laplacianStorage.deallocate()
                }

                roiBuffer.convert(to: laplacianBuffer)
                vDSP.convolve(laplacianStorage,
                              rowCount: roiBuffer.height,
                              columnCount: roiBuffer.width,
                              with3x3Kernel: BlurDetector_8.laplacian,
                              result: &laplacianStorage)
    
                let variance = laplacianBuffer.variance
                lapResult.append(variance)
                print(variance)
            }
        }
        
        return 1
    }
}
