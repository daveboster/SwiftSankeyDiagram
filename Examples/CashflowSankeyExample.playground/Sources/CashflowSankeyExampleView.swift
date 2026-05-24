import SwiftSankeyDiagram
import SwiftUI

public struct CashflowSankeyExampleView: View {
    @State private var selectedNodeID: String?

    private let cashflow = ExampleCashflowFixture.make()
    private var selectedExpenseKind: ExampleExpenseKind? {
        ExampleExpenseKind.allCases.first { selectedNodeID == ExampleCashflowSankeyMapper.expenseKindID($0) }
    }

    private var diagram: ExampleSankeyDiagram {
        ExampleCashflowSankeyMapper.diagram(for: cashflow, drilldown: selectedExpenseKind)
    }

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Cashflow Sankey Example")
                    .font(.largeTitle.bold())

                Text("App-owned cashflow data mapped into generic Sankey nodes and links.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            SankeyDiagram(
                nodes: diagram.nodes,
                links: diagram.links,
                selectedNodeID: $selectedNodeID,
                style: .cashflowExample
            )
            .frame(minWidth: 980, idealWidth: 1_180, maxWidth: .infinity, minHeight: 620, idealHeight: 720)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.cashflowCanvasBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.secondary.opacity(0.18), lineWidth: 1)
            )

            if let selectedExpenseKind {
                Text("Drilling into \(selectedExpenseKind.displayName)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                Text("Click an expense group to show its items.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(24)
        .frame(minWidth: 1_080, minHeight: 760)
        .background(Color.cashflowPageBackground)
    }
}

private struct ExampleIncomeSource {
    let name: String
    let yearlyAmount: Double
}

private enum ExampleExpenseKind: String, CaseIterable {
    case bills
    case spending
    case periodic
    case liabilities

    var displayName: String {
        switch self {
        case .bills:
            "Bills"
        case .spending:
            "Spending"
        case .periodic:
            "Periodic"
        case .liabilities:
            "Liabilities"
        }
    }

    var color: Color {
        switch self {
        case .bills:
            Color(red: 0.88, green: 0.28, blue: 0.36)
        case .spending:
            Color(red: 0.91, green: 0.55, blue: 0.20)
        case .periodic:
            Color(red: 0.45, green: 0.39, blue: 0.92)
        case .liabilities:
            Color(red: 0.18, green: 0.48, blue: 0.87)
        }
    }
}

private struct ExampleExpenseItem {
    let type: ExampleExpenseKind
    let category: String
    let name: String
    let yearlyAmount: Double
}

private struct ExampleCashflow {
    let incomeSources: [ExampleIncomeSource]
    let expenseItems: [ExampleExpenseItem]
}

private struct ExampleSankeyDiagram {
    let nodes: [SankeyNode]
    let links: [SankeyLink]
}

private enum ExampleCashflowSankeyMapper {
    static func diagram(
        for cashflow: ExampleCashflow,
        drilldown: ExampleExpenseKind? = nil
    ) -> ExampleSankeyDiagram {
        var nodes = cashflow.incomeSources.map {
            SankeyNode(id: incomeID($0.name), title: $0.name, layer: 0)
        }
        nodes.append(SankeyNode(id: "total-income", title: "Total Income", layer: 1))

        for kind in ExampleExpenseKind.allCases where total(kind, in: cashflow) > 0 {
            nodes.append(SankeyNode(id: expenseKindID(kind), title: kind.displayName, layer: 2))
        }

        let surplus = totalIncome(in: cashflow) - totalExpenses(in: cashflow)
        if surplus > 0 {
            nodes.append(SankeyNode(id: "surplus", title: "Surplus", layer: 2))
        }

        if let drilldown {
            for item in items(drilldown, in: cashflow) {
                nodes.append(SankeyNode(id: itemID(item), title: item.name, layer: 3))
            }
        }

        var links = cashflow.incomeSources.map {
            SankeyLink(
                source: incomeID($0.name),
                target: "total-income",
                value: $0.yearlyAmount,
                color: Color(red: 0.20, green: 0.62, blue: 0.50)
            )
        }

        for kind in ExampleExpenseKind.allCases {
            let amount = total(kind, in: cashflow)
            guard amount > 0 else { continue }

            links.append(
                SankeyLink(
                    source: "total-income",
                    target: expenseKindID(kind),
                    value: amount,
                    color: kind.color
                )
            )
        }

        if surplus > 0 {
            links.append(
                SankeyLink(
                    source: "total-income",
                    target: "surplus",
                    value: surplus,
                    color: Color(red: 0.24, green: 0.39, blue: 0.88)
                )
            )
        }

        if let drilldown {
            for item in items(drilldown, in: cashflow) {
                links.append(
                    SankeyLink(
                        source: expenseKindID(drilldown),
                        target: itemID(item),
                        value: item.yearlyAmount,
                        color: drilldown.color
                    )
                )
            }
        }

        return ExampleSankeyDiagram(nodes: nodes, links: links)
    }

    private static func incomeID(_ name: String) -> String {
        "income.\(name)"
    }

