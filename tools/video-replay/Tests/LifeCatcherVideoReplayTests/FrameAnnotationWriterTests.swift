import Foundation
import XCTest
@testable import LifeCatcherVideoReplay

final class FrameAnnotationWriterTests: XCTestCase {
    func testRerunRemovesPreviousGeneratedFrames() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("lifecatcher-writer-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let oldFrame = directory.appendingPathComponent("frame_000123.png")
        let oldManifest = directory.appendingPathComponent("frames.jsonl")
        try Data("old-frame".utf8).write(to: oldFrame)
        try Data("old-index".utf8).write(to: oldManifest)

        var writer: FrameAnnotationWriter? = try FrameAnnotationWriter(directory: directory)
        XCTAssertNotNil(writer)
        XCTAssertFalse(FileManager.default.fileExists(atPath: oldFrame.path))
        XCTAssertEqual(try Data(contentsOf: oldManifest).count, 0)
        XCTAssertTrue(FileManager.default.fileExists(
            atPath: directory.appendingPathComponent(".lifecatcher-video-replay-frames").path
        ))
        writer = nil
        try FileManager.default.removeItem(at: directory)
    }

    func testRerunRejectsUnknownFilesBeforeDeletingAnything() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("lifecatcher-writer-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let oldFrame = directory.appendingPathComponent("frame_000123.png")
        let personalFile = directory.appendingPathComponent("keep-me.txt")
        try Data("old-frame".utf8).write(to: oldFrame)
        try Data("personal".utf8).write(to: personalFile)

        XCTAssertThrowsError(try FrameAnnotationWriter(directory: directory))
        XCTAssertTrue(FileManager.default.fileExists(atPath: oldFrame.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: personalFile.path))
        try FileManager.default.removeItem(at: directory)
    }
}
