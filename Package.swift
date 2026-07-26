// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "AirShortcut",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "AirShortcut", targets: ["AirShortcut"])
    ],
    targets: [
        .target(
            name: "AirShortcutMultitouchBridge",
            path: "Sources/AirShortcutMultitouchBridge",
            publicHeadersPath: "include"
        ),
        .executableTarget(
            name: "AirShortcut",
            dependencies: ["AirShortcutMultitouchBridge"],
            path: "Sources/AirShortcut"
        ),
        .testTarget(
            name: "AirShortcutTests",
            dependencies: ["AirShortcut"],
            path: "Tests/AirShortcutTests",
            resources: [
                .process("Fixtures")
            ]
        )
    ]
)
