// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "Tools",
    dependencies: [
        .package(url: "https://github.com/apple/swift-format.git", exact: "0.50600.0"),
        .package(url: "https://github.com/yonaskolb/XcodeGen.git", exact: "2.28.0"),
    ]
)
