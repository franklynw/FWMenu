// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FWMenu",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "FWMenu",
            targets: ["FWMenu"]),
    ],
    dependencies: [
        .package(name: "CGExtensions", url: "https://github.com/franklynw/CGExtensions.git", .upToNextMajor(from: "1.0.0")),
        .package(name: "ActionGestureRecognizer", url: "https://github.com/franklynw/ActionGestureRecognizer.git", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "FWMenu",
            dependencies: ["CGExtensions", "ActionGestureRecognizer"]),
        .testTarget(
            name: "FWMenuTests",
            dependencies: ["FWMenu"]),
    ]
)
