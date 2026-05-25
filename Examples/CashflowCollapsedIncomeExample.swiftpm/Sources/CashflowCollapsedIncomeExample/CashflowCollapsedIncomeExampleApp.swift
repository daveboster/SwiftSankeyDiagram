import SwiftUI

@main
struct CashflowCollapsedIncomeExampleApp: App {
    var body: some Scene {
        WindowGroup {
            CashflowSankeyExampleView(
                title: "Cashflow Sankey - Total Income",
                initialIncomeView: .collapsed
            )
        }
    }
}
