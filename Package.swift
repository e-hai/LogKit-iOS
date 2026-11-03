// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LogKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "LogKit",
            targets: ["LogKit"]
        ),
    ],
    targets: [
        .target(
            name: "LogKit",
            path: "Sources/LogKit"
        ),
        .testTarget(
            name: "LogKitTests",
            dependencies: ["LogKit"],
            path: "Tests/LogKitTests"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
