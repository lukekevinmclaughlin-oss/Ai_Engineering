import SwiftUI

public enum AEMetricTrend {
    case positive(String)
    case negative(String)
    case neutral(String)

    fileprivate var label: String {
        switch self {
        case .positive(let label), .negative(let label), .neutral(let label): return label
        }
    }

    fileprivate var systemImage: String {
        switch self {
        case .positive: return "arrow.up.right"
        case .negative: return "arrow.down.right"
        case .neutral: return "minus"
        }
    }

    fileprivate func color(_ scheme: ColorScheme) -> Color {
        switch self {
        case .positive: return AEColor.readableSignal(scheme)
        case .negative: return AEColor.readableCoral(scheme)
        case .neutral: return AEColor.readableAzure(scheme)
        }
    }
}

/// Lightweight line/area chart for compact dashboard contexts.
public struct AESparkline: View {
    @Environment(\.colorScheme) private var colorScheme

    private let values: [Double]
    private let tint: Color
    private let lineWidth: CGFloat

    public init(
        values: [Double],
        tint: Color = AEColor.signal,
        lineWidth: CGFloat = 2
    ) {
        self.values = values
        self.tint = tint
        self.lineWidth = max(lineWidth, 1)
    }

    public var body: some View {
        GeometryReader { proxy in
            let points = normalizedPoints(in: proxy.size)

            ZStack {
                if points.count > 1 {
                    areaPath(points: points, size: proxy.size)
                        .fill(
                            LinearGradient(
                                colors: [tint.opacity(0.22), tint.opacity(0.01)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    linePath(points: points)
                        .stroke(
                            AEGradient.tint(tint),
                            style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
                        )
                        .shadow(color: tint.opacity(0.24), radius: 5)
                } else {
                    Rectangle()
                        .fill(AEColor.stroke(colorScheme))
                        .frame(height: 1)
                }
            }
        }
        .accessibilityHidden(true)
    }

    private func normalizedPoints(in size: CGSize) -> [CGPoint] {
        guard values.count > 1 else { return [] }

        let minimum = values.min() ?? 0
        let maximum = values.max() ?? 1
        let range = max(maximum - minimum, 0.000_001)
        let xStep = size.width / CGFloat(values.count - 1)
        let inset = min(lineWidth, size.height * 0.1)
        let drawableHeight = max(size.height - inset * 2, 1)

        return values.enumerated().map { index, value in
            let fraction = (value - minimum) / range
            return CGPoint(
                x: CGFloat(index) * xStep,
                y: inset + drawableHeight * (1 - CGFloat(fraction))
            )
        }
    }

    private func linePath(points: [CGPoint]) -> Path {
        Path { path in
            guard let first = points.first else { return }
            path.move(to: first)
            for point in points.dropFirst() {
                path.addLine(to: point)
            }
        }
    }

    private func areaPath(points: [CGPoint], size: CGSize) -> Path {
        Path { path in
            guard let first = points.first, let last = points.last else { return }
            path.move(to: CGPoint(x: first.x, y: size.height))
            path.addLine(to: first)
            for point in points.dropFirst() {
                path.addLine(to: point)
            }
            path.addLine(to: CGPoint(x: last.x, y: size.height))
            path.closeSubpath()
        }
    }
}

public struct AEMetricCard: View {
    @Environment(\.colorScheme) private var colorScheme

    private let title: String
    private let value: String
    private let detail: String?
    private let systemImage: String
    private let tint: Color
    private let trend: AEMetricTrend?
    private let series: [Double]

    public init(
        title: String,
        value: String,
        detail: String? = nil,
        systemImage: String,
        tint: Color = AEColor.signal,
        trend: AEMetricTrend? = nil,
        series: [Double] = []
    ) {
        self.title = title
        self.value = value
        self.detail = detail
        self.systemImage = systemImage
        self.tint = tint
        self.trend = trend
        self.series = series
    }

    public var body: some View {
        AECard(style: .elevated, padding: AESpacing.md, cornerRadius: AERadius.medium) {
            VStack(alignment: .leading, spacing: AESpacing.sm) {
                HStack(spacing: AESpacing.xs) {
                    Image(systemName: systemImage)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(tint)
                        .frame(width: 28, height: 28)
                        .background(tint.opacity(0.11), in: RoundedRectangle(cornerRadius: 8))

                    Text(title)
                        .aeTextRole(.label)
                        .foregroundStyle(AEColor.textSecondary(colorScheme))
                        .lineLimit(1)

                    Spacer(minLength: 4)

                    if let trend {
                        Label(trend.label, systemImage: trend.systemImage)
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(trend.color(colorScheme))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 4)
                            .background(trend.color(colorScheme).opacity(0.10), in: Capsule())
                    }
                }

                Text(value)
                    .aeTextRole(.metric)
                    .monospacedDigit()
                    .foregroundStyle(AEColor.textPrimary(colorScheme))
                    .contentTransition(.numericText())

                if let detail {
                    Text(detail)
                        .aeTextRole(.caption)
                        .foregroundStyle(AEColor.textTertiary(colorScheme))
                        .lineLimit(2)
                }

                if series.count > 1 {
                    AESparkline(values: series, tint: tint)
                        .frame(height: 34)
                        .padding(.top, 2)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

public struct AECompactMetric: View {
    @Environment(\.colorScheme) private var colorScheme

    private let title: String
    private let value: String
    private let systemImage: String?
    private let tint: Color

    public init(
        title: String,
        value: String,
        systemImage: String? = nil,
        tint: Color = AEColor.signal
    ) {
        self.title = title
        self.value = value
        self.systemImage = systemImage
        self.tint = tint
    }

    public var body: some View {
        HStack(spacing: AESpacing.xs) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 26, height: 26)
                    .background(tint.opacity(0.10), in: RoundedRectangle(cornerRadius: 8))
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(AEColor.textPrimary(colorScheme))

                Text(title)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(AEColor.textTertiary(colorScheme))
            }
        }
        .accessibilityElement(children: .combine)
    }
}
