import SwiftUI

public enum AEButtonVariant {
    case primary
    case secondary
    case outline
    case ghost
    case destructive
}

public enum AEButtonSize {
    case compact
    case regular
    case large

    fileprivate var height: CGFloat {
        switch self {
        case .compact: return 34
        case .regular: return 44
        case .large: return 52
        }
    }

    fileprivate var horizontalPadding: CGFloat {
        switch self {
        case .compact: return 12
        case .regular: return 18
        case .large: return 22
        }
    }

    fileprivate var font: Font {
        switch self {
        case .compact: return .system(size: 12, weight: .semibold, design: .rounded)
        case .regular: return .system(size: 14, weight: .semibold, design: .rounded)
        case .large: return .system(size: 16, weight: .semibold, design: .rounded)
        }
    }
}

/// Apply to any SwiftUI `Button`; labels may contain text, icons, or custom content.
public struct AEButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let variant: AEButtonVariant
    private let size: AEButtonSize
    private let expands: Bool
    private let tint: Color

    public init(
        _ variant: AEButtonVariant = .primary,
        size: AEButtonSize = .regular,
        expands: Bool = false,
        tint: Color = AEColor.signal
    ) {
        self.variant = variant
        self.size = size
        self.expands = expands
        self.tint = tint
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(size.font)
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, size.horizontalPadding)
            .frame(maxWidth: expands ? .infinity : nil, minHeight: size.height)
            .background { buttonBackground }
            .overlay { buttonBorder }
            .contentShape(RoundedRectangle(cornerRadius: AERadius.medium, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.975 : 1)
            .brightness(configuration.isPressed ? -0.035 : 0)
            .opacity(isEnabled ? 1 : 0.46)
            .shadow(color: glowColor, radius: configuration.isPressed ? 6 : 14, y: 5)
            .animation(reduceMotion ? nil : AEMotion.quick, value: configuration.isPressed)
    }

    private var foregroundColor: Color {
        switch variant {
        case .primary:
            return Color(red: 0.025, green: 0.075, blue: 0.100)
        case .destructive:
            return .white
        case .secondary, .outline, .ghost:
            return AEColor.textPrimary(colorScheme)
        }
    }

    @ViewBuilder
    private var buttonBackground: some View {
        let shape = RoundedRectangle(cornerRadius: AERadius.medium, style: .continuous)

        switch variant {
        case .primary:
            shape.fill(AEGradient.tint(tint))
        case .secondary:
            shape.fill(AEColor.surfaceElevated(colorScheme))
        case .outline, .ghost:
            shape.fill(variant == .ghost ? Color.clear : AEColor.surface(colorScheme).opacity(0.55))
        case .destructive:
            shape.fill(AEGradient.tint(AEColor.coral))
        }
    }

    @ViewBuilder
    private var buttonBorder: some View {
        let shape = RoundedRectangle(cornerRadius: AERadius.medium, style: .continuous)

        switch variant {
        case .primary:
            shape.strokeBorder(Color.white.opacity(0.24), lineWidth: 1)
        case .secondary:
            shape.strokeBorder(AEColor.strokeStrong(colorScheme), lineWidth: 1)
        case .outline:
            shape.strokeBorder(tint.opacity(0.58), lineWidth: 1)
        case .ghost:
            shape.strokeBorder(Color.clear, lineWidth: 0)
        case .destructive:
            shape.strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
        }
    }

    private var glowColor: Color {
        guard isEnabled else { return .clear }
        switch variant {
        case .primary: return tint.opacity(0.19)
        case .destructive: return AEColor.coral.opacity(0.16)
        case .secondary, .outline, .ghost: return .clear
        }
    }
}

/// A circular button treatment for toolbar and card actions.
public struct AEIconButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let diameter: CGFloat
    private let tint: Color
    private let emphasized: Bool

    public init(
        diameter: CGFloat = 40,
        tint: Color = AEColor.signal,
        emphasized: Bool = false
    ) {
        self.diameter = max(diameter, 28)
        self.tint = tint
        self.emphasized = emphasized
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: diameter * 0.38, weight: .semibold))
            .foregroundStyle(emphasized ? Color.black.opacity(0.78) : AEColor.textPrimary(colorScheme))
            .frame(width: diameter, height: diameter)
            .background {
                Circle()
                    .fill(
                        emphasized
                            ? AnyShapeStyle(AEGradient.tint(tint))
                            : AnyShapeStyle(AEColor.surfaceElevated(colorScheme))
                    )
            }
            .overlay {
                Circle()
                    .strokeBorder(
                        emphasized ? Color.white.opacity(0.22) : AEColor.strokeStrong(colorScheme),
                        lineWidth: 1
                    )
            }
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .opacity(isEnabled ? 1 : 0.46)
            .shadow(color: emphasized ? tint.opacity(0.18) : .clear, radius: 12, y: 4)
            .animation(reduceMotion ? nil : AEMotion.quick, value: configuration.isPressed)
    }
}
