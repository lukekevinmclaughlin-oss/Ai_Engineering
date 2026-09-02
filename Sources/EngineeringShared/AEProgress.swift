import SwiftUI

public struct AEProgressBar: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let progress: Double
    private let tint: Color
    private let height: CGFloat
    private let showsGlow: Bool

    public init(
        progress: Double,
        tint: Color = AEColor.signal,
        height: CGFloat = 8,
        showsGlow: Bool = true
    ) {
        self.progress = min(max(progress, 0), 1)
        self.tint = tint
        self.height = max(height, 3)
        self.showsGlow = showsGlow
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AEColor.strokeStrong(colorScheme))

                Capsule()
                    .fill(AEGradient.tint(tint))
                    .frame(width: proxy.size.width * progress)
                    .overlay(alignment: .top) {
                        Capsule()
                            .fill(Color.white.opacity(0.22))
                            .frame(height: 1)
                            .padding(.horizontal, 2)
                    }
                    .shadow(
                        color: showsGlow ? tint.opacity(0.34) : .clear,
                        radius: showsGlow ? 8 : 0
                    )
            }
        }
        .frame(height: height)
        .animation(reduceMotion ? nil : AEMotion.standard, value: progress)
        .accessibilityElement()
        .accessibilityLabel("Progress")
        .accessibilityValue("\(Int(progress * 100)) percent")
    }
}

public struct AECircularProgress: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let progress: Double
    private let tint: Color
    private let size: CGFloat
    private let lineWidth: CGFloat
    private let showsPercentage: Bool

    public init(
        progress: Double,
        tint: Color = AEColor.signal,
        size: CGFloat = 72,
        lineWidth: CGFloat = 7,
        showsPercentage: Bool = true
    ) {
        self.progress = min(max(progress, 0), 1)
        self.tint = tint
        self.size = max(size, 32)
        self.lineWidth = max(lineWidth, 2)
        self.showsPercentage = showsPercentage
    }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(AEColor.strokeStrong(colorScheme), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AEGradient.tint(tint),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: tint.opacity(0.28), radius: 6)

            if showsPercentage {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: size * 0.22, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(AEColor.textPrimary(colorScheme))
                    .contentTransition(.numericText())
            }
        }
        .frame(width: size, height: size)
        .animation(reduceMotion ? nil : AEMotion.standard, value: progress)
        .accessibilityElement()
        .accessibilityLabel("Progress")
        .accessibilityValue("\(Int(progress * 100)) percent")
    }
}

public struct AESegmentedProgress: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let segmentCount: Int
    private let completedSegments: Int
    private let tint: Color
    private let spacing: CGFloat
    private let height: CGFloat

    public init(
        segmentCount: Int,
        completedSegments: Int,
        tint: Color = AEColor.signal,
        spacing: CGFloat = 5,
        height: CGFloat = 6
    ) {
        self.segmentCount = max(segmentCount, 1)
        self.completedSegments = min(max(completedSegments, 0), max(segmentCount, 1))
        self.tint = tint
        self.spacing = max(spacing, 1)
        self.height = max(height, 3)
    }

    public var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<segmentCount, id: \.self) { index in
                Capsule()
                    .fill(index < completedSegments ? AnyShapeStyle(AEGradient.tint(tint)) : AnyShapeStyle(AEColor.strokeStrong(colorScheme)))
                    .shadow(
                        color: index < completedSegments ? tint.opacity(0.20) : .clear,
                        radius: 4
                    )
            }
        }
        .frame(height: height)
        .animation(reduceMotion ? nil : AEMotion.standard, value: completedSegments)
        .accessibilityElement()
        .accessibilityLabel("Lesson progress")
        .accessibilityValue("\(completedSegments) of \(segmentCount) complete")
    }
}
