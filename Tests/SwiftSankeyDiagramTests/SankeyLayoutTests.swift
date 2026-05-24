import Testing
import SwiftUI
@testable import SwiftSankeyDiagram

@Suite("Sankey layout")
struct SankeyLayoutTests {
    @Test("builds nodes and links from generic data")
    func buildsNodesAndLinks() {
        let layout = SankeyLayout(
            nodes: [
                SankeyNode(id: "salary", title: "Salary", layer: 0),
                SankeyNode(id: "income", title: "Income", layer: 1),
                SankeyNode(id: "bills", title: "Bills", layer: 2)
            ],
            links: [
                SankeyLink(source: "salary", target: "income", value: 100),
                SankeyLink(source: "income", target: "bills", value: 60)
            ],
            style: SankeyDiagramStyle(),
            size: CGSize(width: 600, height: 400)
        ).make()

        #expect(layout.nodes.map(\.id) == ["salary", "income", "bills"])
        #expect(layout.links.count == 2)
    }

    @Test("source and target ribbon edges align to node bars")
    func ribbonEdgesAlignToNodeBars() throws {
        let layout = SankeyLayout(
            nodes: [
                SankeyNode(id: "income-a", title: "Income A", layer: 0),
                SankeyNode(id: "income-b", title: "Income B", layer: 0),
                SankeyNode(id: "total", title: "Total", layer: 1)
            ],
            links: [
                SankeyLink(id: "a", source: "income-a", target: "total", value: 75),
                SankeyLink(id: "b", source: "income-b", target: "total", value: 25)
            ],
            style: SankeyDiagramStyle(minimumLinkThickness: 1),
            size: CGSize(width: 600, height: 400)
        ).make()

        let total = try #require(layout.nodes.first { $0.id == "total" })
        let firstLink = try #require(layout.links.first { $0.id == "a" })
        let secondLink = try #require(layout.links.first { $0.id == "b" })

        #expect(firstLink.targetTopY == total.rect.minY)
        #expect(abs(firstLink.targetBottomY - secondLink.targetTopY) < 0.001)
        #expect(abs(secondLink.targetBottomY - total.rect.maxY) < 0.001)
    }
}
