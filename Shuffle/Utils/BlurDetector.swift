
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
    
}
