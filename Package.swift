// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SwiftMessengerCore",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "SwiftMessengerCore", targets: ["SwiftMessengerCore"])
    ],
    targets: [
        .target(
            name: "SwiftMessengerCore",
            path: "SwiftMessengerLab/Core"
        ),
        .testTarget(
            name: "SwiftMessengerCoreTests",
            dependencies: ["SwiftMessengerCore"],
            path: "Tests/SwiftMessengerCoreTests"
        )
    ]
)

