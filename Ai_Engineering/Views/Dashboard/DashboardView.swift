import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var state: AppState
    @Environment(\.colorScheme) private var colorScheme
    @Binding var selection: AppSection
    @AppStorage("freemium.intro.dismissed") private var dismissedFreemiumIntro = false
    @State private var showIntroPaywall = false

    private let columns = [GridItem(.adaptive(minimum: 210), spacing: AESpacing.md)]

    var body: some View {
        ZStack {
            AEFrontierBackground(accent: AEColor.violet, intensity: 0.8)

            ScrollView {
                VStack(alignment: .leading, spacing: AESpacing.xl) {
                    dashboardHeader

                    if !state.subscription.hasAccess,
                       !state.subscription.isCheckingAccess,
                       !dismissedFreemiumIntro {
                        freemiumIntro
                    }

                    AIConstructionProgressView(snapshot: assemblySnapshot, presentation: .dashboard)

                    if let featured = state.featuredCourse {
                        FeaturedLearningCard(course: featured)
                    }

                    metrics
                    learningPath

                    ViewThatFits(in: .horizontal) {
                        HStack(alignment: .top, spacing: AESpacing.lg) {
                            WeeklyMomentumCard().frame(minWidth: 340)
                            SkillSnapshotCard().frame(minWidth: 340)
                        }
                        VStack(alignment: .leading, spacing: AESpacing.lg) {
                            WeeklyMomentumCard()
                            SkillSnapshotCard()
                        }
                    }
                }
                .padding(.horizontal, responsivePadding)
                .padding(.vertical, AESpacing.lg)
                .frame(maxWidth: 1_260)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("")
        .sheet(isPresented: $showIntroPaywall) {
            SubscriptionPaywallView(store: state.subscription)
                #if os(macOS)
                .frame(minWidth: 900, minHeight: 620)
                #endif
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private var responsivePadding: CGFloat {
        #if os(macOS)
        34
        #else
        20
        #endif
    }

    private var dashboardHeader: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .center, spacing: AESpacing.md) {
                headerCopy
                Spacer(minLength: AESpacing.md)
                headerMetrics
            }
            VStack(alignment: .leading, spacing: AESpacing.md) {
                headerCopy
                headerMetrics
            }
        }
    }

    private var headerCopy: some View {
        VStack(alignment: .leading, spacing: AESpacing.xs) {
            Text("LEARNING TERMINAL / 01")
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .tracking(1.35)
                .foregroundStyle(AEColor.readableSignal(colorScheme))
            Text("Build what comes next.")
                .aeTextRole(.display)
                .foregroundStyle(AEColor.textPrimary(colorScheme))
            Text("Production-grade AI engineering, one focused session at a time.")
                .aeTextRole(.body)
                .foregroundStyle(AEColor.textSecondary(colorScheme))
        }
    }

    private var headerMetrics: some View {
        HStack(spacing: AESpacing.sm) {
            HeaderMetric(icon: "flame.fill", value: "\(state.progress.streak)", label: "day streak", color: AEColor.amber)
            HeaderMetric(icon: "bolt.fill", value: "\(state.progress.totalXP)", label: "total XP", color: AEColor.signal)
        }
    }

    private var freemiumIntro: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .center, spacing: AESpacing.lg) {
                freemiumIntroCopy
                Spacer(minLength: AESpacing.md)
                freemiumIntroActions
            }
            VStack(alignment: .leading, spacing: AESpacing.md) {
                freemiumIntroCopy
                freemiumIntroActions
            }
        }
        .padding(AESpacing.lg)
        .aeGlassSurface(cornerRadius: AERadius.large, tint: AEColor.signal)
    }

    private var freemiumIntroCopy: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("START FREE · GO PRO WHEN READY")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .tracking(1)
                .foregroundStyle(AEColor.readableSignal(colorScheme))
            Text("Learn the fundamentals free")
                .font(.aeHeading)
                .foregroundStyle(AEColor.textPrimary(colorScheme))
            Text("The first module of every course is included. Pro unlocks all 400 lessons, labs, projects, and Tutor Core across iPhone, iPad, and Mac.")
                .font(.aeCallout)
                .foregroundStyle(AEColor.textSecondary(colorScheme))
                .frame(maxWidth: 650, alignment: .leading)
        }
    }

    private var freemiumIntroActions: some View {
        HStack(spacing: AESpacing.sm) {
            Button("Continue free") { dismissedFreemiumIntro = true }
                .buttonStyle(AEButtonStyle(.ghost, size: .compact))
            Button(storeTrialTitle) { showIntroPaywall = true }
                .buttonStyle(AEButtonStyle(.primary, size: .compact, tint: AEColor.signal))
        }
    }

    private var storeTrialTitle: String {
        state.subscription.isEligibleForTrial ? "Start free trial" : "Try Premium"
    }

    private var metrics: some View {
        LazyVGrid(columns: columns, spacing: AESpacing.md) {
            DashboardMetric(
                icon: "target",
                title: "Daily target",
                value: "\(state.progress.todayXP) / \(state.progress.dailyGoal)",
                caption: state.progress.todayXP >= state.progress.dailyGoal ? "Goal secured" : "XP earned today",
                progress: state.progress.dailyProgress,
                color: AEColor.signal
            )
            DashboardMetric(
                icon: "checkmark.circle.fill",
                title: "Lessons complete",
                value: "\(state.progress.completedLessonCount)",
                caption: "of \(state.totalLessonCount) in the catalog",
                progress: Double(state.progress.completedLessonCount) / Double(max(state.totalLessonCount, 1)),
                color: AEColor.azure
            )
            DashboardMetric(
                icon: "clock.fill",
                title: "Practice library",
                value: "\(state.totalLearningMinutes / 60)h",
                caption: "guided learning content",
                progress: 0.68,
                color: AEColor.violet
            )
            DashboardMetric(
                icon: "hammer.fill",
                title: "Project lab",
                value: "\(state.projects.count)",
                caption: "portfolio-ready builds",
                progress: 0.42,
                color: AEColor.coral
            )
        }
    }

    private var learningPath: some View {
        VStack(alignment: .leading, spacing: AESpacing.md) {
            SectionHeading(
                eyebrow: "YOUR PATH",
                title: "AI Engineer",
                detail: "From model calls to reliable systems",
                action: "Explore all",
                actionHandler: { selection = .learn }
            )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AESpacing.md) {
                    ForEach(Array(state.curriculum.courses.enumerated()), id: \.element.id) { index, course in
                        NavigationLink(value: course) {
                            PathCourseCard(
                                course: course,
                                index: index + 1,
                                progress: state.progress.courseProgress(course)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, AESpacing.xs)
            }
            .navigationDestination(for: Course.self) { course in
                CourseDetailView(course: course)
            }
        }
    }

    private var assemblySnapshot: AIAssemblyProgress {
        AIAssemblyProgress(
            courses: state.curriculum.courses,
            projects: state.projects,
            completedLessonIDs: state.progress.value.completedLessonIDs,
            completedMilestoneIDs: state.progress.value.completedMilestoneIDs
        )
    }
}

