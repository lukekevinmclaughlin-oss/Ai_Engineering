import SwiftUI

public enum AECardStyle {
    case standard
    case elevated
    case interactive
    case featured
}

/// The base container for dashboard modules, lessons, and project surfaces.
public struct AECard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme

    private let style: AECardStyle
    private let tint: Color
    private let padding: CGFloat
    private let cornerRadius: CGFloat
    private let content: Content

    public init(
        style: AECardStyle = .standard,
        tint: Color = AEColor.violet,
        padding: CGFloat = AESpacing.lg,
        cornerRadius: CGFloat = AERadius.large,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.tint = tint
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    public var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background { cardBackground }
            .overlay { cardBorder }
            .shadow(
                color: shadowColor,
                radius: style == .elevated || style == .featured ? 24 : 12,
                x: 0,
                y: style == .elevated || style == .featured ? 12 : 6
            )
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    @ViewBuilder
    private var cardBackground: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        switch style {
        case .standard:
            shape.fill(AEColor.surface(colorScheme).opacity(colorScheme == .dark ? 0.90 : 0.98))
        case .elevated, .interactive:
            shape.fill(AEColor.surfaceElevated(colorScheme).opacity(colorScheme == .dark ? 0.94 : 1))
        case .featured:
            shape.fill(
                LinearGradient(
                    colors: [
                        tint.opacity(colorScheme == .dark ? 0.20 : 0.12),
                        AEColor.surfaceElevated(colorScheme),
                        AEColor.azure.opacity(colorScheme == .dark ? 0.075 : 0.045)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }

    @ViewBuilder
    private var cardBorder: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        switch style {
        case .standard, .elevated:
            shape.strokeBorder(AEColor.stroke(colorScheme), lineWidth: 1)
        case .interactive:
            shape.strokeBorder(
                LinearGradient(
                    colors: [tint.opacity(0.50), AEColor.stroke(colorScheme)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
        case .featured:
            shape.strokeBorder(
                LinearGradient(
                    colors: [tint.opacity(0.66), AEColor.azure.opacity(0.26), AEColor.stroke(colorScheme)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
        }
    }

    private var shadowColor: Color {
        switch style {
        case .featured:
            return tint.opacity(colorScheme == .dark ? 0.13 : 0.09)
        case .elevated:
            return AEColor.shadow(colorScheme)
        case .standard, .interactive:
            return AEColor.shadow(colorScheme).opacity(0.55)
        }
    }
}

/// Standardized title treatment for card content with an optional accessory.
public struct AECardHeader<Accessory: View>: View {
    @Environment(\.colorScheme) private var colorScheme

    private let title: String
    private let subtitle: String?
    private let systemImage: String?
    private let tint: Color
    private let accessory: Accessory

    public init(
        title: String,
        subtitle: String? = nil,
        systemImage: String? = nil,
        tint: Color = AEColor.signal,
        @ViewBuilder accessory: () -> Accessory
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.tint = tint
        self.accessory = accessory()
    }

    public var body: some View {
        HStack(alignment: .top, spacing: AESpacing.sm) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 36, height: 36)
                    .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: AERadius.small))
                    .overlay {
                        RoundedRectangle(cornerRadius: AERadius.small)
                            .strokeBorder(tint.opacity(0.18), lineWidth: 1)
                    }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .aeTextRole(.heading)
                    .foregroundStyle(AEColor.textPrimary(colorScheme))

                if let subtitle {
                    Text(subtitle)
                        .aeTextRole(.caption)
                        .foregroundStyle(AEColor.textSecondary(colorScheme))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: AESpacing.sm)
            accessory
        }
    }
}

public extension AECardHeader where Accessory == EmptyView {
    public init(
        title: String,
        subtitle: String? = nil,
        systemImage: String? = nil,
        tint: Color = AEColor.signal
    ) {
        self.init(
            title: title,
            subtitle: subtitle,
            systemImage: systemImage,
            tint: tint,
            accessory: { EmptyView() }
        )
    }
}
