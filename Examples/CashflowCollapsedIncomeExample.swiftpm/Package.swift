// swift-tools-version: 6.0

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "CashflowCollapsedIncomeExample",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .iOSApplication(
            name: "CashflowCollapsedIncomeExample",
            targets: ["CashflowCollapsedIncomeExample"],
            bundleIdentifier: "com.daveboster.SwiftSankeyDiagram.CashflowCollapsedIncomeExample",
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
            name: "CashflowCollapsedIncomeExample",
            dependencies: [
                .product(name: "SwiftSankeyDiagram", package: "SwiftSankeyDiagram")
            ]
        ),
        .testTarget(
            name: "CashflowCollapsedIncomeExampleTests",
            dependencies: ["CashflowCollapsedIncomeExample"]
        )
    ]
)
