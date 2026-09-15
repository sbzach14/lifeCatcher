import XCTest
@testable import LifeCatcherVideoReplay

final class CLIOptionsTests: XCTestCase {
    func testRejectsUnsupportedLogicalFPS() throws {
        let temporary = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
        FileManager.default.createFile(atPath: temporary.path, contents: Data())
        defer { try? FileManager.default.removeItem(at: temporary) }

        XCTAssertThrowsError(
            try CLIOptions.parse(
                arguments: ["--video", temporary.path, "--fps", "60"],
                currentDirectory: URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            )
        )
    }

    func testParsesLogicalFPSAndStableCardProtocol() throws {
        let temporary = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mov")
        FileManager.default.createFile(atPath: temporary.path, contents: Data())
        defer { try? FileManager.default.removeItem(at: temporary) }

        let options = try CLIOptions.parse(
            arguments: [
                "--video", temporary.path,
                "--fps", "240",
                "--mode", "riffle",
                "--orientation", "vertical",
                "--allowed-cards", "0-2,52-54"
            ],
            currentDirectory: URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        )

        XCTAssertEqual(options.logicalFPS, 240)
        XCTAssertEqual(options.mode, .riffle)
        XCTAssertEqual(options.orientation, .vertical)
        XCTAssertEqual(options.allowedCards, [0, 1, 2, 53, 54])
        XCTAssertNil(options.annotatedFramesDirectory)
    }

    func testCardDisplayLabelsFollowStableSuitOrder() {
        XCTAssertEqual(CardDisplayLabels.values[0], "♠️A")
        XCTAssertEqual(CardDisplayLabels.values[12], "♠️K")
        XCTAssertEqual(CardDisplayLabels.values[13], "♥️A")
        XCTAssertEqual(CardDisplayLabels.values[25], "♥️K")
        XCTAssertEqual(CardDisplayLabels.values[26], "♣️A")
        XCTAssertEqual(CardDisplayLabels.values[38], "♣️K")
        XCTAssertEqual(CardDisplayLabels.values[39], "♦️A")
        XCTAssertEqual(CardDisplayLabels.values[51], "♦️K")
    }

    func testDefaultModeDoesNotRotateInput() throws {
        let temporary = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
        FileManager.default.createFile(atPath: temporary.path, contents: Data())
        defer { try? FileManager.default.removeItem(at: temporary) }

        let options = try CLIOptions.parse(
            arguments: ["--video", temporary.path, "--orientation", "horizontal"],
            currentDirectory: URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        )

        XCTAssertEqual(options.mode, .horizontalShuffle)
        XCTAssertEqual(options.mode.shuffleMode, [2, 0])
        XCTAssertEqual(options.orientation, .horizontal)
        XCTAssertEqual(options.rotation, .none)
    }

    func testParsesExplicitFrameRotation() throws {
        let temporary = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
        FileManager.default.createFile(atPath: temporary.path, contents: Data())
        defer { try? FileManager.default.removeItem(at: temporary) }

        let options = try CLIOptions.parse(
            arguments: ["--video", temporary.path, "--rotation", "clockwise"],
            currentDirectory: URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        )

        XCTAssertEqual(options.rotation, .clockwise)
    }

    func testParsesNinetyFoldForcedSingleEntry() throws {
        let temporary = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
        FileManager.default.createFile(atPath: temporary.path, contents: Data())
        defer { try? FileManager.default.removeItem(at: temporary) }

        let options = try CLIOptions.parse(
            arguments: [
                "--video", temporary.path,
                "--single-roi-area-factor", "90",
                "--force-single-entry", "left"
            ],
            currentDirectory: URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        )

        XCTAssertEqual(options.singleROIAreaFactor, 90)
        XCTAssertEqual(options.forcedSingleEntrySide, .left)
    }

    func testHorizontalShuffleUsesTexasAndRiffleDetectorWithoutChangingNormalModes() {
        XCTAssertEqual(ModelRunner.classifierName(mode: .horizontalShuffle, orientation: .horizontal), "cls_20260915_texas")
        XCTAssertEqual(ModelRunner.classifierName(mode: .horizontalShuffle, orientation: .vertical), "cls_20260915_texas")
        XCTAssertEqual(ModelRunner.detectorName(mode: .horizontalShuffle), "riffle_detect_1111")
        XCTAssertEqual(ModelRunner.detectorName(mode: .shuffle), "detect_0903")
        XCTAssertEqual(ModelRunner.detectorName(mode: .both), "detect_0903")
        XCTAssertEqual(ModelRunner.detectorName(mode: .riffle), "riffle_detect_1111")
        XCTAssertEqual(ModelRunner.classifierName(mode: .riffle, orientation: .vertical), "riffle_cls_v_1107")
        XCTAssertEqual(ModelRunner.classifierName(mode: .shuffle, orientation: .horizontal), "cls_1215_h")
        XCTAssertEqual(ModelRunner.classifierName(mode: .shuffle, orientation: .vertical), "cls_1215_v")
    }
}
