// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Hooks-Development-Tools",
    dependencies: [
        .package(url: "https://github.com/apple/swift-format.git", .branch("swift-5.3-branch")),
        .package(url: "https://github.com/yonaskolb/XcodeGen.git", .exact("2.24.0")),
    ]
)
