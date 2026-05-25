// swift-tools-version: 6.0

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "CashflowSankeyExample",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .iOSApplication(
            name: "CashflowSankeyExample",
            targets: ["CashflowSankeyExample"],
            bundleIdentifier: "com.daveboster.SwiftSankeyDiagram.CashflowSankeyExample",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .barChart),
            accentColor: .presetColor(.teal),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/daveboster/SwiftSankeyDiagram.git", from: "0.1.0")
    ],
    targets: [
        .executableTarget(
            name: "CashflowSankeyExample",
            dependencies: [
                .product(name: "SwiftSankeyDiagram", package: "SwiftSankeyDiagram")
            ]
        ),
        .testTarget(
            name: "CashflowSankeyExampleTests",
            dependencies: ["CashflowSankeyExample"]
        )
    ]
)
