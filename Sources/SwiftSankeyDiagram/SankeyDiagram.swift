import SwiftUI

public struct SankeyDiagram: View {
    private let nodes: [SankeyNode]
    private let links: [SankeyLink]
    private let style: SankeyDiagramStyle
    @Binding private var selectedNodeID: String?

    public init(
        nodes: [SankeyNode],
        links: [SankeyLink],
        style: SankeyDiagramStyle = SankeyDiagramStyle()
    ) {
        self.nodes = nodes
        self.links = links
        self.style = style
        _selectedNodeID = .constant(nil)
    }

    public init(
        nodes: [SankeyNode],
        links: [SankeyLink],
        selectedNodeID: Binding<String?>,
        style: SankeyDiagramStyle = SankeyDiagramStyle()
    ) {
        self.nodes = nodes
        self.links = links
        self.style = style
        _selectedNodeID = selectedNodeID
    }

    public var body: some View {
        GeometryReader { proxy in
            let layout = SankeyLayout(
                nodes: nodes,
                links: links,
                style: style,
                size: proxy.size
            ).make()

            ZStack {
                Canvas { context, _ in
                    for link in layout.links {
                        context.fill(
                            link.ribbonPath(curvature: style.linkCurvature),
                            with: .color(link.color.opacity(style.linkOpacity))
                        )
                    }

                    for node in layout.nodes {
                        context.fill(
                            Path(roundedRect: node.rect, cornerRadius: style.nodeCornerRadius),
                            with: .color(node.color)
                        )
                    }
                }

                ForEach(layout.nodes) { node in
                    SankeyNodeLabel(
                        node: node,
                        isSelected: selectedNodeID == node.id,
                        onSelect: { selectedNodeID = node.id }
                    )
                    .frame(width: style.labelWidth, alignment: node.labelAlignment.swiftUIAlignment)
                    .position(node.labelPosition(labelWidth: style.labelWidth))
                }
            }
            .clipped()
        }
    }
}

private struct SankeyNodeLabel: View {
    let node: SankeyLayoutNode
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: node.labelAlignment.stackAlignment, spacing: 2) {
                Text(node.title)
                    .font(.system(size: node.layer == 0 ? 15 : 14, weight: .semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(node.labelAlignment.textAlignment)
                    .lineLimit(2)

                Text(node.value.sankeyCurrencyLabel)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(node.color.opacity(0.12))
                }
            }
        }
        .buttonStyle(.plain)
    }
}

private extension Double {
    var sankeyCurrencyLabel: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "$0"
    }
}
