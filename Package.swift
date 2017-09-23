// swift-tools-version:4.0
import PackageDescription

let package = Package(
	name: "Pool",
	products: [
        .library(name: "Pool", targets: ["Pool"])
    ],
	targets: [
        .target(name: "Pool"),
        .testTarget(name: "PoolTests", dependencies: ["Pool"])
	]
)