private struct HeaderMetric: View {
    @Environment(\.colorScheme) private var colorScheme

    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: AESpacing.xs) {
            Image(systemName: icon)
                .foregroundStyle(color)
            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(AEColor.textPrimary(colorScheme))
                Text(label)
                    .font(.aeCaption)
                    .foregroundStyle(AEColor.textTertiary(colorScheme))
            }
        }
        .padding(.horizontal, AESpacing.sm)
        .padding(.vertical, 10)
        .aeGlassSurface(cornerRadius: AERadius.medium, tint: color)
    }
}

private struct FeaturedLearningCard: View {
    @EnvironmentObject private var state: AppState
    @Environment(\.colorScheme) private var colorScheme
    let course: Course

    var body: some View {
        let accent = Color(hex: course.accent)
        ViewThatFits(in: .horizontal) {
            HStack(spacing: AESpacing.xl) {
                heroCopy(accent: accent)
                    .frame(width: 520, alignment: .leading)
                Spacer(minLength: AESpacing.md)
                NeuralOrbitView(accent: accent)
                    .frame(width: 250, height: 220)
            }
            VStack(alignment: .leading, spacing: AESpacing.lg) {
                heroCopy(accent: accent)
                #if os(macOS)
                NeuralOrbitView(accent: accent)
                    .frame(maxWidth: .infinity)
                    .frame(height: 210)
                #endif
            }
        }
        .padding(heroPadding)
        .background {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [AEColor.surfaceElevated(colorScheme), AEColor.canvasRaised(colorScheme)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(alignment: .topTrailing) {
                    Circle()
                        .fill(accent.opacity(0.17))
                        .frame(width: 360)
                        .blur(radius: 75)
                        .offset(x: 100, y: -180)
                }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(
                    LinearGradient(colors: [accent.opacity(0.55), AEColor.stroke(colorScheme)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
        }
        .shadow(color: accent.opacity(0.12), radius: 36, y: 12)
    }

    private func heroCopy(accent: Color) -> some View {
        let displayAccent = AEColor.readableAccent(course.accent, colorScheme)
        return VStack(alignment: .leading, spacing: AESpacing.md) {
            HStack(spacing: AESpacing.xs) {
                Circle().fill(accent).frame(width: 7, height: 7).aeGlow(color: accent, radius: 8)
                Text(state.progress.courseProgress(course) > 0 ? "CONTINUE LEARNING" : "START YOUR CORE PATH")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .tracking(1.25)
                    .foregroundStyle(displayAccent)
            }

            Text(course.title)
                .font(heroTitleFont)
                .tracking(-0.8)
                .foregroundStyle(AEColor.textPrimary(colorScheme))
                .fixedSize(horizontal: false, vertical: true)

            Text(course.summary)
                .aeTextRole(.body)
                .foregroundStyle(AEColor.textSecondary(colorScheme))
                .frame(maxWidth: 590, alignment: .leading)

            AEFlowLayout(spacing: AESpacing.xs) {
                ForEach(course.skills.prefix(4), id: \.self) { skill in
                    Text(skill)
                        .font(.aeCaption)
                        .foregroundStyle(AEColor.textPrimary(colorScheme).opacity(0.82))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AEColor.textPrimary(colorScheme).opacity(0.07), in: Capsule())
                }
            }

            HStack(spacing: AESpacing.md) {
                NavigationLink(value: course) {
                    Label(state.progress.courseProgress(course) > 0 ? "Resume course" : "Start course", systemImage: "arrow.right")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .foregroundStyle(Color.black.opacity(0.82))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 13)
                        .background(AEGradient.signal, in: Capsule())
                }
                .buttonStyle(.plain)

                Text("\(course.lessonCount) lessons · \(course.estimatedMinutes / 60)h")
                    .font(.aeCallout)
                    .foregroundStyle(AEColor.textSecondary(colorScheme))
            }
        }
    }

    private var heroPadding: CGFloat {
        #if os(macOS)
        AESpacing.xl
        #else
        AESpacing.lg
        #endif
    }

    private var heroTitleFont: Font {
        #if os(macOS)
        .aeHero
        #else
        .aeDisplay
        #endif
    }
}

private struct NeuralOrbitView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let accent: Color

    var body: some View {
        TimelineView(
            .animation(
                minimumInterval: ProcessInfo.processInfo.isLowPowerModeEnabled ? 0.25 : 1.0 / 15.0,
                paused: reduceMotion
            )
        ) { timeline in
            Canvas { context, size in
                let phase = timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 10) / 10
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let radius = min(size.width, size.height) * 0.34
                let nodes = (0..<9).map { index -> CGPoint in
                    let angle = (Double(index) / 9 * .pi * 2) + phase * .pi * 2
                    let ripple = 0.72 + Double(index % 3) * 0.14
                    return CGPoint(
                        x: center.x + cos(angle) * radius * ripple,
                        y: center.y + sin(angle) * radius * ripple * 0.68
                    )
                }

                for index in nodes.indices {
                    let next = nodes[(index + 2) % nodes.count]
                    var edge = Path()
                    edge.move(to: nodes[index])
                    edge.addLine(to: next)
                    context.stroke(edge, with: .color(accent.opacity(0.14)), lineWidth: 0.8)
                }

                for (index, point) in nodes.enumerated() {
                    let nodeRadius: CGFloat = index % 3 == 0 ? 5 : 3
                    context.fill(Path(ellipseIn: CGRect(x: point.x - nodeRadius, y: point.y - nodeRadius, width: nodeRadius * 2, height: nodeRadius * 2)), with: .color(index % 2 == 0 ? accent : AEColor.azure))
                }

                let coreRect = CGRect(x: center.x - 46, y: center.y - 46, width: 92, height: 92)
                context.fill(Path(ellipseIn: coreRect), with: .radialGradient(
                    Gradient(colors: [accent.opacity(0.7), accent.opacity(0.05)]),
                    center: center,
                    startRadius: 3,
                    endRadius: 48
                ))

                let mark = Text("AI")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(AEColor.textPrimary(colorScheme))
                context.draw(mark, at: center)
            }
        }
        .background {
            Circle().fill(accent.opacity(0.1)).blur(radius: 45).padding(40)
        }
        .accessibilityHidden(true)
    }
}

