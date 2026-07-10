import SwiftUI

// MARK: - Color

/// The shared color vocabulary for Ai_Engineering.
///
/// Neutral colors are functions because the app is dark-first, while still
/// retaining legibility and hierarchy when the system is in light mode.
public enum AEColor {
    public static let signal = Color(red: 0.38, green: 0.98, blue: 0.77)
    public static let azure = Color(red: 0.31, green: 0.76, blue: 1.00)
    public static let violet = Color(red: 0.61, green: 0.48, blue: 1.00)
    public static let coral = Color(red: 1.00, green: 0.45, blue: 0.42)
    public static let amber = Color(red: 1.00, green: 0.72, blue: 0.29)

    /// Higher-contrast accent variants intended for small text on light surfaces.
    public static func readableSignal(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? signal : Color(red: 0.00, green: 0.43, blue: 0.31)
    }

    public static func readableAzure(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? azure : Color(red: 0.00, green: 0.39, blue: 0.67)
    }

    public static func readableViolet(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? violet : Color(red: 0.34, green: 0.23, blue: 0.72)
    }

    public static func readableCoral(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? coral : Color(red: 0.72, green: 0.15, blue: 0.15)
    }

    public static func readableAmber(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? amber : Color(red: 0.54, green: 0.31, blue: 0.00)
    }

    public static func canvas(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.018, green: 0.025, blue: 0.050)
            : Color(red: 0.955, green: 0.970, blue: 0.990)
    }

    public static func canvasRaised(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.035, green: 0.047, blue: 0.085)
            : Color.white
    }

    public static func surface(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.055, green: 0.070, blue: 0.115)
            : Color(red: 0.985, green: 0.990, blue: 1.000)
    }

    public static func surfaceElevated(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.075, green: 0.094, blue: 0.150)
            : Color.white
    }

    public static func textPrimary(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.950, green: 0.970, blue: 1.000)
            : Color(red: 0.055, green: 0.070, blue: 0.115)
    }

    public static func textSecondary(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.635, green: 0.685, blue: 0.780)
            : Color(red: 0.310, green: 0.360, blue: 0.455)
    }

    public static func textTertiary(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.420, green: 0.475, blue: 0.575)
            : Color(red: 0.475, green: 0.520, blue: 0.600)
    }

    public static func stroke(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color.white.opacity(0.105)
            : Color(red: 0.080, green: 0.120, blue: 0.210).opacity(0.105)
    }

    public static func strokeStrong(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color.white.opacity(0.19)
            : Color(red: 0.080, green: 0.120, blue: 0.210).opacity(0.19)
    }

    public static func shadow(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.black.opacity(0.52) : Color.indigo.opacity(0.13)
    }
}

public enum AEGradient {
    public static var signal: LinearGradient {
        LinearGradient(
            colors: [AEColor.signal, AEColor.azure],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    public static var spectral: LinearGradient {
        LinearGradient(
            colors: [AEColor.signal, AEColor.azure, AEColor.violet],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    public static var aurora: AngularGradient {
        AngularGradient(
            colors: [AEColor.signal, AEColor.azure, AEColor.violet, AEColor.signal],
            center: .center
        )
    }

    public static func tint(_ color: Color) -> LinearGradient {
        LinearGradient(
            colors: [color.opacity(0.95), color.opacity(0.62)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Type

public enum AETextRole {
    case hero
    case display
    case title
    case heading
    case body
    case callout
    case label
    case caption
    case metric
    case code

    fileprivate var font: Font {
        switch self {
        case .hero:
            return .system(size: 46, weight: .bold, design: .rounded)
        case .display:
            return .system(size: 34, weight: .bold, design: .rounded)
        case .title:
            return .system(size: 24, weight: .bold, design: .rounded)
        case .heading:
            return .system(size: 18, weight: .semibold, design: .rounded)
        case .body:
            return .system(size: 16, weight: .regular, design: .rounded)
        case .callout:
            return .system(size: 14, weight: .medium, design: .rounded)
        case .label:
            return .system(size: 13, weight: .semibold, design: .rounded)
        case .caption:
            return .system(size: 12, weight: .medium, design: .rounded)
        case .metric:
            return .system(size: 28, weight: .bold, design: .rounded)
        case .code:
            return .system(size: 14, weight: .medium, design: .monospaced)
        }
    }

    fileprivate var tracking: CGFloat {
        switch self {
        case .hero, .display: return -0.8
        case .title, .metric: return -0.35
        case .label, .caption: return 0.25
        default: return 0
        }
    }

    fileprivate var lineSpacing: CGFloat {
        switch self {
        case .body: return 3
        case .callout: return 2
        default: return 0
        }
    }
}

private struct AETextRoleModifier: ViewModifier {
    let role: AETextRole

    func body(content: Content) -> some View {
        content
            .font(role.font)
            .tracking(role.tracking)
            .lineSpacing(role.lineSpacing)
    }
}

public extension View {
    /// Applies an Ai_Engineering type role without forcing a foreground color.
    func aeTextRole(_ role: AETextRole) -> some View {
        modifier(AETextRoleModifier(role: role))
    }
}

public extension Font {
    static var aeHero: Font { AETextRole.hero.font }
    static var aeDisplay: Font { AETextRole.display.font }
    static var aeTitle: Font { AETextRole.title.font }
    static var aeHeading: Font { AETextRole.heading.font }
    static var aeBody: Font { AETextRole.body.font }
    static var aeCallout: Font { AETextRole.callout.font }
    static var aeLabel: Font { AETextRole.label.font }
    static var aeCaption: Font { AETextRole.caption.font }
    static var aeMetric: Font { AETextRole.metric.font }
    static var aeCode: Font { AETextRole.code.font }
}

// MARK: - Layout tokens

public enum AESpacing {
    public static let xxs: CGFloat = 4
    public static let xs: CGFloat = 8
    public static let sm: CGFloat = 12
    public static let md: CGFloat = 16
    public static let lg: CGFloat = 24
    public static let xl: CGFloat = 32
    public static let xxl: CGFloat = 48
}

public enum AERadius {
    public static let small: CGFloat = 10
    public static let medium: CGFloat = 16
    public static let large: CGFloat = 24
    public static let capsule: CGFloat = 999
}

public enum AEMotion {
    public static let quick = Animation.spring(response: 0.24, dampingFraction: 0.82)
    public static let standard = Animation.spring(response: 0.38, dampingFraction: 0.84)
    public static let gentle = Animation.spring(response: 0.52, dampingFraction: 0.88)
}
