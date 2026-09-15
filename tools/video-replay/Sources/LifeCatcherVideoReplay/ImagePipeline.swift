import Accelerate
import CoreImage
import CoreVideo
import Foundation

enum ImagePipeline {
    static let context = CIContext(options: [.cacheIntermediates: false])
    static let cameraSize = CGSize(width: 1920, height: 1080)

    static func normalizeCameraFrame(_ source: CVPixelBuffer, rotation: FrameRotation) throws -> CVPixelBuffer {
        let image = orientedImage(source, rotation: rotation)
        return try render(image: image, targetSize: cameraSize, pixelFormat: kCVPixelFormatType_32BGRA)
    }

    /// Produces the same rotated axes as `normalizeCameraFrame`, but keeps the
    /// rotated source's natural pixel dimensions (for example 720×1280 becomes
    /// 1280×720) instead of resizing to the production 1920×1080 camera size.
    static func rotatedFramePreservingSize(_ source: CVPixelBuffer, rotation: FrameRotation) throws -> CVPixelBuffer {
        let image = orientedImage(source, rotation: rotation)
        return try render(image: image, targetSize: image.extent.size, pixelFormat: kCVPixelFormatType_32BGRA)
    }

    private static func orientedImage(_ source: CVPixelBuffer, rotation: FrameRotation) -> CIImage {
        var image = CIImage(cvPixelBuffer: source)
        let resolvedRotation: FrameRotation
        if rotation == .auto {
            resolvedRotation = CVPixelBufferGetHeight(source) > CVPixelBufferGetWidth(source)
                ? .counterclockwise
                : .none
        } else {
            resolvedRotation = rotation
        }
        switch resolvedRotation {
        case .auto, .none:
            break
        case .clockwise:
            image = image.oriented(.right)
        case .counterclockwise:
            image = image.oriented(.left)
        }
        return image
    }

    static func modelInput(
        cameraFrame: CVPixelBuffer,
        targetSize: CGSize,
        targetArea: [Float]
    ) throws -> CVPixelBuffer {
        let image = CIImage(cvPixelBuffer: cameraFrame)
        let xCenter = CGFloat(targetArea[0]) * image.extent.width
        let yCenter = image.extent.height - CGFloat(targetArea[1]) * image.extent.height
        let width = CGFloat(targetArea[2]) * image.extent.width
        let height = CGFloat(targetArea[3]) * image.extent.height

        let cropped: CIImage
        if width != 0 {
            let cropRect = CGRect(
                x: xCenter - width / 2,
                y: yCenter - height / 2,
                width: width,
                height: height
            )
            let gray = CGFloat(114.0 / 255.0)
            let background = CIImage(
                color: CIColor(red: gray, green: gray, blue: gray, alpha: 1)
            ).cropped(to: cropRect)
            cropped = image.composited(over: background).cropped(to: cropRect)
        } else {
            cropped = image
        }
        return try render(image: cropped, targetSize: targetSize, pixelFormat: kCVPixelFormatType_32ARGB)
    }

    static func blackCameraFrame() throws -> CVPixelBuffer {
        try render(
            image: CIImage(color: .black).cropped(to: CGRect(origin: .zero, size: cameraSize)),
            targetSize: cameraSize,
            pixelFormat: kCVPixelFormatType_32BGRA
        )
    }

    private static func render(image: CIImage, targetSize: CGSize, pixelFormat: OSType) throws -> CVPixelBuffer {
        let scaleX = targetSize.width / image.extent.width
        let scaleY = targetSize.height / image.extent.height
        let resized = image
            .transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
            .transformed(by: CGAffineTransform(
                translationX: -image.extent.minX * scaleX,
                y: -image.extent.minY * scaleY
            ))

        var buffer: CVPixelBuffer?
        let attributes: [CFString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true,
            kCVPixelBufferIOSurfacePropertiesKey: [:]
        ]
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(targetSize.width),
            Int(targetSize.height),
            pixelFormat,
            attributes as CFDictionary,
            &buffer
        )
        guard status == kCVReturnSuccess, let buffer else {
            throw ReplayError.image("创建 CVPixelBuffer 失败：\(status)")
        }
        context.render(
            resized,
            to: buffer,
            bounds: CGRect(origin: .zero, size: targetSize),
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )
        return buffer
    }
}

