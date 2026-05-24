# SwiftSankeyDiagram

`SwiftSankeyDiagram` is a reusable SwiftUI package for app-owned data flow
visualizations.

## Package-Owned Responsibilities

- Generic Sankey node and link models.
- SwiftUI diagram rendering.
- Layout calculation for node bars, flow ribbons, and labels.
- Styling knobs that remain independent of a specific app domain.
- Tests for package-owned layout behavior.

Package code must stay reusable. Do not add host-specific app names, storage
models, navigation state, report builders, export destinations, Info.plist
values, Xcode build settings, signing settings, or target configuration to the
package.

## Host-Owned Responsibilities

Host apps own app-specific mapping and presentation:

- Source models such as cashflow items, income records, categories, or schedule
  data.
- Aggregation rules and time windows.
- Mapping source data into `SankeyNode` and `SankeyLink`.
- Domain colors, display names, formatting, and drilldown behavior.
- Export flows such as PDF, Rich Text, or saved image destinations.
- Navigation placement and app-specific report UI.

## Adapter Boundary

The package exposes generic diagram APIs instead of depending on app types:

- `SankeyNode` describes a displayed node and its layer.
- `SankeyLink` describes a positive flow between two nodes.
- `SankeyDiagramStyle` controls reusable layout and visual choices.
- `SankeyDiagram` renders the nodes and links and can bind selected node state
  back to the host app.

The cashflow playground example mirrors host-owned cashflow data to demonstrate
the adapter boundary. It is intentionally example code, not package domain
logic.

## Validation

Use these checks when changing the package boundary:

```bash
swift test
swift build
```
