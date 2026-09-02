// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-pair-coder",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Pair Coder",
            targets: ["Pair Coder"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-atoms/swift-pair.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-either.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-parser.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-serializer.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-coder.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "Pair Coder",
            dependencies: [
                .product(name: "Pair", package: "swift-pair"),
                .product(name: "Either", package: "swift-either"),
                .product(name: "Parser", package: "swift-parser"),
                .product(name: "Parser Product", package: "swift-parser"),
                .product(name: "Serializer", package: "swift-serializer"),
                .product(name: "Coder", package: "swift-coder"),
            ]
        ),
        .testTarget(
            name: "Pair Coder Tests",
            dependencies: [
                .target(name: "Pair Coder"),
                .product(name: "Pair", package: "swift-pair"),
                .product(name: "Either", package: "swift-either"),
                .product(name: "Parser", package: "swift-parser"),
                .product(name: "Parser Product", package: "swift-parser"),
                .product(name: "Serializer", package: "swift-serializer"),
                .product(name: "Coder", package: "swift-coder"),
            ],
            path: "Tests/Pair Coder Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
