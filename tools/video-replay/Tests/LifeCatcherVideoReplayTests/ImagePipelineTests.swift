import CoreVideo
import XCTest
@testable import LifeCatcherVideoReplay

final class ImagePipelineTests: XCTestCase {
    func testAutoRotationPreservesNaturalPixelCount() throws {
        var source: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            720,
            1280,
            kCVPixelFormatType_32BGRA,
            [kCVPixelBufferIOSurfacePropertiesKey: [:]] as CFDictionary,
            &source
        )
        XCTAssertEqual(status, kCVReturnSuccess)
        let rotated = try ImagePipeline.rotatedFramePreservingSize(
            XCTUnwrap(source),
            rotation: .auto
        )
        XCTAssertEqual(CVPixelBufferGetWidth(rotated), 1280)
        XCTAssertEqual(CVPixelBufferGetHeight(rotated), 720)
    }
}