private struct DashboardMetric: View {
    @Environment(\.colorScheme) private var colorScheme

    let icon: String
    let title: String
    let value: String
    let caption: String
    let progress: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: AESpacing.sm) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .frame(width: 30, height: 30)
                    .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 9))
                Spacer()
                Text(title.uppercased())
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .tracking(0.8)
                    .foregroundStyle(AEColor.textTertiary(colorScheme))
            }

            Text(value)
                .font(.aeMetric)
                .foregroundStyle(AEColor.textPrimary(colorScheme))
            Text(caption)
                .font(.aeCaption)
                .foregroundStyle(AEColor.textSecondary(colorScheme))

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(AEColor.stroke(colorScheme))
                    Capsule()
                        .fill(LinearGradient(colors: [color, color.opacity(0.55)], startPoint: .leading, endPoint: .trailing))
                        .frame(width: proxy.size.width * min(max(progress, 0.025), 1))
                }
            }
            .frame(height: 4)
        }
        .padding(AESpacing.md)
        .frame(maxWidth: .infinity, minHeight: 156, alignment: .leading)
        .aeGlassSurface(cornerRadius: AERadius.medium, tint: color)
    }
}

private struct SectionHeading: View {
    @Environment(\.colorScheme) private var colorScheme

    let eyebrow: String
    let title: String
    let detail: String
    let action: String
    let actionHandler: () -> Void

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 3) {
                Text(eyebrow)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .tracking(1)
                    .foregroundStyle(AEColor.readableSignal(colorScheme))
                HStack(alignment: .firstTextBaseline, spacing: AESpacing.sm) {
                    Text(title).font(.aeTitle).foregroundStyle(AEColor.textPrimary(colorScheme))
                    Text(detail).font(.aeCallout).foregroundStyle(AEColor.textTertiary(colorScheme))
                }
            }
            Spacer()
            Button(action, action: actionHandler)
                .font(.aeLabel)
                .buttonStyle(.plain)
                .foregroundStyle(AEColor.readableSignal(colorScheme))
        }
    }
}

