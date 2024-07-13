// swift-tools-version:5.8

import PackageDescription

let package = Package(
    name: "build",
    products: [
    ],
    targets: [
        .executableTarget(
            name: "build",
            path: "XCFrameworkBuild"
        )
    ]
)
