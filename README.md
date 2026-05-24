# SwiftSankeyDiagram

SwiftSankeyDiagram is a small SwiftUI package for drawing Sankey diagrams from app-owned data.

The package owns the generic diagram model:

- `SankeyNode`
- `SankeyLink`
- `SankeyDiagram`
- `SankeyDiagramStyle`

Your app owns its source models and maps them into nodes and links. The included cashflow playground shows one way to adapt income and expense data into a yearly cashflow diagram.

## Usage

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
