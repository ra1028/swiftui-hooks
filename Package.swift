// swift-tools-version:5.9

import Foundation
import PackageDescription

let package = Package(
    name: "swiftui-hooks",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14),
        .watchOS(.v7),
    ],
    products: [
        .library(name: "Hooks", targets: ["Hooks"]),
    ],
    targets: [
        .target(name: "Hooks"),
        .testTarget(
            name: "HooksTests",
            dependencies: ["Hooks"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
