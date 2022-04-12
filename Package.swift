// swift-tools-version:5.6

import Foundation
import PackageDescription

let package = Package(
    name: "SwiftUI-Hooks",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(name: "Hooks", targets: ["Hooks"])
    ],
    targets: [
        .target(
            name: "Hooks",
            swiftSettings: [
                .unsafeFlags([
                    "-Xfrontend",
                    "-enable-actor-data-race-checks",
                ])
            ]
        ),
        .testTarget(
            name: "HooksTests",
            dependencies: ["Hooks"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
