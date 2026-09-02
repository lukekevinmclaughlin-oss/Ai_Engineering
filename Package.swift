// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "EngineeringShared",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "EngineeringShared", targets: ["EngineeringShared"])
    ],
    targets: [
        .target(name: "EngineeringShared"),
        .testTarget(name: "EngineeringSharedTests", dependencies: ["EngineeringShared"])
    ]
)
