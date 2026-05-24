// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SwiftSankeyDiagram",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "SwiftSankeyDiagram",
            targets: ["SwiftSankeyDiagram"]
        )
    ],
    targets: [
        .target(name: "SwiftSankeyDiagram"),
        .testTarget(
            name: "SwiftSankeyDiagramTests",
            dependencies: ["SwiftSankeyDiagram"]
        )
    ]
)
