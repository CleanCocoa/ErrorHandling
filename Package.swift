// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ErrorReporter",
    platforms: [
        .macOS(.v10_13),
    ],
    products: [
        .library(
            name: "ErrorReporter",
            targets: ["ErrorReporter"]),
    ],
    targets: [
        .target(
            name: "ErrorReporter",
            resources: [.process("Resources/PrivacyInfo.xcprivacy")])
    ]
)
