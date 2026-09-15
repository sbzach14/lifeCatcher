import AppKit
import CoreImage
import CoreVideo
import Foundation

private struct CameraBox: Codable {
    let x: Float
    let y: Float
    let width: Float
    let height: Float
}

private struct AnnotatedDetection: Codable {
    let classIndex: Int
    let label: String
    let confidence: Float
    let cameraBox: CameraBox
}

private struct FrameAnnotationRecord: Codable {
    let sourceFrame: Int
    let logicalTimeSeconds: Double
    let modelStage: InferenceStage
    let stateBefore: String
    let stateAfter: String
    let image: String
    let imageWidth: Int
    let imageHeight: Int
    let cameraROI: CameraBox
    let detections: [AnnotatedDetection]
}

final class FrameAnnotationWriter {
    private static let ownershipMarker = ".lifecatcher-video-replay-frames"
    private let directory: URL
    private let manifestHandle: FileHandle
    private let encoder = JSONEncoder()

    init(directory: URL) throws {
        self.directory = directory
        let manager = FileManager.default
        var isDirectory: ObjCBool = false
        if manager.fileExists(atPath: directory.path, isDirectory: &isDirectory) {
            guard isDirectory.boolValue else {
                throw ReplayError.image("逐帧输出路径不是目录：\(directory.path)")
            }
            let directoryValues = try directory.resourceValues(forKeys: [.isSymbolicLinkKey])
            guard directoryValues.isSymbolicLink != true else {
                throw ReplayError.image("逐帧输出目录不能是符号链接：\(directory.path)")
            }
            try Self.removePreviousExports(in: directory, manager: manager)
        } else {
            try manager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        let markerURL = directory.appendingPathComponent(Self.ownershipMarker)
        try Data("lifeCatcher video replay frames\n".utf8).write(to: markerURL, options: .atomic)
        let manifestURL = directory.appendingPathComponent("frames.jsonl")
        guard manager.createFile(atPath: manifestURL.path, contents: nil) else {
            throw ReplayError.image("无法创建逐帧索引：\(manifestURL.path)")
        }
        manifestHandle = try FileHandle(forWritingTo: manifestURL)
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
    }

    private static func removePreviousExports(in directory: URL, manager: FileManager) throws {
        let keys: Set<URLResourceKey> = [.isDirectoryKey, .isRegularFileKey, .isSymbolicLinkKey]
        let contents = try manager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: Array(keys),
            options: []
        )
        var removable: [URL] = []
        var unknown: [String] = []
        for item in contents {
            let values = try item.resourceValues(forKeys: keys)
            let name = item.lastPathComponent
            guard values.isDirectory != true,
                  values.isSymbolicLink != true,
                  values.isRegularFile == true,
                  isGeneratedFile(name) else {
                unknown.append(name)
                continue
            }
            removable.append(item)
        }
        guard unknown.isEmpty else {
            let preview = unknown.sorted().prefix(5).joined(separator: "、")
            throw ReplayError.image(
                "逐帧输出目录含非工具文件，拒绝自动清空：\(preview)。请改用专用输出目录：\(directory.path)"
            )
        }
        for item in removable {
            try manager.removeItem(at: item)
        }
    }

    private static func isGeneratedFile(_ name: String) -> Bool {
        if name == ownershipMarker || name == "frames.jsonl" || name == ".DS_Store" || name == ".localized" {
            return true
        }
        guard name.hasPrefix("frame_"), name.hasSuffix(".png") else { return false }
        let digits = name.dropFirst("frame_".count).dropLast(".png".count)
        return digits.count >= 6 && digits.allSatisfy(\.isNumber)
    }

    deinit {
        try? manifestHandle.close()
    }

    func write(exportedFrame: CVPixelBuffer, inference: FrameInference) throws {
        let width = CVPixelBufferGetWidth(exportedFrame)
        let height = CVPixelBufferGetHeight(exportedFrame)
        let cameraROI = normalizedBox(inference.cameraROI)
        let detections = inference.detections.map {
            AnnotatedDetection(
                classIndex: $0.classIndex,
                label: $0.label,
                confidence: $0.confidence,
                cameraBox: normalizedBox($0.cameraBox)
            )
        }
        let filename = String(format: "frame_%06d.png", inference.logicalFrame)
        let imageURL = directory.appendingPathComponent(filename)
        try render(
            exportedFrame: exportedFrame,
            width: width,
            height: height,
            inference: inference,
            cameraROI: cameraROI,
            detections: detections,
            outputURL: imageURL
        )

        let record = FrameAnnotationRecord(
            sourceFrame: inference.logicalFrame,
            logicalTimeSeconds: Double(inference.logicalFrame) / Double(inference.logicalFPS),
            modelStage: inference.stage,
            stateBefore: inference.stateBefore,
            stateAfter: inference.stateAfter,
            image: filename,
            imageWidth: width,
            imageHeight: height,
            cameraROI: cameraROI,
            detections: detections
        )
        var data = try encoder.encode(record)
        data.append(0x0A)
        try manifestHandle.write(contentsOf: data)
    }

