import SwiftUI

struct ProgressProfileView: View {
    @EnvironmentObject private var state: AppState
    @Environment(\.colorScheme) private var colorScheme
    @State private var showResetConfirmation = false
    @State private var showTutorSettings = false

    var body: some View {
        ZStack {
            AEFrontierBackground(accent: AEColor.signal, intensity: 0.58)

            ScrollView {
                VStack(alignment: .leading, spacing: AESpacing.xl) {
                    profileHero
                    AIConstructionProgressView(snapshot: assemblySnapshot, presentation: .profile)
                    achievementGrid

                    ViewThatFits(in: .horizontal) {
                        HStack(alignment: .top, spacing: AESpacing.lg) {
                            skillMatrix.frame(minWidth: 330)
                            roleReadiness.frame(minWidth: 330)
                        }
                        VStack(alignment: .leading, spacing: AESpacing.lg) {
                            skillMatrix
                            roleReadiness
                        }
                    }

                    learningSettings
                }
                .padding(.horizontal, responsivePadding)
                .padding(.vertical, AESpacing.lg)
                .frame(maxWidth: 1_160)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Progress")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .confirmationDialog(
            "Reset all learning progress?",
            isPresented: $showResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset progress", role: .destructive) { state.progress.reset() }
        } message: {
            Text("Completed lessons, XP, streaks, bookmarks, and project milestones will be removed from this device.")
        }
        .sheet(isPresented: $showTutorSettings) {
            TutorSettingsView(tutor: state.tutor)
        }
    }

    private var profileHero: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: AESpacing.lg) {
                profileIdentity
                Spacer()
                totalXP
            }
            VStack(alignment: .leading, spacing: AESpacing.lg) {
                profileIdentity
                totalXP
            }
        }
        .padding(AESpacing.xl)
        .aeGlassSurface(cornerRadius: 28, tint: AEColor.signal)
    }

    private var profileIdentity: some View {
        HStack(spacing: AESpacing.lg) {
            ZStack {
                Circle()
                    .stroke(AEGradient.spectral, lineWidth: 3)
                    .frame(width: 92, height: 92)
                    .aeGlow(color: AEColor.signal, radius: 22, intensity: 0.8)
                Circle()
                    .fill(AEColor.textPrimary(colorScheme).opacity(0.055))
                    .frame(width: 78, height: 78)
                Text("AI")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(AEGradient.signal)
            }

            VStack(alignment: .leading, spacing: AESpacing.xs) {
                Text("ENGINEER PROFILE")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .tracking(1.2)
                    .foregroundStyle(AEColor.readableSignal(colorScheme))
                Text("Your learning signal")
                    .aeTextRole(.display)
                    .foregroundStyle(AEColor.textPrimary(colorScheme))
                Text("Level \(currentLevel) · \(xpToNextLevel) XP to the next level")
                    .font(.aeCallout)
                    .foregroundStyle(AEColor.textSecondary(colorScheme))
                ProgressView(value: levelProgress)
                    .tint(AEColor.signal)
                    .frame(maxWidth: 380)
            }
        }
    }

    private var totalXP: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(state.progress.totalXP)")
                .aeTextRole(.hero)
                .foregroundStyle(AEColor.textPrimary(colorScheme))
            Text("TOTAL XP")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .tracking(1)
                .foregroundStyle(AEColor.textTertiary(colorScheme))
        }
    }

    private var achievementGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 190), spacing: AESpacing.md)], spacing: AESpacing.md) {
            ProfileMetric(icon: "flame.fill", value: "\(state.progress.streak)", label: "day streak", color: AEColor.amber)
            ProfileMetric(icon: "checkmark.circle.fill", value: "\(state.progress.completedLessonCount)", label: "lessons complete", color: AEColor.signal)
            ProfileMetric(icon: "hammer.fill", value: "\(completedMilestones)", label: "project milestones", color: AEColor.coral)
            ProfileMetric(icon: "bookmark.fill", value: "\(state.progress.value.bookmarkedCourseIDs.count)", label: "saved courses", color: AEColor.violet)
        }
    }

    private var skillMatrix: some View {
        VStack(alignment: .leading, spacing: AESpacing.lg) {
            VStack(alignment: .leading, spacing: 3) {
                Text("SKILL MATRIX")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .tracking(1)
                    .foregroundStyle(AEColor.readableAzure(colorScheme))
                Text("Production capabilities")
                    .font(.aeTitle)
                    .foregroundStyle(AEColor.textPrimary(colorScheme))
            }

            ForEach(state.skillMetrics) { metric in
                SkillMetricRow(metric: metric)
            }
        }
        .padding(AESpacing.lg)
        .frame(maxWidth: .infinity, minHeight: 410, alignment: .topLeading)
        .aeGlassSurface(tint: AEColor.azure)
    }

    private var roleReadiness: some View {
        VStack(alignment: .leading, spacing: AESpacing.lg) {
            VStack(alignment: .leading, spacing: 3) {
                Text("ROLE READINESS")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .tracking(1)
                    .foregroundStyle(AEColor.readableViolet(colorScheme))
                Text("AI Engineer path")
                    .font(.aeTitle)
                    .foregroundStyle(AEColor.textPrimary(colorScheme))
            }

            ReadinessStage(index: 1, title: "Foundation", detail: "Python, APIs, model mechanics", progress: foundationProgress, color: AEColor.signal)
            ReadinessStage(index: 2, title: "Applied systems", detail: "RAG, tools, agents, workflows", progress: appliedProgress, color: AEColor.azure)
            ReadinessStage(index: 3, title: "Production", detail: "Evals, safety, observability, cost", progress: productionProgress, color: AEColor.violet)
            ReadinessStage(index: 4, title: "Portfolio", detail: "Complete two verified capstones", progress: portfolioProgress, color: AEColor.coral)
        }
        .padding(AESpacing.lg)
        .frame(maxWidth: .infinity, minHeight: 410, alignment: .topLeading)
        .aeGlassSurface(tint: AEColor.violet)
    }

    private var learningSettings: some View {
        VStack(alignment: .leading, spacing: AESpacing.lg) {
            VStack(alignment: .leading, spacing: 3) {
                Text("LEARNING SYSTEM")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .tracking(1)
                    .foregroundStyle(AEColor.readableSignal(colorScheme))
                Text("Tune your practice")
                    .font(.aeTitle)
                    .foregroundStyle(AEColor.textPrimary(colorScheme))
            }

            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Daily XP target").font(.aeHeading).foregroundStyle(AEColor.textPrimary(colorScheme))
                    Text("Choose a pace you can sustain every week.")
                        .font(.aeCallout)
                        .foregroundStyle(AEColor.textSecondary(colorScheme))
                }
                Spacer()
                Picker("Daily XP target", selection: Binding(
                    get: { state.progress.dailyGoal },
                    set: { state.progress.setDailyGoal($0) }
                )) {
                    Text("50 XP").tag(50)
                    Text("100 XP").tag(100)
                    Text("150 XP").tag(150)
                    Text("250 XP").tag(250)
                }
                .labelsHidden()
                .frame(maxWidth: 150)
            }

            Divider().overlay(AEColor.stroke(colorScheme))

            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Tutor Core").font(.aeHeading).foregroundStyle(AEColor.textPrimary(colorScheme))
                    Text("Offline by default · \(state.tutor.activeEngineName)")
                        .font(.aeCallout)
                        .foregroundStyle(AEColor.textSecondary(colorScheme))
                }
                Spacer()
                Button("Tutor settings") { showTutorSettings = true }
                    .buttonStyle(AEButtonStyle(.outline, size: .compact, tint: AEColor.violet))
            }

            Divider().overlay(AEColor.stroke(colorScheme))

            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Offline-first progress").font(.aeHeading).foregroundStyle(AEColor.textPrimary(colorScheme))
                    Text("Your lesson state is stored locally on this device.")
                        .font(.aeCallout)
                        .foregroundStyle(AEColor.textSecondary(colorScheme))
                }
                Spacer()
                Label("ACTIVE", systemImage: "checkmark.shield.fill")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(AEColor.readableSignal(colorScheme))
            }

            Divider().overlay(AEColor.stroke(colorScheme))

            Button(role: .destructive) { showResetConfirmation = true } label: {
                Label("Reset learning progress", systemImage: "arrow.counterclockwise")
            }
            .buttonStyle(.plain)
            .font(.aeLabel)
            .foregroundStyle(AEColor.readableCoral(colorScheme))
        }
        .padding(AESpacing.lg)
        .aeGlassSurface(tint: AEColor.signal)
    }

    private var currentLevel: Int { state.progress.totalXP / 500 + 1 }
    private var levelProgress: Double { Double(state.progress.totalXP % 500) / 500 }
    private var xpToNextLevel: Int { 500 - (state.progress.totalXP % 500) }
    private var completedMilestones: Int { assemblySnapshot.completedMilestones }

    private func courseProgress(at index: Int) -> Double {
        guard state.curriculum.courses.indices.contains(index) else { return 0 }
        return state.progress.courseProgress(state.curriculum.courses[index])
    }

    private var foundationProgress: Double { courseProgress(at: 1) }
    private var appliedProgress: Double { courseProgress(at: 0) }
    private var productionProgress: Double { max(courseProgress(at: 0) * 0.82, courseProgress(at: 2)) }
    private var portfolioProgress: Double {
        let portfolioProjects = Array(state.projects.prefix(2))
        let milestoneKeys = Set(portfolioProjects.flatMap { project in
            project.milestones.map { milestone in
                AIAssemblyProgress.milestoneKey(projectID: project.id, milestoneID: milestone.id)
            }
        })
        let completed = state.progress.value.completedMilestoneIDs.intersection(milestoneKeys).count
        return Double(completed) / Double(max(milestoneKeys.count, 1))
    }

    private var assemblySnapshot: AIAssemblyProgress {
        AIAssemblyProgress(
            courses: state.curriculum.courses,
            projects: state.projects,
            completedLessonIDs: state.progress.value.completedLessonIDs,
            completedMilestoneIDs: state.progress.value.completedMilestoneIDs
        )
    }

    private var responsivePadding: CGFloat {
        #if os(macOS)
        28
        #else
        20
        #endif
    }
}

