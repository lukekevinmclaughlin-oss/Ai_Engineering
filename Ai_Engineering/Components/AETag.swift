import SwiftUI

public enum AETagKind {
    case accent
    case info
    case success
    case warning
    case danger
    case neutral
}

public enum AETagSize {
    case compact
    case regular

    fileprivate var font: Font {
        switch self {
        case .compact: return .system(size: 10, weight: .bold, design: .rounded)
        case .regular: return .system(size: 12, weight: .semibold, design: .rounded)
        }
    }

    fileprivate var horizontalPadding: CGFloat { self == .compact ? 8 : 10 }
    fileprivate var verticalPadding: CGFloat { self == .compact ? 4 : 6 }
}

public struct AETag: View {
    @Environment(\.colorScheme) private var colorScheme

    private let text: String
    private let systemImage: String?
    private let kind: AETagKind
    private let size: AETagSize

    public init(
        _ text: String,
        systemImage: String? = nil,
        kind: AETagKind = .neutral,
        size: AETagSize = .regular
    ) {
        self.text = text
        self.systemImage = systemImage
        self.kind = kind
        self.size = size
    }

    public var body: some View {
        HStack(spacing: 5) {
            if let systemImage {
                Image(systemName: systemImage)
                    .imageScale(.small)
            }
            Text(text)
                .lineLimit(1)
        }
        .font(size.font)
        .foregroundStyle(foregroundColor)
        .padding(.horizontal, size.horizontalPadding)
        .padding(.vertical, size.verticalPadding)
        .background(backgroundColor, in: Capsule())
        .overlay {
            Capsule()
                .strokeBorder(accentColor.opacity(0.22), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }

    private var accentColor: Color {
        switch kind {
        case .accent: return AEColor.violet
        case .info: return AEColor.azure
        case .success: return AEColor.signal
        case .warning: return AEColor.amber
        case .danger: return AEColor.coral
        case .neutral: return AEColor.textSecondary(colorScheme)
        }
    }

    private var foregroundColor: Color {
        switch kind {
        case .accent: return AEColor.readableViolet(colorScheme)
        case .info: return AEColor.readableAzure(colorScheme)
        case .success: return AEColor.readableSignal(colorScheme)
        case .warning: return AEColor.readableAmber(colorScheme)
        case .danger: return AEColor.readableCoral(colorScheme)
        case .neutral: return AEColor.textSecondary(colorScheme)
        }
    }

    private var backgroundColor: Color {
        accentColor.opacity(colorScheme == .dark ? 0.105 : 0.085)
    }
}

public struct AEStatusDot: View {
    @Environment(\.colorScheme) private var colorScheme

    private let label: String
    private let color: Color

    public init(_ label: String, color: Color = AEColor.signal) {
        self.label = label
        self.color = color
    }

    public var body: some View {
        HStack(spacing: 7) {
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
                .overlay {
                    Circle()
                        .stroke(color.opacity(0.25), lineWidth: 4)
                }
                .shadow(color: color.opacity(0.5), radius: 4)

            Text(label)
                .aeTextRole(.caption)
                .foregroundStyle(AEColor.textSecondary(colorScheme))
        }
        .accessibilityElement(children: .combine)
    }
}
