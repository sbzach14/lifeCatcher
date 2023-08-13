import UIKit
import CoreVideo
import CoreImage
import CoreMedia
import MobileCoreServices
import Foundation
import Accelerate

//处理ciimage，输出合适大小的pixelbuffer供模型输入
func createCVPixelBuffer(ciImage: CIImage, targetSize: CGSize, isSavedImage: Bool = false) -> CVPixelBuffer? {
    
    // Resize the image to the target size
    let resizedCIImage = ciImage.resize(to: targetSize)
    
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
    context.render(resizedCIImage, to: buffer, bounds: resizedCIImage.extent, colorSpace: colorSpace)

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
            
            //如果长宽颠倒则先旋转90度再缩放
            if (originAr > 1 && targetAr > 1) || (originAr < 1 && targetAr < 1){
                let scaleX = size.width / self.extent.size.width
                let scaleY = size.height / self.extent.size.height
                return self.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
            }
            
            //长宽不颠倒直接进行缩放
            else{
                let rotationTransform = CGAffineTransform(rotationAngle: -.pi / 2)  // 顺时针旋转90度
                let rotatedImage = self.transformed(by: rotationTransform)
                
                let xOffset = self.extent.size.height
                let translationTransform = CGAffineTransform(translationX: xOffset, y: CGFloat(0))
                let translatedImage = rotatedImage.transformed(by: translationTransform)
                let scaleX = size.width / translatedImage.extent.size.width
                let scaleY = size.height / translatedImage.extent.size.height
                return translatedImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
            }
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
