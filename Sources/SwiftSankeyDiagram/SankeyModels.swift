import SwiftUI

public struct SankeyNode: Identifiable, Hashable, Sendable {
    public let id: String
    public var title: String
    public var layer: Int

    public init(id: String, title: String, layer: Int) {
        self.id = id
        self.title = title
        self.layer = layer
    }
}

public struct SankeyLink: Identifiable {
    public let id: String
    public var source: String
    public var target: String
    public var value: Double
    public var color: Color?

    public init(
        id: String? = nil,
        source: String,
        target: String,
        value: Double,
        color: Color? = nil
    ) {
        self.id = id ?? "\(source)->\(target):\(value)"
        self.source = source
        self.target = target
        self.value = value
        self.color = color
    }
}

public struct SankeyDiagramStyle: Sendable {
    public var nodeWidth: CGFloat
    public var nodeCornerRadius: CGFloat
    public var nodeSpacing: CGFloat
    public var horizontalPadding: CGFloat
    public var verticalPadding: CGFloat
    public var minimumNodeHeight: CGFloat
    public var minimumLinkThickness: CGFloat
    public var labelWidth: CGFloat
    public var linkCurvature: CGFloat
    public var linkOpacity: Double
    public var nodePalette: [SankeyPaletteColor]

    public init(
        nodeWidth: CGFloat = 8,
        nodeCornerRadius: CGFloat = 4,
        nodeSpacing: CGFloat = 26,
        horizontalPadding: CGFloat = 34,
        verticalPadding: CGFloat = 24,
        minimumNodeHeight: CGFloat = 18,
        minimumLinkThickness: CGFloat = 3,
        labelWidth: CGFloat = 190,
        linkCurvature: CGFloat = 0.52,
        linkOpacity: Double = 0.16,
        nodePalette: [SankeyPaletteColor] = .defaultSankeyPalette
    ) {
        self.nodeWidth = nodeWidth
        self.nodeCornerRadius = nodeCornerRadius
        self.nodeSpacing = nodeSpacing
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.minimumNodeHeight = minimumNodeHeight
        self.minimumLinkThickness = minimumLinkThickness
        self.labelWidth = labelWidth
        self.linkCurvature = linkCurvature
        self.linkOpacity = linkOpacity
        self.nodePalette = nodePalette
    }
}

public struct SankeyPaletteColor: Sendable, Equatable {
    public var red: Double
    public var green: Double
    public var blue: Double
    public var opacity: Double

    public init(red: Double, green: Double, blue: Double, opacity: Double = 1) {
        self.red = red
        self.green = green
        self.blue = blue
        self.opacity = opacity
    }

    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: opacity)
    }
}

public extension Array where Element == SankeyPaletteColor {
    static var defaultSankeyPalette: [SankeyPaletteColor] {
        [
            SankeyPaletteColor(red: 0.20, green: 0.62, blue: 0.50),
            SankeyPaletteColor(red: 0.88, green: 0.28, blue: 0.36),
            SankeyPaletteColor(red: 0.91, green: 0.55, blue: 0.20),
            SankeyPaletteColor(red: 0.45, green: 0.39, blue: 0.92),
            SankeyPaletteColor(red: 0.18, green: 0.48, blue: 0.87)
        ]
    }
}
