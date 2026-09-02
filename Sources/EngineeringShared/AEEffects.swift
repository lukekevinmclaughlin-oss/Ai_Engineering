import SwiftUI

// MARK: - Frontier background

/// A reusable scene background with a restrained technical grid and aurora glow.
public struct AEFrontierBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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
        TimelineView(
            .animation(
                minimumInterval: ProcessInfo.processInfo.isLowPowerModeEnabled ? 0.5 : 1.0 / 15.0,
                paused: reduceMotion
            )
        ) { timeline in
            let seconds = timeline.date.timeIntervalSinceReferenceDate
            let phase = reduceMotion ? 0.38 : seconds.truncatingRemainder(dividingBy: 12) / 12
            let drift = reduceMotion ? 0 : sin(seconds / 4.5)

            ZStack {
                AEColor.canvas(colorScheme)

                GeometryReader { proxy in
                    let width = max(proxy.size.width, 1)
                    let height = max(proxy.size.height, 1)

                    glowOrb(color: accent, diameter: max(width * 0.72, 360))
                        .offset(x: width * 0.32 + drift * 14, y: -height * 0.30 + drift * 8)

                    glowOrb(color: AEColor.azure, diameter: max(width * 0.58, 300))
                        .offset(x: -width * 0.36 - drift * 10, y: height * 0.33 - drift * 7)

                    if showsGrid {
                        AEGridOverlay()
                            .mask(
                                LinearGradient(
                                    colors: [.clear, .white.opacity(0.9), .clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                        AEAmbientScanOverlay(accent: accent, phase: phase)
                    }
                }
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
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

private struct AEAmbientScanOverlay: View {
    @Environment(\.colorScheme) private var colorScheme

    let accent: Color
    let phase: Double

    var body: some View {
        GeometryReader { proxy in
            let travel = proxy.size.height + 220
            let y = -110 + travel * phase

            ZStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, accent.opacity(colorScheme == .dark ? 0.060 : 0.035), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 110)
                    .offset(y: y)

                Canvas { context, size in
                    let points = [
                        CGPoint(x: size.width * 0.16, y: size.height * 0.24),
                        CGPoint(x: size.width * 0.78, y: size.height * 0.18),
                        CGPoint(x: size.width * 0.64, y: size.height * 0.72),
                        CGPoint(x: size.width * 0.30, y: size.height * 0.82)
                    ]
                    for (index, point) in points.enumerated() {
                        let pulse = 2.0 + 1.4 * sin((phase * .pi * 2) + Double(index))
                        let rect = CGRect(x: point.x - pulse, y: point.y - pulse, width: pulse * 2, height: pulse * 2)
                        context.fill(Path(ellipseIn: rect), with: .color(accent.opacity(colorScheme == .dark ? 0.20 : 0.12)))
                    }
                }
            }
        }
        .clipped()
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
                                colorScheme == .dark
                                    ? Color.white.opacity(borderOpacity)
                                    : Color.indigo.opacity(borderOpacity * 0.62),
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
    public func aeGlow(
        color: Color = AEColor.signal,
        radius: CGFloat = 18,
        intensity: Double = 1
    ) -> some View {
        modifier(AEGlowModifier(color: color, radius: radius, intensity: intensity))
    }

    public func aeGlassSurface(
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
