import EngineeringShared
import SwiftUI

/// A normalized snapshot of the learner's work that can drive every AI assembly treatment.
/// Only catalog-backed identifiers count, so deleted or stale progress cannot inflate the visual.
struct AIAssemblyProgress: Equatable, Sendable {
    let completedLessons: Int
    let totalLessons: Int
    let completedCourses: Int
    let totalCourses: Int
    let completedMilestones: Int
    let totalMilestones: Int

    init(
        completedLessons: Int,
        totalLessons: Int,
        completedCourses: Int,
        totalCourses: Int,
        completedMilestones: Int,
        totalMilestones: Int
    ) {
        self.completedLessons = min(max(completedLessons, 0), max(totalLessons, 0))
        self.totalLessons = max(totalLessons, 0)
        self.completedCourses = min(max(completedCourses, 0), max(totalCourses, 0))
        self.totalCourses = max(totalCourses, 0)
        self.completedMilestones = min(max(completedMilestones, 0), max(totalMilestones, 0))
        self.totalMilestones = max(totalMilestones, 0)
    }

    init(
        courses: [Course],
        projects: [LabProject],
        completedLessonIDs: Set<String>,
        completedMilestoneIDs: Set<String>
    ) {
        let lessonIDs = Set(courses.flatMap(\.lessons).map(\.id))
        let milestoneIDs = Set(projects.flatMap { project in
            project.milestones.map { milestone in
                milestone.progressID(projectID: project.id)
            }
        })
        let verifiedLessonIDs = completedLessonIDs.intersection(lessonIDs)

        self.init(
            completedLessons: verifiedLessonIDs.count,
            totalLessons: lessonIDs.count,
            completedCourses: courses.filter { course in
                !course.lessons.isEmpty && course.lessons.allSatisfy { verifiedLessonIDs.contains($0.id) }
            }.count,
            totalCourses: courses.count,
            completedMilestones: completedMilestoneIDs.intersection(milestoneIDs).count,
            totalMilestones: milestoneIDs.count
        )
    }

    static func milestoneKey(projectID: String, milestoneID: String) -> String {
        "\(projectID)::\(milestoneID)"
    }

    var completedUnits: Int {
        completedLessons + completedCourses + completedMilestones
    }

    var totalUnits: Int {
        totalLessons + totalCourses + totalMilestones
    }

    var fractionComplete: Double {
        guard totalUnits > 0 else { return 0 }
        return min(max(Double(completedUnits) / Double(totalUnits), 0), 1)
    }

    var percentage: Int {
        Int((fractionComplete * 100).rounded())
    }

    var remainingUnits: Int {
        max(totalUnits - completedUnits, 0)
    }

    var stage: AIAssemblyStage {
        AIAssemblyStage.allCases.last(where: { fractionComplete >= $0.threshold }) ?? .blueprint
    }

    var nextStage: AIAssemblyStage? {
        AIAssemblyStage.allCases.first(where: { $0.threshold > fractionComplete })
    }
}

enum AIAssemblyStage: Int, CaseIterable, Sendable {
    case blueprint
    case neuralCore
    case cognitiveLattice
    case systemsIntegration
    case autonomousReasoning
    case commissioned

    var threshold: Double {
        switch self {
        case .blueprint: 0
        case .neuralCore: 0.08
        case .cognitiveLattice: 0.25
        case .systemsIntegration: 0.50
        case .autonomousReasoning: 0.75
        case .commissioned: 1
        }
    }

    var title: String {
        switch self {
        case .blueprint: "Blueprint scaffold"
        case .neuralCore: "Neural core online"
        case .cognitiveLattice: "Cognitive lattice"
        case .systemsIntegration: "Systems integration"
        case .autonomousReasoning: "Reasoning engine"
        case .commissioned: "AI commissioned"
        }
    }

