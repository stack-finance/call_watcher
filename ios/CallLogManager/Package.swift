// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "CallLogManager",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "CallLogManager",
            targets: ["CallLogManager"]),
    ],
    targets: [
        .target(
            name: "CallLogManager",
            dependencies: []),
        .testTarget(
            name: "CallLogManagerTests",
            dependencies: ["CallLogManager"]),
    ]
)
