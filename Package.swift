// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ChartKit",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "ChartKit", targets: ["ChartKit"]),
    ],
    targets: [
        .target(name: "ChartKit"),
        .testTarget(name: "ChartKitTests", dependencies: ["ChartKit"]),
    ]
)
