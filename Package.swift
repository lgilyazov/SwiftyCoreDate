// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "SwiftyCoreData",
    platforms: [
        .iOS(.v13), .macOS(.v12), .watchOS(.v6)
    ],
    products: [
        .library(
            name: "SwiftyCoreData",
            targets: ["SwiftyCoreData"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-collections.git",
            .upToNextMinor(from: "1.0.4")
        )
    ],
    targets: [
        .target(
            name: "SwiftyCoreData",
            dependencies: [
                .product(name: "Collections", package: "swift-collections")
            ]
        ),
        .testTarget(
            name: "SwiftyCoreDataTests",
            dependencies: ["SwiftyCoreData"]
        ),
    ]
)
