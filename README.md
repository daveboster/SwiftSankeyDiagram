# SwiftSankeyDiagram

SwiftSankeyDiagram is a small SwiftUI package for drawing Sankey diagrams from app-owned data.

The package owns the generic diagram model:

- `SankeyNode`
- `SankeyLink`
- `SankeyDiagram`
- `SankeyDiagramStyle`

Your app owns its source models and maps them into nodes and links. The included cashflow playground shows one way to adapt income and expense data into a yearly cashflow diagram.

## Usage

Use Swift Package Manager:

```swift
.package(url: "https://github.com/daveboster/SwiftSankeyDiagram.git", from: "0.1.0")
```

```swift
import SwiftSankeyDiagram
import SwiftUI

let nodes = [
    SankeyNode(id: "salary", title: "Salary", layer: 0),
    SankeyNode(id: "income", title: "Income", layer: 1),
    SankeyNode(id: "bills", title: "Bills", layer: 2)
]

let links = [
    SankeyLink(source: "salary", target: "income", value: 96_000, color: .green),
    SankeyLink(source: "income", target: "bills", value: 42_000, color: .red)
]

SankeyDiagram(nodes: nodes, links: links)
    .frame(height: 420)
```

## Cashflow Example

Open `Examples/CashflowSankeyExample.playground` in Xcode. It mirrors app-owned cashflow structs, then maps them into generic Sankey nodes and links.

The important boundary is that the package does not know about cashflow, expenses, categories, or any app storage. Those stay in the app. The package only renders nodes and links.

## Exporting

The diagram is a SwiftUI view, so apps can render it with platform APIs such as `ImageRenderer` when exporting to PNG/PDF/Rich Text workflows.

## Validation

```bash
swift test
swift build
```

See [docs/SWIFT_SANKEY_DIAGRAM.md](docs/SWIFT_SANKEY_DIAGRAM.md) for package boundary guidance.

## Versioning

`SwiftSankeyDiagram` uses semantic versioning. While the package is below 1.0,
minor releases may include source-breaking API changes as the public diagram
surface stabilizes. Patch releases should remain source-compatible within the
same minor version. See [CONTRIBUTING.md](CONTRIBUTING.md) for the pre-1.0
patch-versus-minor tagging policy.

## Contributing

Issues and pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md)
before broad API, layout, or adapter changes so the package boundary can stay
useful across host apps.

See [CHANGELOG.md](CHANGELOG.md) for release notes.

## License

`SwiftSankeyDiagram` is available under the MIT License. See [LICENSE](LICENSE).

## Credit

The initial ribbon drawing approach was informed by J.C. Builds' Medium article
["Easily Add a Clean SwiftUI Sankey Diagram to Your App"](https://medium.com/@jc_builds/easily-add-a-clean-swiftui-sankey-diagram-to-your-app-c4972b55d0c1),
especially the idea of avoiding rounded stroke caps so flow edges meet vertical
node bars cleanly.
