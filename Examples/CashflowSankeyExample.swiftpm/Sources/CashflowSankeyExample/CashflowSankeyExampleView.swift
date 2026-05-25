import SwiftSankeyDiagram
import SwiftUI

struct CashflowSankeyExampleView: View {
    @State private var selectedNodeID: String?
    @State private var incomeView: ExampleIncomeView
    private let title: String

    private let cashflow = ExampleCashflowFixture.make()
    private var selectedExpenseKind: ExampleExpenseKind? {
        ExampleExpenseKind.allCases.first { selectedNodeID == ExampleCashflowSankeyMapper.expenseKindID($0) }
    }

    private var diagram: ExampleSankeyDiagram {
        ExampleCashflowSankeyMapper.diagram(
            for: cashflow,
            showsIncomeSources: incomeView == .expanded,
            drilldown: selectedExpenseKind
        )
    }

    private var diagramSelection: Binding<String?> {
        Binding(
            get: { selectedNodeID },
            set: { newValue in
                guard newValue == ExampleCashflowSankeyMapper.totalIncomeID else {
                    selectedNodeID = newValue
                    return
                }

                incomeView.toggle()
                selectedNodeID = nil
            }
        )
    }

    init(
        title: String = "Cashflow Sankey Example",
        initialIncomeView: ExampleIncomeView = .expanded
    ) {
        self.title = title
        _incomeView = State(initialValue: initialIncomeView)
    }

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            content
                .padding(24)
                .frame(width: 1_080, height: 760, alignment: .topLeading)
        }
        .background(Color.cashflowPageBackground)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.largeTitle.bold())

                Text("App-owned cashflow data mapped into generic Sankey nodes and links.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            SankeyDiagram(
                nodes: diagram.nodes,
                links: diagram.links,
                selectedNodeID: diagramSelection,
                style: .cashflowExample(showsIncomeSources: incomeView == .expanded)
            )
            .frame(width: 1_032, height: 620)
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
            } else if incomeView == .expanded {
                Text("Click Total Income to hide income sources, or click an expense group to show its items.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                Text("Click Total Income to show income sources, or click an expense group to show its items.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

enum ExampleIncomeView: String, CaseIterable, Identifiable {
    case expanded
    case collapsed

    var id: String { rawValue }

    var title: String {
        switch self {
        case .expanded:
            "Income Sources"
        case .collapsed:
            "Total Income"
        }
    }

    mutating func toggle() {
        self = self == .expanded ? .collapsed : .expanded
    }
}

struct ExampleIncomeSource {
    let name: String
    let yearlyAmount: Double
}

enum ExampleExpenseKind: String, CaseIterable {
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

struct ExampleExpenseItem {
    let type: ExampleExpenseKind
    let category: String
    let name: String
    let yearlyAmount: Double
}

struct ExampleCashflow {
    let incomeSources: [ExampleIncomeSource]
    let expenseItems: [ExampleExpenseItem]
}

struct ExampleSankeyDiagram {
    let nodes: [SankeyNode]
    let links: [SankeyLink]
}

enum ExampleCashflowSankeyMapper {
    static let totalIncomeID = "total-income"

    static func diagram(
        for cashflow: ExampleCashflow,
        showsIncomeSources: Bool,
        drilldown: ExampleExpenseKind? = nil
    ) -> ExampleSankeyDiagram {
        let totalIncomeLayer = showsIncomeSources ? 1 : 0
        let expenseLayer = showsIncomeSources ? 2 : 1
        let itemLayer = showsIncomeSources ? 3 : 2

        var nodes: [SankeyNode] = []
        if showsIncomeSources {
            nodes.append(contentsOf: cashflow.incomeSources.map {
                SankeyNode(id: incomeID($0.name), title: $0.name, layer: 0)
            })
        }
        nodes.append(SankeyNode(id: totalIncomeID, title: "Total Income", layer: totalIncomeLayer))

        for kind in ExampleExpenseKind.allCases where total(kind, in: cashflow) > 0 {
            nodes.append(SankeyNode(id: expenseKindID(kind), title: kind.displayName, layer: expenseLayer))
        }

        let surplus = totalIncome(in: cashflow) - totalExpenses(in: cashflow)
        if surplus > 0 {
            nodes.append(SankeyNode(id: "surplus", title: "Surplus", layer: expenseLayer))
        }

        if let drilldown {
            for item in items(drilldown, in: cashflow) {
                nodes.append(SankeyNode(id: itemID(item), title: item.name, layer: itemLayer))
            }
        }

        var links: [SankeyLink] = []
        if showsIncomeSources {
            links.append(contentsOf: cashflow.incomeSources.map {
                SankeyLink(
                    source: incomeID($0.name),
                    target: totalIncomeID,
                    value: $0.yearlyAmount,
                    color: Color(red: 0.20, green: 0.62, blue: 0.50)
                )
            })
        }

        for kind in ExampleExpenseKind.allCases {
            let amount = total(kind, in: cashflow)
            guard amount > 0 else { continue }

            links.append(
                SankeyLink(
                    source: totalIncomeID,
                    target: expenseKindID(kind),
                    value: amount,
                    color: kind.color
                )
            )
        }

        if surplus > 0 {
            links.append(
                SankeyLink(
                    source: totalIncomeID,
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

    static func incomeID(_ name: String) -> String {
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

enum ExampleCashflowFixture {
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

extension SankeyDiagramStyle {
    static func cashflowExample(showsIncomeSources: Bool) -> SankeyDiagramStyle {
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
                showsIncomeSources
                    ? SankeyPaletteColor(red: 0.20, green: 0.62, blue: 0.50)
                    : SankeyPaletteColor(red: 0.88, green: 0.28, blue: 0.36),
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
