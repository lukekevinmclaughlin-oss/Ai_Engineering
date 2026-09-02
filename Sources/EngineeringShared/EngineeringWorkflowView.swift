import SwiftUI

public struct EngineeringWorkflowStage: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let detail: String
    public let systemImage: String

    public init(id: String, title: String, detail: String, systemImage: String) {
        self.id = id
        self.title = title
        self.detail = detail
        self.systemImage = systemImage
    }
}

public struct EngineeringWorkflowView: View {
    @Environment(\.colorScheme) private var colorScheme

    private let eyebrow: String
    private let title: String
    private let outcome: String
    private let accent: Color
    private let stages: [EngineeringWorkflowStage]

    public init(
        eyebrow: String = "YOUR OPERATING LOOP",
        title: String,
        outcome: String,
        accent: Color,
        stages: [EngineeringWorkflowStage]
    ) {
        self.eyebrow = eyebrow
        self.title = title
        self.outcome = outcome
        self.accent = accent
        self.stages = stages
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: AESpacing.md) {
            VStack(alignment: .leading, spacing: 5) {
                Text(eyebrow)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .tracking(1.1)
                    .foregroundStyle(AEColor.readableAccent("#7C6BFF", colorScheme))
                Text(title)
                    .font(.aeHeading)
                    .foregroundStyle(AEColor.textPrimary(colorScheme))
                Text(outcome)
                    .font(.aeCallout)
                    .foregroundStyle(AEColor.textSecondary(colorScheme))
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 190), spacing: AESpacing.sm)], spacing: AESpacing.sm) {
                ForEach(Array(stages.enumerated()), id: \.element.id) { index, stage in
                    HStack(alignment: .top, spacing: AESpacing.sm) {
                        ZStack {
                            Circle()
                                .fill(accent.opacity(0.14))
                                .frame(width: 38, height: 38)
                            Image(systemName: stage.systemImage)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(accent)
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text(String(format: "%02d", index + 1))
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .foregroundStyle(AEColor.textTertiary(colorScheme))
                            Text(stage.title)
                                .font(.aeLabel)
                                .foregroundStyle(AEColor.textPrimary(colorScheme))
                            Text(stage.detail)
                                .font(.aeCaption)
                                .foregroundStyle(AEColor.textSecondary(colorScheme))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(AESpacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AEColor.subtleFill(colorScheme), in: RoundedRectangle(cornerRadius: AERadius.medium))
                }
            }
        }
        .padding(AESpacing.lg)
        .aeGlassSurface(cornerRadius: AERadius.large, tint: accent)
    }
}
