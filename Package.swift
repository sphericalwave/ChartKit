// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwCharts",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "SwCharts", targets: ["SwCharts"]),
        // Deprecated compatibility product: re-exports SwCharts under the old
        // name. Remove once every app imports SwCharts.
        .library(name: "ChartKit", targets: ["ChartKit"]),
    ],
    targets: [
        .target(name: "SwCharts"),
        .target(name: "ChartKit", dependencies: ["SwCharts"]),
        .testTarget(name: "SwChartsTests", dependencies: ["SwCharts"]),
    ]
)
