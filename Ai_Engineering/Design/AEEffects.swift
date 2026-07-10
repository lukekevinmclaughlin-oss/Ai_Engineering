import SwiftUI

// MARK: - Frontier background

/// A reusable scene background with a restrained technical grid and aurora glow.
public struct AEFrontierBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    private let accent: Color
    private let intensity: Double
    private let showsGrid: Bool

    public init(
        accent: Color = AEColor.violet,
        intensity: Double = 1,
        showsGrid: Bool = true
    ) {
        self.accent = accent
        self.intensity = min(max(intensity, 0), 1.5)
        self.showsGrid = showsGrid
    }

    public var body: some View {
        ZStack {
            AEColor.canvas(colorScheme)

            GeometryReader { proxy in
                let width = max(proxy.size.width, 1)
                let height = max(proxy.size.height, 1)

                glowOrb(color: accent, diameter: max(width * 0.72, 360))
                    .offset(x: width * 0.32, y: -height * 0.30)

                glowOrb(color: AEColor.azure, diameter: max(width * 0.58, 300))
                    .offset(x: -width * 0.36, y: height * 0.33)

                if showsGrid {
                    AEGridOverlay()
                        .mask(
                            LinearGradient(
                                colors: [.clear, .white.opacity(0.9), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func glowOrb(color: Color, diameter: CGFloat) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        color.opacity(0.22 * intensity),
                        color.opacity(0.065 * intensity),
                        .clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: diameter * 0.5
                )
            )
            .frame(width: diameter, height: diameter)
            .blur(radius: 22)
    }
}

/// A fine engineering-grid overlay. Place it above any solid or gradient fill.
public struct AEGridOverlay: View {
    @Environment(\.colorScheme) private var colorScheme

    private let spacing: CGFloat
    private let opacity: Double

    public init(spacing: CGFloat = 32, opacity: Double = 0.42) {
        self.spacing = max(spacing, 12)
        self.opacity = min(max(opacity, 0), 1)
    }

    public var body: some View {
        Canvas { context, size in
            var fineGrid = Path()
            var majorGrid = Path()

            for x in stride(from: CGFloat.zero, through: size.width, by: spacing) {
                fineGrid.move(to: CGPoint(x: x, y: 0))
                fineGrid.addLine(to: CGPoint(x: x, y: size.height))
            }

            for y in stride(from: CGFloat.zero, through: size.height, by: spacing) {
                fineGrid.move(to: CGPoint(x: 0, y: y))
                fineGrid.addLine(to: CGPoint(x: size.width, y: y))
            }

            let majorSpacing = spacing * 4
            for x in stride(from: CGFloat.zero, through: size.width, by: majorSpacing) {
                majorGrid.move(to: CGPoint(x: x, y: 0))
                majorGrid.addLine(to: CGPoint(x: x, y: size.height))
            }

            for y in stride(from: CGFloat.zero, through: size.height, by: majorSpacing) {
                majorGrid.move(to: CGPoint(x: 0, y: y))
                majorGrid.addLine(to: CGPoint(x: size.width, y: y))
            }

            let base = colorScheme == .dark ? Color.white : Color.indigo
            context.stroke(
                fineGrid,
                with: .color(base.opacity(0.035 * opacity)),
                lineWidth: 0.5
            )
            context.stroke(
                majorGrid,
                with: .color(base.opacity(0.065 * opacity)),
                lineWidth: 0.75
            )
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

// MARK: - Surface and glow modifiers

private struct AEGlowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    let intensity: Double

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.28 * intensity), radius: radius * 0.45)
            .shadow(color: color.opacity(0.16 * intensity), radius: radius)
    }
}

private struct AEGlassSurfaceModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    let cornerRadius: CGFloat
    let tint: Color?
    let borderOpacity: Double

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        if let tint {
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .fill(tint.opacity(colorScheme == .dark ? 0.055 : 0.035))
                        }
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(colorScheme == .dark ? borderOpacity : borderOpacity * 0.75),
                                AEColor.stroke(colorScheme)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
    }
}

public extension View {
    func aeGlow(
        color: Color = AEColor.signal,
        radius: CGFloat = 18,
        intensity: Double = 1
    ) -> some View {
        modifier(AEGlowModifier(color: color, radius: radius, intensity: intensity))
    }

    func aeGlassSurface(
        cornerRadius: CGFloat = AERadius.large,
        tint: Color? = nil,
        borderOpacity: Double = 0.18
    ) -> some View {
        modifier(
            AEGlassSurfaceModifier(
                cornerRadius: cornerRadius,
                tint: tint,
                borderOpacity: min(max(borderOpacity, 0), 1)
            )
        )
    }
}
