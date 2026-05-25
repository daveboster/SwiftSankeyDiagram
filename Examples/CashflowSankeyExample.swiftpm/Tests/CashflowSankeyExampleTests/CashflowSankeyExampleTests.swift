import Testing
@testable import CashflowSankeyExample

@Suite("Cashflow Sankey example mapper")
struct CashflowSankeyExampleTests {
    @Test("supports collapsed income scenario")
    func supportsCollapsedIncomeScenario() throws {
        let diagram = ExampleCashflowSankeyMapper.diagram(
            for: ExampleCashflowFixture.make(),
            showsIncomeSources: false
        )

        let totalIncome = try #require(diagram.nodes.first { $0.id == ExampleCashflowSankeyMapper.totalIncomeID })

        #expect(totalIncome.layer == 0)
        #expect(!diagram.nodes.contains { $0.id.hasPrefix("income.") })
        #expect(!diagram.links.contains { $0.target == ExampleCashflowSankeyMapper.totalIncomeID })
        #expect(diagram.links.contains {
            $0.source == ExampleCashflowSankeyMapper.totalIncomeID
                && $0.target == ExampleCashflowSankeyMapper.expenseKindID(.bills)
        })
    }

    @Test("supports expanded income scenario")
    func supportsExpandedIncomeScenario() throws {
        let diagram = ExampleCashflowSankeyMapper.diagram(
            for: ExampleCashflowFixture.make(),
            showsIncomeSources: true
        )

        let totalIncome = try #require(diagram.nodes.first { $0.id == ExampleCashflowSankeyMapper.totalIncomeID })

        #expect(totalIncome.layer == 1)
        #expect(diagram.nodes.contains { $0.id == "income.Salary" })
        #expect(diagram.links.contains {
            $0.source == "income.Salary" && $0.target == ExampleCashflowSankeyMapper.totalIncomeID
        })
    }
}
