// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "edfp",
    products: [
        .executable(
            name: "edfp",
            targets: ["edfp"]),
        .library(
            name: "EmojiDataFileParser",
            targets: ["EmojiDataFileParser"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-package-manager.git", .revision("swift-4.1.3-RELEASE")),
    ],
    targets: [
        .target(
            name: "EmojiDataFileParser",
            dependencies: []),
        .testTarget(
            name: "EmojiDataFileParserTests",
            dependencies: ["EmojiDataFileParser"]),
        .target(
            name: "edfp",
            dependencies: ["EmojiDataFileParser", "Utility"]),
    ]
)
