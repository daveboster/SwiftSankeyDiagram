# Getting Started With Xcode

This guide shows how to add `SwiftSankeyDiagram` to an existing Xcode app and
render a first diagram.

## Add The Package

1. Open your app project or workspace in Xcode.
2. Choose `File > Add Package Dependencies...`.
3. Enter the package URL:

   ```text
   https://github.com/daveboster/SwiftSankeyDiagram.git
   ```

4. Choose the dependency rule you want. For early adoption, use `Up to Next
   Minor Version` from `0.1.0`, or pin an exact version if your app needs tighter
   release control.
5. Add the `SwiftSankeyDiagram` product to the app or framework target that will
   render the diagram.

If your project manages dependencies in `Package.swift`, add:

```swift
.package(url: "https://github.com/daveboster/SwiftSankeyDiagram.git", from: "0.1.0")
```

and add `SwiftSankeyDiagram` to the target dependencies that need it.

## Render A First Diagram

Import the package from a SwiftUI view:

```swift
import SwiftSankeyDiagram
import SwiftUI
```

Create app-owned nodes and links:

```swift
let nodes = [
    SankeyNode(id: "salary", title: "Salary", layer: 0),
    SankeyNode(id: "income", title: "Total Income", layer: 1),
    SankeyNode(id: "bills", title: "Bills", layer: 2),
    SankeyNode(id: "surplus", title: "Surplus", layer: 2)
]

let links = [
    SankeyLink(source: "salary", target: "income", value: 96_000, color: .green),
    SankeyLink(source: "income", target: "bills", value: 42_000, color: .red),
    SankeyLink(source: "income", target: "surplus", value: 54_000, color: .blue)
]
```

Render the diagram:

```swift
SankeyDiagram(nodes: nodes, links: links)
    .frame(minHeight: 420)
```

## Map App Data

Keep app data in your app. Add a small mapper that converts your domain models
into `SankeyNode` and `SankeyLink`.

For a cashflow app, the mapper typically:

- creates one left-side node per annual income source
- creates a total income node
- creates expense group nodes, such as Bills, Spending, Periodic, and
  Liabilities
- creates optional item-level nodes for drilldown
- creates links whose `value` is the annual amount for that flow

Use stable string IDs so links can reliably point at nodes.

## Add Selection Or Drilldown

Use the `selectedNodeID` binding initializer when the host view needs to react
to selected nodes:

```swift
@State private var selectedNodeID: String?

SankeyDiagram(
    nodes: nodes,
    links: links,
    selectedNodeID: $selectedNodeID
)
```

The package only reports selected node IDs. Your app decides what that means,
such as showing item-level cashflow detail when an expense group is selected.

## Export To An Image

Because `SankeyDiagram` is a SwiftUI view, host apps can render it with
platform APIs such as `ImageRenderer` when creating PNG, PDF, or Rich Text
exports.

Keep export destinations and document/report code in the host app. The package
should only provide the reusable diagram view.

## Validate

After adding the package to an app, run the app's normal Xcode build and test
commands. For the package itself, use:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
bash scripts/check-swift-playgrounds-scenarios.sh
bash scripts/check-swift-playgrounds-scenarios.sh --local-package
```

## Troubleshooting

- If `import SwiftSankeyDiagram` fails, confirm the package product is added to
  the target that contains the importing file.
- If a cashflow example fails with `No such module 'SwiftSankeyDiagram'`, open
  one of the `.swiftpm` app playgrounds under `Examples/` rather than a
  standalone `.playground` bundle. Each app playground's `Package.swift`
  declares the public GitHub package dependency that Swift Playgrounds needs.
- If the diagram is blank, confirm every link has a positive `value` and that
  every `source` and `target` matches an existing node ID.
- If labels are clipped, give the diagram more width or adjust
  `SankeyDiagramStyle.labelWidth`.
- If the diagram does not match app totals, test the app-owned mapper before
  debugging package layout.