    var shortTitle: String {
        switch self {
        case .blueprint: "Frame"
        case .neuralCore: "Core"
        case .cognitiveLattice: "Lattice"
        case .systemsIntegration: "Systems"
        case .autonomousReasoning: "Reasoning"
        case .commissioned: "Online"
        }
    }

    var detail: String {
        switch self {
        case .blueprint: "The first lesson lays down the frame."
        case .neuralCore: "Foundational concepts are energising the central core."
        case .cognitiveLattice: "Skills are linking into a working knowledge network."
        case .systemsIntegration: "Projects are joining models, data, tools, and safeguards."
        case .autonomousReasoning: "Advanced systems are being calibrated and verified."
        case .commissioned: "Every learning component is installed and operational."
        }
    }
}

enum AIConstructionPresentation: Sendable {
    case dashboard
    case profile
}

/// The primary live learning-progress visualization used on the dashboard and profile.
struct AIConstructionProgressView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let snapshot: AIAssemblyProgress
    var presentation: AIConstructionPresentation = .dashboard

    var body: some View {
        VStack(alignment: .leading, spacing: AESpacing.lg) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .center, spacing: AESpacing.xl) {
                    assemblyCopy
                        .frame(minWidth: 320, maxWidth: 490, alignment: .leading)
                    Spacer(minLength: AESpacing.sm)
                    animatedAssembly
                        .frame(minWidth: 320, idealWidth: 430, maxWidth: 520)
                        .frame(height: presentation == .dashboard ? 310 : 280)
                }

                VStack(alignment: .leading, spacing: AESpacing.lg) {
                    assemblyCopy
                    animatedAssembly
                        .frame(maxWidth: .infinity)
                        .frame(height: presentation == .dashboard ? 285 : 250)
                }
            }

            assemblyProgressRail
            componentTelemetry
        }
        .padding(cardPadding)
        .background(cardBackground)
        .overlay(cardBorder)
        .shadow(color: AEColor.shadow(colorScheme), radius: 32, y: 16)
        .animation(reduceMotion ? nil : AEMotion.gentle, value: snapshot.fractionComplete)
        .accessibilityElement(children: .contain)
    }

    private var assemblyCopy: some View {
        VStack(alignment: .leading, spacing: AESpacing.md) {
            HStack(spacing: AESpacing.xs) {
                Circle()
                    .fill(snapshot.stage == .commissioned ? AEColor.signal : AEColor.amber)
                    .frame(width: 7, height: 7)
                    .aeGlow(color: snapshot.stage == .commissioned ? AEColor.signal : AEColor.amber, radius: 8)
                Text(snapshot.stage == .commissioned ? "ASSEMBLY COMPLETE" : "AI ASSEMBLY / LIVE")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .tracking(1.25)
                    .foregroundStyle(snapshot.stage == .commissioned ? AEColor.readableSignal(colorScheme) : AEColor.readableAmber(colorScheme))
            }

            Text(presentation == .dashboard ? "Build your AI." : "Your AI build telemetry")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .tracking(-0.7)
                .foregroundStyle(AEColor.textPrimary(colorScheme))
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: AESpacing.xs) {
                Text(snapshot.stage.title)
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .foregroundStyle(AEColor.readableViolet(colorScheme))
                Text(snapshot.stage.detail)
                    .font(.aeBody)
                    .foregroundStyle(AEColor.textSecondary(colorScheme))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text("Each verified lesson, completed course, and project milestone installs another part of this system.")
                .font(.aeCallout)
                .foregroundStyle(AEColor.textSecondary(colorScheme))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var animatedAssembly: some View {
        AIConstructionScene(progress: snapshot.fractionComplete, reduceMotion: reduceMotion)
            .accessibilityHidden(true)
    }

    private var assemblyProgressRail: some View {
        VStack(alignment: .leading, spacing: AESpacing.sm) {
            HStack(alignment: .firstTextBaseline) {
                Text("ASSEMBLY PROGRESS")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .tracking(1)
                    .foregroundStyle(AEColor.textTertiary(colorScheme))
                Spacer()
                Text("\(snapshot.percentage)%")
                    .font(.system(.title3, design: .monospaced, weight: .bold))
                    .foregroundStyle(AEColor.readableSignal(colorScheme))
                    .contentTransition(.numericText())
            }

            GeometryReader { proxy in
                let width = max(proxy.size.width, 1)
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AEColor.stroke(colorScheme))
                    Capsule()
                        .fill(AEGradient.spectral)
                        .frame(width: width * snapshot.fractionComplete)
                        .aeGlow(color: AEColor.signal, radius: 10, intensity: snapshot.fractionComplete > 0 ? 0.9 : 0)

                    ForEach(AIAssemblyStage.allCases, id: \.rawValue) { stage in
                        Circle()
                            .fill(snapshot.fractionComplete >= stage.threshold ? AEColor.signal : AEColor.surfaceElevated(colorScheme))
                            .overlay(Circle().stroke(AEColor.strokeStrong(colorScheme), lineWidth: 1))
                            .frame(width: 8, height: 8)
                            .offset(x: max(min(width * stage.threshold - 4, width - 8), 0))
                    }
                }
            }
            .frame(height: 8)

            HStack {
                Text(snapshot.nextStage.map { "Next: \($0.title)" } ?? "All systems online")
                Spacer()
                Text(snapshot.remainingUnits == 1 ? "1 component remains" : "\(snapshot.remainingUnits) components remain")
            }
            .font(.aeCaption)
            .foregroundStyle(AEColor.textTertiary(colorScheme))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("AI assembly \(snapshot.percentage) percent complete. \(snapshot.stage.title).")
        .accessibilityValue(snapshot.remainingUnits == 0 ? "All systems online" : "\(snapshot.remainingUnits) learning components remain")
    }

    private var componentTelemetry: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: AESpacing.sm) {
                telemetryPill(icon: "checkmark.seal.fill", title: "Lessons", value: snapshot.completedLessons, total: snapshot.totalLessons, color: AEColor.signal)
                telemetryPill(icon: "rectangle.stack.fill", title: "Courses", value: snapshot.completedCourses, total: snapshot.totalCourses, color: AEColor.azure)
                telemetryPill(icon: "hammer.fill", title: "Build nodes", value: snapshot.completedMilestones, total: snapshot.totalMilestones, color: AEColor.violet)
            }

            VStack(alignment: .leading, spacing: AESpacing.sm) {
                telemetryPill(icon: "checkmark.seal.fill", title: "Lessons", value: snapshot.completedLessons, total: snapshot.totalLessons, color: AEColor.signal)
                telemetryPill(icon: "rectangle.stack.fill", title: "Courses", value: snapshot.completedCourses, total: snapshot.totalCourses, color: AEColor.azure)
                telemetryPill(icon: "hammer.fill", title: "Build nodes", value: snapshot.completedMilestones, total: snapshot.totalMilestones, color: AEColor.violet)
            }
        }
    }

    private func telemetryPill(icon: String, title: String, value: Int, total: Int, color: Color) -> some View {
        HStack(spacing: AESpacing.xs) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(title)
                .foregroundStyle(AEColor.textSecondary(colorScheme))
            Spacer(minLength: AESpacing.xs)
            Text("\(value)/\(total)")
                .foregroundStyle(AEColor.textPrimary(colorScheme))
                .contentTransition(.numericText())
        }
        .font(.aeCaption)
        .padding(.horizontal, AESpacing.sm)
        .padding(.vertical, 9)
        .frame(maxWidth: .infinity)
        .background(color.opacity(colorScheme == .dark ? 0.08 : 0.06), in: RoundedRectangle(cornerRadius: AERadius.small, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AERadius.small, style: .continuous)
                .stroke(color.opacity(0.15), lineWidth: 1)
        }
    }

    private var cardPadding: CGFloat {
        #if os(macOS)
        AESpacing.xl
        #else
        AESpacing.lg
        #endif
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [AEColor.surfaceElevated(colorScheme), AEColor.canvasRaised(colorScheme)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(alignment: .topTrailing) {
                Circle()
                    .fill(AEColor.violet.opacity(colorScheme == .dark ? 0.15 : 0.08))
                    .frame(width: 420, height: 420)
                    .blur(radius: 85)
                    .offset(x: 150, y: -230)
                    .accessibilityHidden(true)
            }
            .overlay(alignment: .bottomLeading) {
                Circle()
                    .fill(AEColor.signal.opacity(colorScheme == .dark ? 0.08 : 0.045))
                    .frame(width: 300, height: 300)
                    .blur(radius: 75)
                    .offset(x: -130, y: 190)
                    .accessibilityHidden(true)
            }
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .stroke(
                LinearGradient(
                    colors: [AEColor.signal.opacity(0.42), AEColor.violet.opacity(0.24), AEColor.stroke(colorScheme)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
    }
}

/// A low-profile version intended for a sidebar directly above its ordinary progress bar.
struct AIConstructionMiniatureView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let snapshot: AIAssemblyProgress

    var body: some View {
        HStack(spacing: AESpacing.xs) {
            AIConstructionScene(progress: snapshot.fractionComplete, reduceMotion: reduceMotion, density: .miniature)
                .frame(width: 58, height: 58)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text("AI BUILD / \(snapshot.percentage)%")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .tracking(0.45)
                    .foregroundStyle(AEColor.readableSignal(colorScheme))
                    .minimumScaleFactor(0.82)
                Text(snapshot.stage.shortTitle)
                    .font(.aeCallout)
                    .foregroundStyle(AEColor.textPrimary(colorScheme))
                    .lineLimit(1)
                Text(snapshot.nextStage.map { "Next · \($0.shortTitle)" } ?? "All systems online")
                    .font(.aeCaption)
                    .foregroundStyle(AEColor.textTertiary(colorScheme))
                    .lineLimit(1)
            }
            .layoutPriority(1)
            Spacer(minLength: 0)
        }
        .padding(10)
        .background(AEColor.surface(colorScheme).opacity(0.78), in: RoundedRectangle(cornerRadius: AERadius.medium, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AERadius.medium, style: .continuous)
                .stroke(AEColor.stroke(colorScheme), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("AI build, \(snapshot.stage.title), \(snapshot.percentage) percent complete")
    }
}

/// A brief completion acknowledgement that can be embedded in lesson or milestone overlays.
struct AIComponentInstalledBadge: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isEnergized = false

    let progress: Double
    var componentName: String = "Neural component installed"

    var body: some View {
        HStack(spacing: AESpacing.sm) {
            ZStack {
                ForEach(0..<5, id: \.self) { index in
                    Circle()
                        .fill(index == 0 ? AEColor.signal : AEColor.azure)
                        .frame(width: index == 0 ? 10 : 5, height: index == 0 ? 10 : 5)
                        .offset(nodeOffset(index))
                        .opacity(isEnergized ? 1 : 0.22)
                        .scaleEffect(isEnergized ? 1 : 0.35)
                        .animation(
                            reduceMotion ? nil : .spring(response: 0.44, dampingFraction: 0.66).delay(Double(index) * 0.055),
                            value: isEnergized
                        )
                }
                Circle()
                    .stroke(AEColor.signal.opacity(isEnergized ? 0.55 : 0.12), lineWidth: 1)
                    .frame(width: 42, height: 42)
                    .scaleEffect(isEnergized ? 1 : 0.55)
                    .opacity(isEnergized ? 1 : 0)
            }
            .frame(width: 48, height: 48)
            .aeGlow(color: AEColor.signal, radius: isEnergized ? 14 : 0)

            VStack(alignment: .leading, spacing: 2) {
                Text(componentName)
                    .font(.aeLabel)
                    .foregroundStyle(AEColor.textPrimary(colorScheme))
                Text("AI assembly is now \(Int((min(max(progress, 0), 1) * 100).rounded()))% complete")
                    .font(.aeCaption)
                    .foregroundStyle(AEColor.textSecondary(colorScheme))
            }
        }
        .padding(.horizontal, AESpacing.md)
        .padding(.vertical, AESpacing.sm)
        .background(AEColor.signal.opacity(colorScheme == .dark ? 0.09 : 0.06), in: RoundedRectangle(cornerRadius: AERadius.medium, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AERadius.medium, style: .continuous)
                .stroke(AEColor.signal.opacity(0.25), lineWidth: 1)
        }
        .onAppear {
            if reduceMotion {
                isEnergized = true
            } else {
                withAnimation(AEMotion.gentle) { isEnergized = true }
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func nodeOffset(_ index: Int) -> CGSize {
        switch index {
        case 1: CGSize(width: -13, height: -9)
        case 2: CGSize(width: 14, height: -11)
        case 3: CGSize(width: -14, height: 12)
        case 4: CGSize(width: 13, height: 11)
        default: .zero
        }
    }
}

private struct AIConstructionScene: View {
    enum Density {
        case full
        case miniature
    }

    @Environment(\.colorScheme) private var colorScheme

    let progress: Double
    let reduceMotion: Bool
    var density: Density = .full

    var body: some View {
        if reduceMotion {
            scene(phase: 0.22)
        } else {
            TimelineView(.animation(minimumInterval: animationInterval)) { timeline in
                scene(phase: phase(for: timeline.date))
            }
        }
    }

    private var animationInterval: TimeInterval {
        if ProcessInfo.processInfo.isLowPowerModeEnabled { return 0.5 }
        return density == .miniature ? 0.2 : 1.0 / 12.0
    }

    private func phase(for date: Date) -> Double {
        date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 8) / 8
    }

    private func scene(phase: Double) -> some View {
        Canvas(rendersAsynchronously: true) { context, size in
            let p = min(max(progress, 0), 1)
            let center = CGPoint(x: size.width * 0.5, y: size.height * 0.49)
            let scale = min(size.width / 430, size.height / 300)

            drawGrid(context: &context, size: size, scale: scale)
            drawScaffold(context: &context, center: center, scale: scale, phase: phase)
            drawSilhouette(context: &context, center: center, scale: scale, progress: p, phase: phase)
            drawNeuralLattice(context: &context, center: center, scale: scale, progress: p, phase: phase)
            drawScanner(context: &context, size: size, center: center, scale: scale, progress: p, phase: phase)

            if density == .full {
                let label = Text(p >= 1 ? "SYSTEM ONLINE" : "ASSEMBLY \(Int((p * 100).rounded()))%")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(
                        p >= 1
                            ? AEColor.readableSignal(colorScheme)
                            : AEColor.readableAzure(colorScheme)
                    )
                context.draw(label, at: CGPoint(x: size.width * 0.5, y: size.height - 13))
            }
        }
        .background {
            RadialGradient(
                colors: [AEColor.violet.opacity(colorScheme == .dark ? 0.15 : 0.08), .clear],
                center: .center,
                startRadius: 4,
                endRadius: 180
            )
        }
    }

    private func drawGrid(context: inout GraphicsContext, size: CGSize, scale: CGFloat) {
        guard density == .full else { return }
        let gridColor = colorScheme == .dark ? Color.white : Color.indigo
        var grid = Path()
        let step = max(24 * scale, 18)
        for x in stride(from: CGFloat.zero, through: size.width, by: step) {
            grid.move(to: CGPoint(x: x, y: 0))
            grid.addLine(to: CGPoint(x: x, y: size.height))
        }
        for y in stride(from: CGFloat.zero, through: size.height, by: step) {
            grid.move(to: CGPoint(x: 0, y: y))
            grid.addLine(to: CGPoint(x: size.width, y: y))
        }
        context.stroke(grid, with: .color(gridColor.opacity(0.035)), lineWidth: 0.6)
    }

    private func drawScaffold(context: inout GraphicsContext, center: CGPoint, scale: CGFloat, phase: Double) {
        let radius = 116 * scale
        let pulse = 0.72 + 0.18 * sin(phase * .pi * 2)

        for index in 0..<3 {
            let inset = CGFloat(index) * 17 * scale
            let rect = CGRect(
                x: center.x - radius + inset,
                y: center.y - radius * 0.82 + inset * 0.55,
                width: (radius - inset) * 2,
                height: radius * 1.64 - inset * 1.1
            )
            context.stroke(
                Path(ellipseIn: rect),
                with: .color((index == 0 ? AEColor.violet : AEColor.azure).opacity((0.10 + Double(index) * 0.025) * pulse)),
                style: StrokeStyle(lineWidth: index == 0 ? 1.1 : 0.7, dash: [5 * scale, 7 * scale])
            )
        }

        let bracketColor = AEColor.textTertiary(colorScheme).opacity(0.32)
        let w = 144 * scale
        let h = 117 * scale
        let arm = 19 * scale
        var brackets = Path()
        for sx: CGFloat in [-1, 1] {
            for sy: CGFloat in [-1, 1] {
                let x = center.x + sx * w
                let y = center.y + sy * h
                brackets.move(to: CGPoint(x: x - sx * arm, y: y))
                brackets.addLine(to: CGPoint(x: x, y: y))
                brackets.addLine(to: CGPoint(x: x, y: y - sy * arm))
            }
        }
        context.stroke(brackets, with: .color(bracketColor), lineWidth: 1)
    }

    private func drawSilhouette(
        context: inout GraphicsContext,
        center: CGPoint,
        scale: CGFloat,
        progress: Double,
        phase: Double
    ) {
        let outline = headPath(center: center, scale: scale)
        context.stroke(
            outline,
            with: .color(AEColor.textTertiary(colorScheme).opacity(0.28)),
            style: StrokeStyle(lineWidth: 1.15, dash: [3 * scale, 4 * scale])
        )

        var activeContext = context
        activeContext.clip(to: Path(CGRect(
            x: center.x - 105 * scale,
            y: center.y + 102 * scale - 204 * scale * CGFloat(progress),
            width: 210 * scale,
            height: 206 * scale * CGFloat(progress)
        )))
        activeContext.fill(
            outline,
            with: .linearGradient(
                Gradient(colors: [AEColor.violet.opacity(0.04), AEColor.azure.opacity(0.16), AEColor.signal.opacity(0.07)]),
                startPoint: CGPoint(x: center.x, y: center.y - 100 * scale),
                endPoint: CGPoint(x: center.x, y: center.y + 100 * scale)
            )
        )
        activeContext.stroke(
            outline,
            with: .linearGradient(
                Gradient(colors: [AEColor.violet, AEColor.azure, AEColor.signal]),
                startPoint: CGPoint(x: center.x, y: center.y - 100 * scale),
                endPoint: CGPoint(x: center.x, y: center.y + 100 * scale)
            ),
            lineWidth: 1.8
        )

        let coreRadius = (progress >= 0.08 ? 25 : 14) * scale
        let coreCenter = CGPoint(x: center.x, y: center.y + 17 * scale)
        context.fill(
            Path(ellipseIn: CGRect(x: coreCenter.x - coreRadius, y: coreCenter.y - coreRadius, width: coreRadius * 2, height: coreRadius * 2)),
            with: .radialGradient(
                Gradient(colors: [AEColor.signal.opacity(progress >= 0.08 ? 0.9 : 0.18), AEColor.azure.opacity(0.16), .clear]),
                center: coreCenter,
                startRadius: 1,
                endRadius: coreRadius
            )
        )

        if progress >= 0.08 {
            let ringPulse = 1 + CGFloat(sin(phase * .pi * 2)) * 0.05
            let ring = CGRect(
                x: coreCenter.x - 31 * scale * ringPulse,
                y: coreCenter.y - 31 * scale * ringPulse,
                width: 62 * scale * ringPulse,
                height: 62 * scale * ringPulse
            )
            context.stroke(Path(ellipseIn: ring), with: .color(AEColor.signal.opacity(0.45)), lineWidth: 1.2)
        }
    }

    private func headPath(center: CGPoint, scale: CGFloat) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: center.x, y: center.y - 101 * scale))
        path.addCurve(
            to: CGPoint(x: center.x + 75 * scale, y: center.y - 51 * scale),
            control1: CGPoint(x: center.x + 43 * scale, y: center.y - 103 * scale),
            control2: CGPoint(x: center.x + 74 * scale, y: center.y - 82 * scale)
        )
        path.addLine(to: CGPoint(x: center.x + 70 * scale, y: center.y + 24 * scale))
        path.addCurve(
            to: CGPoint(x: center.x + 37 * scale, y: center.y + 66 * scale),
            control1: CGPoint(x: center.x + 69 * scale, y: center.y + 45 * scale),
            control2: CGPoint(x: center.x + 55 * scale, y: center.y + 58 * scale)
        )
        path.addLine(to: CGPoint(x: center.x + 31 * scale, y: center.y + 89 * scale))
        path.addCurve(
            to: CGPoint(x: center.x - 31 * scale, y: center.y + 89 * scale),
            control1: CGPoint(x: center.x + 12 * scale, y: center.y + 100 * scale),
            control2: CGPoint(x: center.x - 12 * scale, y: center.y + 100 * scale)
        )
        path.addLine(to: CGPoint(x: center.x - 37 * scale, y: center.y + 66 * scale))
        path.addCurve(
            to: CGPoint(x: center.x - 70 * scale, y: center.y + 24 * scale),
            control1: CGPoint(x: center.x - 55 * scale, y: center.y + 58 * scale),
            control2: CGPoint(x: center.x - 69 * scale, y: center.y + 45 * scale)
        )
        path.addLine(to: CGPoint(x: center.x - 75 * scale, y: center.y - 51 * scale))
        path.addCurve(
            to: CGPoint(x: center.x, y: center.y - 101 * scale),
            control1: CGPoint(x: center.x - 74 * scale, y: center.y - 82 * scale),
            control2: CGPoint(x: center.x - 43 * scale, y: center.y - 103 * scale)
        )
        path.closeSubpath()
        return path
    }

    private func drawNeuralLattice(
        context: inout GraphicsContext,
        center: CGPoint,
        scale: CGFloat,
        progress: Double,
        phase: Double
    ) {
        let points = latticePoints.map { point in
            CGPoint(x: center.x + point.x * scale, y: center.y + point.y * scale)
        }
        let activeCount = min(Int((Double(points.count) * progress).rounded(.up)), points.count)

        for (from, to) in latticeEdges {
            guard points.indices.contains(from), points.indices.contains(to) else { continue }
            let isActive = from < activeCount && to < activeCount
            var edge = Path()
            edge.move(to: points[from])
            edge.addLine(to: points[to])
            context.stroke(
                edge,
                with: .color(isActive ? AEColor.azure.opacity(0.55) : AEColor.textTertiary(colorScheme).opacity(0.13)),
                lineWidth: isActive ? 1.2 : 0.65
            )
        }

        for (index, point) in points.enumerated() {
            let isActive = index < activeCount
            let baseRadius: CGFloat = index % 6 == 0 ? 4.2 : 2.6
            let pulse = isActive ? 1 + CGFloat(sin(phase * .pi * 2 + Double(index))) * 0.12 : 1
            let radius = baseRadius * scale * pulse
            context.fill(
                Path(ellipseIn: CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)),
                with: .color(isActive ? (index.isMultiple(of: 3) ? AEColor.signal : AEColor.azure) : AEColor.textTertiary(colorScheme).opacity(0.23))
            )
        }

        guard density == .full, activeCount > 3 else { return }
        let particles = min(max(activeCount / 4, 2), 10)
        for index in 0..<particles {
            let angle = phase * .pi * 2 + Double(index) / Double(particles) * .pi * 2
            let radius = (92 + CGFloat(index % 3) * 13) * scale
            let point = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius * 0.72
            )
            context.fill(
                Path(ellipseIn: CGRect(x: point.x - 1.8 * scale, y: point.y - 1.8 * scale, width: 3.6 * scale, height: 3.6 * scale)),
                with: .color(index.isMultiple(of: 2) ? AEColor.signal : AEColor.violet)
            )
        }
    }

    private func drawScanner(
        context: inout GraphicsContext,
        size: CGSize,
        center: CGPoint,
        scale: CGFloat,
        progress: Double,
        phase: Double
    ) {
        guard density == .full, progress < 1 else { return }
        let y = center.y - 105 * scale + 210 * scale * CGFloat(phase)
        let xInset = max((size.width - 210 * scale) / 2, 4)
        var scan = Path()
        scan.move(to: CGPoint(x: xInset, y: y))
        scan.addLine(to: CGPoint(x: size.width - xInset, y: y))
        context.stroke(
            scan,
            with: .linearGradient(
                Gradient(colors: [.clear, AEColor.signal.opacity(0.75), .clear]),
                startPoint: CGPoint(x: xInset, y: y),
                endPoint: CGPoint(x: size.width - xInset, y: y)
            ),
            lineWidth: 1
        )
    }

    private var latticePoints: [CGPoint] {
        [
            CGPoint(x: 0, y: -78), CGPoint(x: -29, y: -70), CGPoint(x: 30, y: -69),
            CGPoint(x: -51, y: -47), CGPoint(x: -18, y: -44), CGPoint(x: 17, y: -46), CGPoint(x: 52, y: -45),
            CGPoint(x: -56, y: -13), CGPoint(x: -27, y: -16), CGPoint(x: 0, y: -19), CGPoint(x: 28, y: -14), CGPoint(x: 57, y: -11),
            CGPoint(x: -48, y: 18), CGPoint(x: -21, y: 14), CGPoint(x: 0, y: 17), CGPoint(x: 22, y: 15), CGPoint(x: 48, y: 20),
            CGPoint(x: -37, y: 46), CGPoint(x: -13, y: 43), CGPoint(x: 14, y: 43), CGPoint(x: 38, y: 47),
            CGPoint(x: -23, y: 70), CGPoint(x: 0, y: 76), CGPoint(x: 24, y: 69),
            CGPoint(x: -62, y: 40), CGPoint(x: 63, y: 40), CGPoint(x: -66, y: -35), CGPoint(x: 66, y: -34),
            CGPoint(x: -39, y: -84), CGPoint(x: 40, y: -83), CGPoint(x: -6, y: -52), CGPoint(x: 7, y: 51)
        ]
    }

    private var latticeEdges: [(Int, Int)] {
        [
            (0, 1), (0, 2), (1, 3), (1, 4), (2, 5), (2, 6),
            (3, 7), (4, 8), (4, 9), (5, 9), (5, 10), (6, 11),
            (7, 8), (8, 9), (9, 10), (10, 11), (7, 12), (8, 13),
            (9, 14), (10, 15), (11, 16), (12, 13), (13, 14), (14, 15),
            (15, 16), (12, 17), (13, 18), (15, 19), (16, 20), (17, 18),
            (18, 19), (19, 20), (17, 21), (18, 22), (19, 22), (20, 23),
            (21, 22), (22, 23), (24, 12), (25, 16), (26, 3), (27, 6),
            (28, 1), (29, 2), (30, 4), (30, 5), (31, 18), (31, 19)
        ]
    }
}
