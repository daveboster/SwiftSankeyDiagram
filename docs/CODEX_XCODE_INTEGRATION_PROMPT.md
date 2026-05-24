# Codex Xcode Integration Prompt

Use this prompt when asking Codex to add `SwiftSankeyDiagram` to an existing
Xcode app.

```md
Please implement `SwiftSankeyDiagram` in this Xcode project.

Package:
https://github.com/daveboster/SwiftSankeyDiagram.git

Goal:
Add a native SwiftUI Sankey diagram using the package, while keeping all
app-specific data, aggregation, navigation, export, and release behavior inside
this app.

Start by reading the repo guidance, build/test docs, package/dependency setup,
and the existing feature area where this diagram should live. Do not assume the
project uses one dependency mechanism; inspect the Xcode project, workspace, and
Swift package setup first.

Implementation requirements:
- Add `SwiftSankeyDiagram` as a Swift Package dependency to the target that will
  render the diagram.
- Do not modify `SwiftSankeyDiagram` unless there is a clear reusable package
  bug or missing generic API. If package changes are needed, stop and explain
  why before editing app code around it.
- Create an app-owned mapper that converts existing app data into
  `SankeyNode` and `SankeyLink`.
- Keep domain concepts out of package code. For example, if this is a cashflow
  app, income sources, expense types, categories, schedules, reports, opening
  balances, and export rules remain app-owned.
- Use stable node IDs and positive annual values for links.
- Add a SwiftUI view that renders `SankeyDiagram`.
- If drilldown is needed, use `selectedNodeID` and let the app decide how to
  rebuild nodes and links for the selected group.
- Keep colors, labels, currency/date formatting, and report/export placement
  consistent with the existing app.
- If the diagram is part of a report/export surface, keep preview and export
  output derived from the same app-owned mapper where practical.
- Add or update focused tests for the mapper totals, node IDs, links, drilldown
  behavior, and any report/export integration touched.
- Run the narrowest useful Xcode/SwiftPM validation first, then the broader
  validation required by this repo's docs.

Cashflow example mapping:
- annual income sources -> layer 0 income nodes
- total income -> layer 1 node
- expense groups such as Bills, Spending, Periodic, and Liabilities -> layer 2
  nodes
- optional selected expense items/categories -> layer 3 drilldown nodes
- annual source/group/item amounts -> `SankeyLink.value`
- selected node ID -> app-owned drilldown state

Deliverables:
- App dependency wiring for `SwiftSankeyDiagram`
- App-owned mapper type and focused tests
- SwiftUI diagram view integrated into the requested feature surface
- Validation summary with exact commands run and any remaining manual checks

Do not tag releases or push release automation unless explicitly asked in this
task. If this is user-facing in the host app, follow that repo's release-note
and TestFlight/release metadata workflow before commit.
```
