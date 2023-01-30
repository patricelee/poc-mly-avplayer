import PackageDescription

let package = Package(
    name: "MLYSDK",
    platforms: [
        .iOS(.v15),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "MLYSDK",
            targets: ["MLYSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swisspol/GCDWebServer.git", .upToNextMajor(from: "3.5.4")),
        .package(url: "https://github.com/muxinc/mux-stats-sdk-avplayer.git", .upToNextMajor(from: "3.1.0")),
        .package(url: "https://github.com/getsentry/sentry-cocoa.git", .upToNextMajor(from: "7.31.3")),
    ],
    targets: [
        .binaryTarget(
            name: "MLYSDK",
            path: "XCFramework/MLYSDK.xcframework"
        )
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