private struct ProfileMetric: View {
    @Environment(\.colorScheme) private var colorScheme

    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: AESpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 38, height: 38)
                .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 11))
            VStack(alignment: .leading, spacing: 1) {
                Text(value).font(.aeHeading).foregroundStyle(AEColor.textPrimary(colorScheme))
                Text(label).font(.aeCaption).foregroundStyle(AEColor.textTertiary(colorScheme))
            }
        }
        .padding(AESpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .aeGlassSurface(cornerRadius: AERadius.medium, tint: color)
    }
}

private struct SkillMetricRow: View {
    @Environment(\.colorScheme) private var colorScheme

    let metric: SkillMetric

    var body: some View {
        let color = Color(hex: metric.color)
        VStack(spacing: 7) {
            HStack {
                Text(metric.name).font(.aeCallout).foregroundStyle(AEColor.textPrimary(colorScheme))
                Spacer()
                if metric.delta > 0 {
                    Text("+\(metric.delta)%")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(AEColor.readableSignal(colorScheme))
                }
                Text("\(Int(metric.value * 100))")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(AEColor.readableAccent(metric.color, colorScheme))
            }
            ProgressView(value: metric.value).tint(color)
        }
    }
}

private struct ReadinessStage: View {
    @Environment(\.colorScheme) private var colorScheme

    let index: Int
    let title: String
    let detail: String
    let progress: Double
    let color: Color

    var body: some View {
        HStack(spacing: AESpacing.md) {
            ZStack {
                Circle().stroke(AEColor.stroke(colorScheme), lineWidth: 4)
                Circle()
                    .trim(from: 0, to: min(max(progress, 0), 1))
                    .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(index)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(color)
            }
            .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.aeCallout).foregroundStyle(AEColor.textPrimary(colorScheme))
                Text(detail).font(.aeCaption).foregroundStyle(AEColor.textTertiary(colorScheme))
            }
            Spacer()
            Text("\(Int(min(max(progress, 0), 1) * 100))%")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
        }
    }
}