private struct PathCourseCard: View {
    @Environment(\.colorScheme) private var colorScheme

    let course: Course
    let index: Int
    let progress: Double

    var body: some View {
        let accent = Color(hex: course.accent)
        let displayAccent = AEColor.readableAccent(course.accent, colorScheme)
        VStack(alignment: .leading, spacing: AESpacing.md) {
            HStack {
                Text(String(format: "%02d", index))
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(displayAccent)
                Spacer()
                Image(systemName: course.icon)
                    .foregroundStyle(accent)
                    .frame(width: 34, height: 34)
                    .background(accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
            }
            Text(course.eyebrow.uppercased())
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .tracking(0.8)
                .foregroundStyle(AEColor.textTertiary(colorScheme))
            Text(course.title)
                .font(.aeHeading)
                .foregroundStyle(AEColor.textPrimary(colorScheme))
                .lineLimit(2)
            Text("\(course.lessonCount) lessons · \(course.difficulty)")
                .font(.aeCaption)
                .foregroundStyle(AEColor.textSecondary(colorScheme))
            ProgressView(value: progress)
                .tint(accent)
        }
        .padding(AESpacing.md)
        .frame(width: 250, height: 190, alignment: .leading)
        .aeGlassSurface(cornerRadius: AERadius.medium, tint: accent)
    }
}

private struct WeeklyMomentumCard: View {
    @EnvironmentObject private var state: AppState
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: AESpacing.md) {
            Text("WEEKLY MOMENTUM")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .tracking(1)
                .foregroundStyle(AEColor.readableSignal(colorScheme))
            Text("Consistency compounds.")
                .font(.aeHeading)
                .foregroundStyle(AEColor.textPrimary(colorScheme))
            HStack(alignment: .bottom, spacing: 9) {
                ForEach(Array(state.progress.activityForLastSevenDays().enumerated()), id: \.offset) { index, xp in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(index == 6 ? AEGradient.signal : LinearGradient(colors: [AEColor.violet.opacity(0.8), AEColor.azure.opacity(0.35)], startPoint: .top, endPoint: .bottom))
                            .frame(height: max(CGFloat(xp) / 2.5, 8))
                        Text(shortWeekday(offset: index - 6))
                            .font(.system(size: 9, weight: .semibold, design: .monospaced))
                            .foregroundStyle(AEColor.textTertiary(colorScheme))
                    }
                    .frame(maxWidth: 34)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 130, alignment: .bottom)
        }
        .padding(AESpacing.lg)
        .frame(maxWidth: .infinity, minHeight: 245, alignment: .topLeading)
        .aeGlassSurface(tint: AEColor.azure)
    }

    private func shortWeekday(offset: Int) -> String {
        let date = Calendar.current.date(byAdding: .day, value: offset, to: Date()) ?? Date()
        return date.formatted(.dateTime.weekday(.narrow))
    }
}

private struct SkillSnapshotCard: View {
    @EnvironmentObject private var state: AppState
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: AESpacing.md) {
            Text("SKILL SIGNAL")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .tracking(1)
                .foregroundStyle(AEColor.readableViolet(colorScheme))
            Text("Production readiness")
                .font(.aeHeading)
                .foregroundStyle(AEColor.textPrimary(colorScheme))

            ForEach(state.skillMetrics.prefix(4)) { skill in
                VStack(spacing: 6) {
                    HStack {
                        Text(skill.name).font(.aeCaption).foregroundStyle(AEColor.textSecondary(colorScheme))
                        Spacer()
                        Text("\(Int(skill.value * 100))%")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundStyle(AEColor.readableAccent(skill.color, colorScheme))
                    }
                    ProgressView(value: skill.value)
                        .tint(Color(hex: skill.color))
                }
            }
        }
        .padding(AESpacing.lg)
        .frame(maxWidth: .infinity, minHeight: 245, alignment: .topLeading)
        .aeGlassSurface(tint: AEColor.violet)
    }
}
