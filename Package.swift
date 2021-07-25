// swift-tools-version:5.3

import Foundation
import PackageDescription

let package = Package(
    name: "Hooks",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(name: "Hooks", targets: ["Hooks"]),
        .library(name: "HooksTesting", targets: ["HooksTesting"]),
    ],
    targets: [
        .target(
            name: "Hooks"
        ),
        .target(
            name: "HooksTesting",
            dependencies: ["Hooks"]
        ),
        .testTarget(
            name: "HooksTests",
            dependencies: ["HooksTesting"]
        ),
        .testTarget(
            name: "HooksTestingTests",
            dependencies: ["HooksTesting"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)

if ProcessInfo.processInfo.environment["WATCHOS"] == "true" {
    package.targets.removeAll(where: \.isTest)
}
