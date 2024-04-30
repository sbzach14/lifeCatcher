import UIKit
import CoreVideo
import CoreImage
import CoreMedia
import MobileCoreServices
import Foundation
import Accelerate

// 在CVPixelBuffer上绘制红色矩形框的函数
func drawRectanglesOnPixelBuffer(pixelBuffer: CVPixelBuffer, rectList: [[Float]]) -> CVPixelBuffer?{
    // 创建图形上下文
    CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
    let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
    let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
    let width = CVPixelBufferGetWidth(pixelBuffer)
    let height = CVPixelBufferGetHeight(pixelBuffer)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo: UInt32 = CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
    guard let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
        return nil
    }
    
    // 设置绘制属性
    context.setStrokeColor(UIColor.red.cgColor)
    context.setLineWidth(2.0)
    
    for coor in rectList{
        let x = Int((coor[0] - coor[2]/2)*Float(width))
        let y = Int(((1 - coor[1]) - coor[3]/2)*Float(height))
        let w = Int(coor[2]*Float(width))
        let h = Int(coor[3]*Float(height))
        
        let firstRect = CGRect(x: x, y: y, width: w, height: h)
        context.addRect(firstRect)
        context.strokePath()
    }
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
    
    return pixelBuffer
}


//处理ciimage，输出合适大小的pixelbuffer供模型输入
func createCVPixelBuffer(ciImage: CIImage, targetSize: CGSize, targetArea: [Float], isSavedImage: Bool = false) -> CVPixelBuffer? {
    
    // Extract target area from original image
    let xCenter = CGFloat(targetArea[0]) * ciImage.extent.width
    let yCenter = ciImage.extent.height - CGFloat(targetArea[1]) * ciImage.extent.height
    let width = CGFloat(targetArea[2]) * ciImage.extent.width
    let height = CGFloat(targetArea[3]) * ciImage.extent.height
    
    var croppedCIImage = ciImage
    
    if width != 0{
        croppedCIImage = ciImage.cropped(to: CGRect(x: xCenter - width / 2, y: yCenter - height / 2, width: width, height: height))
    }
    
        
    // Resize the image to the target size
    let resizedCIImage = croppedCIImage.resize(to: targetSize)
    // Apply translation
    let finalCIImage = resizedCIImage.transformed(by: CGAffineTransform(translationX: -resizedCIImage.extent.minX, y: -resizedCIImage.extent.minY))
    
    // Create a pixel buffer
    var pixelBuffer: CVPixelBuffer?
    let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(targetSize.width), Int(targetSize.height), kCVPixelFormatType_32ARGB, nil, &pixelBuffer)
    guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
        print("Unable to create CVPixelBuffer")
        return nil
    }
    
    // Lock the pixel buffer
    CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))

    // Get the pixel buffer's base address
    guard let baseAddress = CVPixelBufferGetBaseAddress(buffer) else {
        print("Unable to get pixel buffer base address")
        // Unlock the pixel buffer
        CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        return nil
    }

    // Create a CGColorSpace
    let colorSpace = CGColorSpaceCreateDeviceRGB()

    
    let context = CIContext()
    
    // Render the resized CIImage onto the pixel buffer
    context.render(finalCIImage, to: buffer, bounds: finalCIImage.extent, colorSpace: colorSpace)

    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))

    
    if isSavedImage{
        //创建图片文件并保存
        if let cgImage = CIContext()
            .createCGImage(resizedCIImage, from: resizedCIImage.extent){
            
            let desktopPath = "/Users/naldochen/Desktop"
            let destinationURL = URL(fileURLWithPath: desktopPath).appendingPathComponent("test.jpg")
            
            
            guard let destination = CGImageDestinationCreateWithURL(destinationURL as CFURL, kUTTypeJPEG, 1, nil) else {
                print("无法创建目标 URL")
                return nil
            }
            
            CGImageDestinationAddImage(destination, cgImage, nil)
            
            if CGImageDestinationFinalize(destination) {
                print("成功保存为 \(destinationURL.path)")
            } else {
                print("保存失败")
            }
        }
    }
    
    return buffer
}

extension CIImage {
    //图片比例适应
    func resize(to size: CGSize) -> CIImage {
        if self.extent.size.width == size.width && self.extent.size.height == size.height{
            return self
        }
        
        else{
            
            let originAr = self.extent.size.width / self.extent.size.height
            let targetAr = size.width / size.height
            
            let scaleX = size.width / self.extent.size.width
            let scaleY = size.height / self.extent.size.height
            return self.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
//            if (originAr >= 1 && targetAr >= 1) || (originAr <= 1 && targetAr <= 1){
//                let scaleX = size.width / self.extent.size.width
//                let scaleY = size.height / self.extent.size.height
//                return self.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
//            }
//            
//            else{
//                let rotationTransform = CGAffineTransform(rotationAngle: -.pi / 2)  // 顺时针旋转90度
//                let rotatedImage = self.transformed(by: rotationTransform)
//                
//                let xOffset = self.extent.size.height
//                let translationTransform = CGAffineTransform(translationX: xOffset, y: CGFloat(0))
//                let translatedImage = rotatedImage.transformed(by: translationTransform)
//                let scaleX = size.width / translatedImage.extent.size.width
//                let scaleY = size.height / translatedImage.extent.size.height
//                return translatedImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
//            }
        }
    }
}

func performHistogramEqualization(ciImage: CIImage) -> CIImage? {
    let context = CIContext()

    guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
        return nil
    }
    
    // 定义 vImage_CGImageFormat
    var cgImageFormat = vImage_CGImageFormat(
        bitsPerComponent: UInt32(cgImage.bitsPerComponent),
        bitsPerPixel: UInt32(cgImage.bitsPerPixel),
        colorSpace: Unmanaged.passUnretained(cgImage.colorSpace!),
        bitmapInfo: cgImage.bitmapInfo,
        version: 0,
        decode: nil,
        renderingIntent: cgImage.renderingIntent)


    do {
        // 将 CGImage 转换为 vImage.PixelBuffer
        let buffer = try vImage.PixelBuffer(
            cgImage: cgImage,
            cgImageFormat: &cgImageFormat,
            pixelFormat: vImage.Interleaved8x4.self)

        // 创建源和目标 vImage.PixelBuffer
        var sourceBuffer: vImage.PixelBuffer<vImage.Interleaved8x4> = buffer
        

        // 执行直方图均衡化
        sourceBuffer.equalizeHistogram(destination: sourceBuffer)
        
        // 将目标 vImage.PixelBuffer 转换为 CGImage
        let equalizedCGImage = try sourceBuffer.makeCGImage(cgImageFormat: cgImageFormat)
        
        // 将 CGImage 转换为 UIImage
        let equalizedImage = CIImage(cgImage: equalizedCGImage!)
        
        return equalizedImage
    } catch {
        print("Error: \(error)")
        return nil
    }
}
