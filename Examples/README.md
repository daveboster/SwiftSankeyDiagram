# Examples

## Supported Scenarios

- `CashflowSankeyExample.swiftpm` starts with income sources expanded into
  `Total Income`.
- `CashflowCollapsedIncomeExample.swiftpm` starts with `Total Income` collapsed
  on the far left. Selecting `Total Income` expands the income sources; selecting
  it again collapses them.

Each scenario is an app playground backed by Swift Package Manager. Its
`Package.swift` depends on the public GitHub package URL, which is what makes
`import SwiftSankeyDiagram` available to the example target in Swift
Playgrounds.

In Xcode, open a `.swiftpm` package and run its matching scheme on an iOS
Simulator destination. These examples are iOS app playgrounds, not macOS
command-line executables.

To validate the supported scenarios from the repository root:

```bash
bash scripts/check-swift-playgrounds-scenarios.sh
```

To run the same scenario builds against the local package checkout instead of
the released public dependency:

```bash
bash scripts/check-swift-playgrounds-scenarios.sh --local-package
```