    private func render(
        exportedFrame: CVPixelBuffer,
        width: Int,
        height: Int,
        inference: FrameInference,
        cameraROI: CameraBox,
        detections: [AnnotatedDetection],
        outputURL: URL
    ) throws {
        let image = CIImage(cvPixelBuffer: exportedFrame)
        guard let cameraCGImage = ImagePipeline.context.createCGImage(image, from: image.extent),
              let bitmap = NSBitmapImageRep(
                bitmapDataPlanes: nil,
                pixelsWide: width,
                pixelsHigh: height,
                bitsPerSample: 8,
                samplesPerPixel: 4,
                hasAlpha: true,
                isPlanar: false,
                colorSpaceName: .deviceRGB,
                bytesPerRow: 0,
                bitsPerPixel: 0
              ),
              let graphics = NSGraphicsContext(bitmapImageRep: bitmap) else {
            throw ReplayError.image("无法为第 \(inference.logicalFrame) 帧创建标注画布")
        }

        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = graphics
        let canvas = CGRect(x: 0, y: 0, width: width, height: height)
        NSImage(cgImage: cameraCGImage, size: canvas.size).draw(in: canvas, from: .zero, operation: .copy, fraction: 1)

        let roiRect = drawingRect(cameraROI, width: width, height: height)
        stroke(rect: roiRect, color: .systemTeal, lineWidth: 4)
        drawLabel(
            inference.stage == .detect ? "ROI: FULL FRAME / detect" : "ROI / cls",
            at: CGPoint(
                x: roiRect.minX + 3,
                y: inference.stage == .detect ? canvas.maxY - 58 : max(4, roiRect.maxY - 25)
            ),
            color: .systemTeal,
            canvas: canvas
        )

        let targetColor: NSColor = inference.stage == .detect ? .systemRed : .systemYellow
        for detection in detections {
            let rect = drawingRect(detection.cameraBox, width: width, height: height)
            stroke(rect: rect, color: targetColor, lineWidth: 4)
            drawLabel(
                "\(inference.stage.rawValue) \(detection.label) \(String(format: "%.3f", detection.confidence))",
                at: CGPoint(x: rect.minX, y: min(canvas.maxY - 28, rect.maxY + 3)),
                color: targetColor,
                canvas: canvas
            )
        }

        let header = "frame \(String(format: "%06d", inference.logicalFrame))  \(inference.stage.rawValue)  \(inference.stateBefore) → \(inference.stateAfter)  \(inference.logicalFPS)fps"
        drawHeader(header, canvas: canvas)
        NSGraphicsContext.restoreGraphicsState()

        guard let png = bitmap.representation(using: .png, properties: [:]) else {
            throw ReplayError.image("无法编码第 \(inference.logicalFrame) 帧 PNG")
        }
        try png.write(to: outputURL, options: .atomic)
    }

    private func normalizedBox(_ box: [Float]) -> CameraBox {
        guard box.count == 4 else { return CameraBox(x: 0, y: 0, width: 0, height: 0) }
        let minX = clamp(box[0] - box[2] / 2)
        let maxX = clamp(box[0] + box[2] / 2)
        let minY = clamp(box[1] - box[3] / 2)
        let maxY = clamp(box[1] + box[3] / 2)
        return CameraBox(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    private func clamp(_ value: Float) -> Float {
        min(1, max(0, value))
    }

    private func drawingRect(_ box: CameraBox, width: Int, height: Int) -> CGRect {
        CGRect(
            x: CGFloat(box.x) * CGFloat(width),
            y: (1 - CGFloat(box.y + box.height)) * CGFloat(height),
            width: CGFloat(box.width) * CGFloat(width),
            height: CGFloat(box.height) * CGFloat(height)
        )
    }

    private func stroke(rect: CGRect, color: NSColor, lineWidth: CGFloat) {
        color.setStroke()
        let path = NSBezierPath(rect: rect)
        path.lineWidth = lineWidth
        path.stroke()
    }

    private func drawHeader(_ text: String, canvas: CGRect) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: 17, weight: .bold),
            .foregroundColor: NSColor.white
        ]
        let size = (text as NSString).size(withAttributes: attributes)
        let rect = CGRect(x: 0, y: canvas.maxY - size.height - 14, width: canvas.width, height: size.height + 14)
        NSColor.black.withAlphaComponent(0.72).setFill()
        rect.fill()
        (text as NSString).draw(at: CGPoint(x: 8, y: rect.minY + 7), withAttributes: attributes)
    }

    private func drawLabel(_ text: String, at point: CGPoint, color: NSColor, canvas: CGRect) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 17, weight: .bold),
            .foregroundColor: NSColor.white
        ]
        let size = (text as NSString).size(withAttributes: attributes)
        let x = min(max(2, point.x), max(2, canvas.maxX - size.width - 10))
        let y = min(max(2, point.y), max(2, canvas.maxY - size.height - 6))
        let background = CGRect(x: x - 3, y: y - 2, width: size.width + 6, height: size.height + 4)
        color.withAlphaComponent(0.82).setFill()
        background.fill()
        (text as NSString).draw(at: CGPoint(x: x, y: y), withAttributes: attributes)
    }
}
