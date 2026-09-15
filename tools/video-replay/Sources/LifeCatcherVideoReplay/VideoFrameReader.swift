import AVFoundation
import CoreVideo
import Foundation

final class VideoFrameReader {
    struct Metadata {
        let width: Int
        let height: Int
        let nominalFPS: Float
        let durationSeconds: Double
    }

    let metadata: Metadata

    private let reader: AVAssetReader
    private let output: AVAssetReaderTrackOutput

    init(url: URL) async throws {
        let asset = AVURLAsset(url: url)
        guard let track = try await asset.loadTracks(withMediaType: .video).first else {
            throw ReplayError.video("文件中没有视频轨道：\(url.path)")
        }
        reader = try AVAssetReader(asset: asset)
        output = AVAssetReaderTrackOutput(
            track: track,
            outputSettings: [
                kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
            ]
        )
        output.alwaysCopiesSampleData = false
        guard reader.canAdd(output) else {
            throw ReplayError.video("AVAssetReader 无法读取该视频轨道")
        }
        reader.add(output)

        let dimensions = try await track.load(.naturalSize)
        let nominalFrameRate = try await track.load(.nominalFrameRate)
        let duration = try await asset.load(.duration)
        metadata = Metadata(
            width: Int(abs(dimensions.width)),
            height: Int(abs(dimensions.height)),
            nominalFPS: nominalFrameRate,
            durationSeconds: duration.seconds.isFinite ? duration.seconds : 0
        )
    }

    func start() throws {
        guard reader.startReading() else {
            throw ReplayError.video("视频解码启动失败：\(reader.error?.localizedDescription ?? "未知错误")")
        }
    }

    func nextPixelBuffer() throws -> CVPixelBuffer? {
        guard let sampleBuffer = output.copyNextSampleBuffer() else {
            if reader.status == .failed {
                throw ReplayError.video("视频解码失败：\(reader.error?.localizedDescription ?? "未知错误")")
            }
            return nil
        }
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            throw ReplayError.video("视频帧不包含 CVPixelBuffer")
        }
        return imageBuffer
    }
}
