import UIKit
import CoreVideo
import CoreImage
import CoreMedia
import MobileCoreServices
import Foundation
import Accelerate

func cropTest()->CGImage{
    
    let imagePath = Bundle.main.path(forResource: "IMG_4619 2", ofType: "JPG")!
    let image = UIImage(contentsOfFile: imagePath)!
    let originalImage = CIImage(image: image)!
    
    let model = ViewModel()
    model.originSize = [1920, 1080]
    let pixelBuffer = createCVPixelBuffer(ciImage:originalImage, targetSize: CGSize(width: 640, height: 480), targetArea: [0,0,0,0])!
    model.processImageOrigin(pixelBuffer, taskIndex: 0)
    model.isHorizon = true
    print(model.lastBoxes)
    model.computeTargetArea()
    print(model.targetArea)
    let newpixelBuffer = createCVPixelBuffer(ciImage:originalImage, targetSize: CGSize(width: 640, height: 480), targetArea: model.targetArea)!
    
    let ciImage = CIImage(cvPixelBuffer: newpixelBuffer)
    let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent)!
    
//    // 框的参数
//    let boxRect = CGRect(x: 0, y: 0, width: 300, height: 400)
//
//    // 用 CIFilter 创建包含框的新 CIImage
//    let boxImage = originalImage.cropped(to: boxRect)
//    
//    var cgImage = CIContext().createCGImage(boxImage, from: boxImage.extent)!
//    
//    
//    
//    /// The 8-bit-per-channel, 4-channel source pixel buffer.
//    let sourceBuffer8 = try! vImage.PixelBuffer<vImage.Interleaved8x4>(
//        cgImage: cgImage,
//        cgImageFormat: &BlurDetector_8.sourceFormat8)
//    
//    
//    /// The 8-bit planar destination pixel buffer.
//    var destinationBuffer8 = vImage.PixelBuffer<vImage.Planar8>(width: 300,
//                                                                height: 400)
//    
//    
//    
////        cameraImage = rescaleBuffer8.makeCGImage(
////            cgImageFormat: BlurDetector_8.sourceFormat8)!
////        let savedUIImage = UIImage(cgImage: cameraImage!)
////        UIImageWriteToSavedPhotosAlbum(savedUIImage, self, nil, nil)
//    
//            
//    
//    
//    let divisor: Int = 0x1000
//    let fDivisor = Float(divisor)
//    
//    sourceBuffer8.multiply(by: (0,
//                                Int(BlurDetector_8.defaultRedCoefficient * fDivisor),
//                                Int(BlurDetector_8.defaultGreenCoefficient * fDivisor),
//                                Int(BlurDetector_8.defaultBlueCoefficient * fDivisor)),
//                           divisor: divisor,
//                           preBias: (0, 0, 0, 0),
//                           postBias: 0,
//                           destination: destinationBuffer8)
//    
//    
//        let centerX = 100
//        let centerY = 100
//        let widthX = 200
//        let heightY = 200
//        
//        // 定义感兴趣区域
//        let regionOfInterest = CGRect(x: centerX - widthX / 2, y: centerY - heightY / 2, width: widthX, height: heightY)
//
//        // 调用 withUnsafeRegionOfInterest 方法
//        destinationBuffer8.withUnsafeRegionOfInterest(regionOfInterest) { roiBuffer in
//            // 在闭包中执行对感兴趣区域的操作
//            // roiBuffer 是感兴趣区域的 vImage.PixelBuffer
//            
//            cgImage = roiBuffer.makeCGImage(cgImageFormat: BlurDetector_8.destinationFormat8)!
//        }

    return cgImage
}

//处理ciimage，输出合适大小的pixelbuffer供模型输入
func createCVPixelBuffer(ciImage: CIImage, targetSize: CGSize, targetArea: [Float], isSavedImage: Bool = false) -> CVPixelBuffer? {
    
    // Extract target area from original image
    let xCenter = CGFloat(targetArea[0])
    let yCenter = ciImage.extent.height - CGFloat(targetArea[1])
    let width = CGFloat(targetArea[2])
    let height = CGFloat(targetArea[3])
    
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
            
            if (originAr > 1 && targetAr > 1) || (originAr < 1 && targetAr < 1){
                let scaleX = size.width / self.extent.size.width
                let scaleY = size.height / self.extent.size.height
                return self.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
            }
            
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
