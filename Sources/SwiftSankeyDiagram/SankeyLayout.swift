import SwiftUI

struct SankeyLayout {
    let nodes: [SankeyNode]
    let links: [SankeyLink]
    let style: SankeyDiagramStyle
    let size: CGSize

    func make() -> SankeyLayoutOutput {
        let validLinks = links.filter { $0.value > 0 }
        let nodeValues = computeNodeValues(validLinks: validLinks)
        let layers = nodesByLayer(nodeValues: nodeValues)
        let scale = computeScale(layers: layers)
        let positionedNodes = positionNodes(layers: layers, nodeValues: nodeValues, scale: scale)
        let nodeByID = Dictionary(uniqueKeysWithValues: positionedNodes.map { ($0.id, $0) })
        let positionedLinks = positionLinks(
            validLinks: validLinks,
            nodesByID: nodeByID,
            nodeValues: nodeValues,
            scale: scale
        )

        return SankeyLayoutOutput(nodes: positionedNodes, links: positionedLinks)
    }

    private func computeNodeValues(validLinks: [SankeyLink]) -> [String: Double] {
        var incoming: [String: Double] = [:]
        var outgoing: [String: Double] = [:]

        for link in validLinks {
            outgoing[link.source, default: 0] += link.value
            incoming[link.target, default: 0] += link.value
        }

        return Dictionary(uniqueKeysWithValues: nodes.map { node in
            let value = max(incoming[node.id, default: 0], outgoing[node.id, default: 0], 0)
            return (node.id, value)
        })
    }

    private func nodesByLayer(nodeValues: [String: Double]) -> [[SankeyNode]] {
        let grouped = Dictionary(grouping: nodes.filter { nodeValues[$0.id, default: 0] > 0 }) { $0.layer }
        return grouped.keys.sorted().map { layer in
            grouped[layer] ?? []
        }
    }

    private func computeScale(layers: [[SankeyNode]]) -> CGFloat {
        let availableHeight = max(1, size.height - (style.verticalPadding * 2))
        let layerScales = layers.compactMap { layer -> CGFloat? in
            let total = layer.reduce(0) { partial, node in
                partial + max(nodeValue(node.id), 0)
            }
            guard total > 0 else { return nil }

            let spacing = CGFloat(max(0, layer.count - 1)) * style.nodeSpacing
            return max(1, availableHeight - spacing) / CGFloat(total)
        }

        return layerScales.min() ?? 1
    }

    private func positionNodes(
        layers: [[SankeyNode]],
        nodeValues: [String: Double],
        scale: CGFloat
    ) -> [SankeyLayoutNode] {
        guard !layers.isEmpty else { return [] }

        let leftX = style.horizontalPadding
        let rightX = max(leftX, size.width - style.horizontalPadding - style.nodeWidth)
        let xStep = layers.count == 1 ? 0 : (rightX - leftX) / CGFloat(layers.count - 1)

        return layers.enumerated().flatMap { layerIndex, layer in
            let heights = layer.map {
                nodeHeight(value: nodeValues[$0.id, default: 0], scale: scale)
            }
            let totalHeight = heights.reduce(0, +) + CGFloat(max(0, layer.count - 1)) * style.nodeSpacing
            var y = max(style.verticalPadding, (size.height - totalHeight) / 2)
            let x = leftX + (CGFloat(layerIndex) * xStep)

            return zip(layer, heights).map { node, height in
                defer { y += height + style.nodeSpacing }

                return SankeyLayoutNode(
                    id: node.id,
                    title: node.title,
                    value: nodeValues[node.id, default: 0],
                    layer: node.layer,
                    color: color(for: node, layerIndex: layerIndex),
                    rect: CGRect(x: x, y: y, width: style.nodeWidth, height: height),
                    labelAlignment: labelAlignment(layerIndex: layerIndex, layerCount: layers.count)
                )
            }
        }
    }

    private func positionLinks(
        validLinks: [SankeyLink],
        nodesByID: [String: SankeyLayoutNode],
        nodeValues: [String: Double],
        scale: CGFloat
    ) -> [SankeyLayoutLink] {
        var sourceOffsets: [String: Double] = [:]
        var targetOffsets: [String: Double] = [:]
        var positionedLinks: [SankeyLayoutLink] = []

        for link in validLinks {
            guard
                let source = nodesByID[link.source],
                let target = nodesByID[link.target]
            else {
                continue
            }

            let sourceBand = band(
                in: source.rect,
                nodeValue: nodeValues[source.id, default: 0],
                offsetValue: sourceOffsets[source.id, default: 0],
                linkValue: link.value
            )
            let targetBand = band(
                in: target.rect,
                nodeValue: nodeValues[target.id, default: 0],
                offsetValue: targetOffsets[target.id, default: 0],
                linkValue: link.value
            )

            positionedLinks.append(
                SankeyLayoutLink(
                    id: link.id,
                    sourceX: source.rect.maxX,
                    sourceTopY: sourceBand.minY,
                    sourceBottomY: sourceBand.maxY,
                    targetX: target.rect.minX,
                    targetTopY: targetBand.minY,
                    targetBottomY: targetBand.maxY,
                    fallbackThickness: max(style.minimumLinkThickness, CGFloat(link.value) * scale),
                    color: link.color ?? source.color
                )
            )

            sourceOffsets[source.id, default: 0] += link.value
            targetOffsets[target.id, default: 0] += link.value
        }

        return positionedLinks
    }

