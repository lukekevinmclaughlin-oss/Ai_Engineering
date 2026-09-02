import SwiftUI

public extension Color {
    public init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)

        let red: Double
        let green: Double
        let blue: Double
        let alpha: Double

        switch cleaned.count {
        case 3:
            red = Double((value >> 8) & 0xF) / 15
            green = Double((value >> 4) & 0xF) / 15
            blue = Double(value & 0xF) / 15
            alpha = 1
        case 8:
            red = Double((value >> 24) & 0xFF) / 255
            green = Double((value >> 16) & 0xFF) / 255
            blue = Double((value >> 8) & 0xFF) / 255
            alpha = Double(value & 0xFF) / 255
        default:
            red = Double((value >> 16) & 0xFF) / 255
            green = Double((value >> 8) & 0xFF) / 255
            blue = Double(value & 0xFF) / 255
            alpha = 1
        }

        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}

public struct AEFlowLayout: Layout {
    public var spacing: CGFloat = AESpacing.xs

    /// SwiftUI proposes `.infinity` (not nil) for an unbounded width -- e.g. inside a
    /// ScrollView on macOS. `proposal.width ?? fallback` only catches nil, so an
    /// infinite proposal stops the rows from ever wrapping and makes sizeThatFits
    /// return an infinite width, which wedges the layout engine and leaves the view
    /// unresponsive. Always resolve to a finite width.
    private func resolvedWidth(_ proposed: CGFloat?) -> CGFloat {
        guard let width = proposed, width.isFinite, width > 0 else { return 320 }
        return width
    }

    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) -> CGSize {
        let width = resolvedWidth(proposal.width)
        let result = arrange(subviews: subviews, width: width)
        return CGSize(width: width, height: result.height)
    }

    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) {
        let result = arrange(subviews: subviews, width: resolvedWidth(bounds.width))
        for (index, point) in result.points.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + point.x, y: bounds.minY + point.y),
                proposal: .unspecified
            )
        }
    }

    private func arrange(subviews: Subviews, width: CGFloat) -> (points: [CGPoint], height: CGFloat) {
        var points: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var lineHeight: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x > 0, x + size.width > width {
                x = 0
                y += lineHeight + spacing
                lineHeight = 0
            }
            points.append(CGPoint(x: x, y: y))
            lineHeight = max(lineHeight, size.height)
            x += size.width + spacing
        }
        return (points, y + lineHeight)
    }
}