enum BlurDetector {
    static var sourceFormat = vImage_CGImageFormat(
        bitsPerComponent: 8,
        bitsPerPixel: 32,
        colorSpace: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue)
    )!

    static let red: Float = 0.2126
    static let green: Float = 0.7152
    static let blue: Float = 0.0722
    static let laplacian: [Float] = [-1, -1, -1, -1, 8, -1, -1, -1, -1]

    static func planarBuffer(from pixelBuffer: CVPixelBuffer) throws -> vImage.PixelBuffer<vImage.Planar8> {
        let image = CIImage(cvPixelBuffer: pixelBuffer)
        guard let cgImage = ImagePipeline.context.createCGImage(image, from: image.extent) else {
            throw ReplayError.image("无法为清晰度计算生成 CGImage")
        }
        let source = try vImage.PixelBuffer<vImage.Interleaved8x4>(
            cgImage: cgImage,
            cgImageFormat: &sourceFormat
        )
        let destination = vImage.PixelBuffer<vImage.Planar8>(width: source.width, height: source.height)
        let divisor = 0x1000
        let floatDivisor = Float(divisor)
        source.multiply(
            by: (
                0,
                Int(red * floatDivisor),
                Int(green * floatDivisor),
                Int(blue * floatDivisor)
            ),
            divisor: divisor,
            preBias: (0, 0, 0, 0),
            postBias: 0,
            destination: destination
        )
        return destination
    }

    static func laplacianVariance(
        box: [Float],
        planarBuffer: vImage.PixelBuffer<vImage.Planar8>
    ) -> Float {
        let centerX = box[0] * Float(planarBuffer.width)
        let centerY = box[1] * Float(planarBuffer.height)
        let width = max(1, box[2] * Float(planarBuffer.width))
        let height = max(1, box[3] * Float(planarBuffer.height))
        let rawROI = CGRect(
            x: CGFloat(centerX - width / 2),
            y: CGFloat(centerY - height / 2),
            width: CGFloat(width),
            height: CGFloat(height)
        )
        let bounds = CGRect(x: 0, y: 0, width: planarBuffer.width, height: planarBuffer.height)
        let roi = rawROI.integral.intersection(bounds)
        guard roi.width >= 3, roi.height >= 3 else { return 0 }

        var variance: Float = 0
        planarBuffer.withUnsafeRegionOfInterest(roi) { roiBuffer in
            var storage = UnsafeMutableBufferPointer<Float>.allocate(capacity: roiBuffer.width * roiBuffer.height)
            defer { storage.deallocate() }
            let laplacianBuffer = vImage.PixelBuffer(
                data: storage.baseAddress!,
                width: roiBuffer.width,
                height: roiBuffer.height,
                byteCountPerRow: roiBuffer.width * MemoryLayout<Float>.stride,
                pixelFormat: vImage.PlanarF.self
            )
            roiBuffer.convert(to: laplacianBuffer)
            vDSP.convolve(
                storage,
                rowCount: roiBuffer.height,
                columnCount: roiBuffer.width,
                with3x3Kernel: laplacian,
                result: &storage
            )
            variance = laplacianBuffer.variance
        }
        return variance
    }
}

// Compatibility names intentionally match the production implementation so the
// frame-to-detection method can stay textually aligned with the iOS source.
typealias BlurDetector_8 = BlurDetector

extension BlurDetector {
    static var sourceFormat8: vImage_CGImageFormat {
        get { sourceFormat }
        set { sourceFormat = newValue }
    }
    static let defaultRedCoefficient = red
    static let defaultGreenCoefficient = green
    static let defaultBlueCoefficient = blue
}

func ComputeROILaplacianVariance(
    box: [Float],
    destinationBuffer8: vImage.PixelBuffer<vImage.Planar8>
) -> Float {
    BlurDetector.laplacianVariance(box: box, planarBuffer: destinationBuffer8)
}

extension AccelerateMutableBuffer where Element == Float {
    var variance: Float {
        var mean = Float.nan
        var standardDeviation = Float.nan
        withUnsafeBufferPointer {
            vDSP_normalize(
                $0.baseAddress!,
                1,
                nil,
                1,
                &mean,
                &standardDeviation,
                vDSP_Length(count)
            )
        }
        return standardDeviation * standardDeviation
    }
}