    private func nodeValue(_ id: String) -> Double {
        let validLinks = links.filter { $0.value > 0 }
        return computeNodeValues(validLinks: validLinks)[id, default: 0]
    }

    private func nodeHeight(value: Double, scale: CGFloat) -> CGFloat {
        max(style.minimumNodeHeight, CGFloat(value) * scale)
    }

    private func band(
        in rect: CGRect,
        nodeValue: Double,
        offsetValue: Double,
        linkValue: Double
    ) -> (minY: CGFloat, maxY: CGFloat) {
        guard nodeValue > 0 else {
            let halfThickness = style.minimumLinkThickness / 2
            return (rect.midY - halfThickness, rect.midY + halfThickness)
        }

        let startRatio = offsetValue / nodeValue
        let endRatio = (offsetValue + linkValue) / nodeValue
        let minY = rect.minY + (rect.height * CGFloat(startRatio))
        let maxY = rect.minY + (rect.height * CGFloat(endRatio))

        if maxY - minY >= style.minimumLinkThickness {
            return (minY, maxY)
        }

        let midpoint = (minY + maxY) / 2
        let halfThickness = style.minimumLinkThickness / 2
        return (midpoint - halfThickness, midpoint + halfThickness)
    }

    private func color(for node: SankeyNode, layerIndex: Int) -> Color {
        guard !style.nodePalette.isEmpty else {
            return .secondary
        }

        return style.nodePalette[layerIndex % style.nodePalette.count].color
    }

    private func labelAlignment(layerIndex: Int, layerCount: Int) -> SankeyLabelAlignment {
        layerIndex == layerCount - 1 ? .trailing : .leading
    }
}

struct SankeyLayoutOutput {
    let nodes: [SankeyLayoutNode]
    let links: [SankeyLayoutLink]
}

struct SankeyLayoutNode: Identifiable {
    let id: String
    let title: String
    let value: Double
    let layer: Int
    let color: Color
    let rect: CGRect
    let labelAlignment: SankeyLabelAlignment

    func labelPosition(labelWidth: CGFloat) -> CGPoint {
        let inset: CGFloat = 12

        switch labelAlignment {
        case .leading:
            return CGPoint(x: rect.maxX + inset + (labelWidth / 2), y: rect.midY)
        case .trailing:
            return CGPoint(x: rect.minX - inset - (labelWidth / 2), y: rect.midY)
        }
    }
}

struct SankeyLayoutLink: Identifiable {
    let id: String
    let sourceX: CGFloat
    let sourceTopY: CGFloat
    let sourceBottomY: CGFloat
    let targetX: CGFloat
    let targetTopY: CGFloat
    let targetBottomY: CGFloat
    let fallbackThickness: CGFloat
    let color: Color

    func ribbonPath(curvature: CGFloat) -> Path {
        let sourceTop = CGPoint(x: sourceX, y: sourceTopY)
        let sourceBottom = CGPoint(x: sourceX, y: sourceBottomY)
        let targetTop = CGPoint(x: targetX, y: targetTopY)
        let targetBottom = CGPoint(x: targetX, y: targetBottomY)
        let distance = max(24, targetX - sourceX)
        let clampedCurvature = min(max(curvature, 0), 1)

        var path = Path()
        path.move(to: sourceTop)
        path.addCurve(
            to: targetTop,
            control1: CGPoint(
                x: sourceTop.x + (distance * clampedCurvature),
                y: sourceTop.y + ((targetTop.y - sourceTop.y) * clampedCurvature)
            ),
            control2: CGPoint(
                x: targetTop.x - (distance * clampedCurvature),
                y: targetTop.y - ((targetTop.y - sourceTop.y) * clampedCurvature)
            )
        )
        path.addLine(to: targetBottom)
        path.addCurve(
            to: sourceBottom,
            control1: CGPoint(
                x: targetBottom.x - (distance * clampedCurvature),
                y: targetBottom.y + ((sourceBottom.y - targetBottom.y) * clampedCurvature)
            ),
            control2: CGPoint(
                x: sourceBottom.x + (distance * clampedCurvature),
                y: sourceBottom.y - ((sourceBottom.y - targetBottom.y) * clampedCurvature)
            )
        )
        path.closeSubpath()
        return path
    }
}

enum SankeyLabelAlignment {
    case leading
    case trailing

    var swiftUIAlignment: Alignment {
        switch self {
        case .leading:
            .leading
        case .trailing:
            .trailing
        }
    }

    var stackAlignment: HorizontalAlignment {
        switch self {
        case .leading:
            .leading
        case .trailing:
            .trailing
        }
    }

    var textAlignment: TextAlignment {
        switch self {
        case .leading:
            .leading
        case .trailing:
            .trailing
        }
    }
}
