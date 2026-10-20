// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LockWidget",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "LockWidget",
            path: "Sources"
        )
    ]
)