    static func expenseKindID(_ kind: ExampleExpenseKind) -> String {
        "expense.\(kind.rawValue)"
    }

    private static func itemID(_ item: ExampleExpenseItem) -> String {
        "item.\(item.type.rawValue).\(item.category).\(item.name)"
    }

    private static func totalIncome(in cashflow: ExampleCashflow) -> Double {
        cashflow.incomeSources.reduce(0) { $0 + $1.yearlyAmount }
    }

    private static func totalExpenses(in cashflow: ExampleCashflow) -> Double {
        cashflow.expenseItems.reduce(0) { $0 + $1.yearlyAmount }
    }

    private static func total(_ kind: ExampleExpenseKind, in cashflow: ExampleCashflow) -> Double {
        cashflow.expenseItems
            .filter { $0.type == kind }
            .reduce(0) { $0 + $1.yearlyAmount }
    }

    private static func items(_ kind: ExampleExpenseKind, in cashflow: ExampleCashflow) -> [ExampleExpenseItem] {
        cashflow.expenseItems
            .filter { $0.type == kind }
            .sorted { lhs, rhs in
                if lhs.yearlyAmount == rhs.yearlyAmount {
                    return lhs.name < rhs.name
                }

                return lhs.yearlyAmount > rhs.yearlyAmount
            }
    }
}

private enum ExampleCashflowFixture {
    static func make() -> ExampleCashflow {
        ExampleCashflow(
            incomeSources: [
                ExampleIncomeSource(name: "Salary", yearlyAmount: 96_000),
                ExampleIncomeSource(name: "Partner Income", yearlyAmount: 68_000),
                ExampleIncomeSource(name: "Consulting", yearlyAmount: 16_800),
                ExampleIncomeSource(name: "Interest", yearlyAmount: 1_200)
            ],
            expenseItems: [
                ExampleExpenseItem(type: .bills, category: "Housing", name: "Mortgage", yearlyAmount: 28_800),
                ExampleExpenseItem(type: .bills, category: "Housing", name: "Property Tax", yearlyAmount: 6_000),
                ExampleExpenseItem(type: .bills, category: "Utilities", name: "Electric and Gas", yearlyAmount: 3_600),
                ExampleExpenseItem(type: .bills, category: "Utilities", name: "Water", yearlyAmount: 1_200),
                ExampleExpenseItem(type: .bills, category: "Insurance", name: "Home Insurance", yearlyAmount: 3_600),
                ExampleExpenseItem(type: .spending, category: "Food", name: "Groceries", yearlyAmount: 13_200),
                ExampleExpenseItem(type: .spending, category: "Food", name: "Dining", yearlyAmount: 5_400),
                ExampleExpenseItem(type: .spending, category: "Home", name: "Household", yearlyAmount: 4_200),
                ExampleExpenseItem(type: .spending, category: "Personal", name: "Clothing", yearlyAmount: 2_400),
                ExampleExpenseItem(type: .periodic, category: "Travel", name: "Vacation", yearlyAmount: 7_200),
                ExampleExpenseItem(type: .periodic, category: "Auto", name: "Vehicle Service", yearlyAmount: 2_400),
                ExampleExpenseItem(type: .periodic, category: "Fees", name: "Annual Fees", yearlyAmount: 1_200),
                ExampleExpenseItem(type: .periodic, category: "Gifts", name: "Holidays", yearlyAmount: 3_600),
                ExampleExpenseItem(type: .liabilities, category: "Debt", name: "Auto Loan", yearlyAmount: 5_400),
                ExampleExpenseItem(type: .liabilities, category: "Debt", name: "Student Loan", yearlyAmount: 3_600),
                ExampleExpenseItem(type: .liabilities, category: "Debt", name: "Credit Card", yearlyAmount: 2_400)
            ]
        )
    }
}

private extension SankeyDiagramStyle {
    static var cashflowExample: SankeyDiagramStyle {
        SankeyDiagramStyle(
            nodeWidth: 8,
            nodeCornerRadius: 4,
            nodeSpacing: 26,
            horizontalPadding: 34,
            verticalPadding: 24,
            minimumNodeHeight: 18,
            minimumLinkThickness: 3,
            labelWidth: 190,
            linkCurvature: 0.52,
            linkOpacity: 0.16,
            nodePalette: [
                SankeyPaletteColor(red: 0.20, green: 0.62, blue: 0.50),
                SankeyPaletteColor(red: 0.20, green: 0.62, blue: 0.50),
                SankeyPaletteColor(red: 0.88, green: 0.28, blue: 0.36),
                SankeyPaletteColor(red: 0.88, green: 0.28, blue: 0.36)
            ]
        )
    }
}

private extension Color {
    static var cashflowCanvasBackground: Color {
        #if os(macOS)
        Color(nsColor: .textBackgroundColor)
        #else
        Color(.secondarySystemBackground)
        #endif
    }

    static var cashflowPageBackground: Color {
        #if os(macOS)
        Color(nsColor: .windowBackgroundColor)
        #else
        Color(.systemBackground)
        #endif
    }
}
