// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "lifeCatcher-video-replay",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "lifecatcher-video-replay", targets: ["LifeCatcherVideoReplay"])
    ],
    targets: [
        .executableTarget(
            name: "LifeCatcherVideoReplay",
            path: "Sources/LifeCatcherVideoReplay"
        ),
        .testTarget(
            name: "LifeCatcherVideoReplayTests",
            dependencies: ["LifeCatcherVideoReplay"],
            path: "Tests/LifeCatcherVideoReplayTests"
        )
    ],
    swiftLanguageVersions: [.v5]
)
