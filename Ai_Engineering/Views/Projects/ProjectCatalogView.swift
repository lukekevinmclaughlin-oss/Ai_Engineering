import EngineeringShared
import SwiftUI

struct ProjectCatalogView: View {
    @EnvironmentObject private var state: AppState
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedLevel = "All"
    @State private var searchText = ""

    private var levels: [String] {
        let available = Set(state.projects.map(\.difficulty))
        return ["All"] + ["Beginner", "Intermediate", "Advanced"].filter(available.contains)
    }

    private var projects: [LabProject] {
        state.projects.filter { project in
            let matchesLevel = selectedLevel == "All" || project.difficulty == selectedLevel
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            let matchesSearch = query.isEmpty || [
                project.title,
                project.subtitle,
                project.summary,
                project.skills.joined(separator: " ")
            ]
            .joined(separator: " ")
            .localizedCaseInsensitiveContains(query)
            return matchesLevel && matchesSearch
        }
    }

    private var showsFeaturedProject: Bool {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedLevel == "All"
    }

    private var gridProjects: [LabProject] {
        showsFeaturedProject ? Array(projects.dropFirst()) : projects
    }

    var body: some View {
        ZStack {
            AEFrontierBackground(accent: AEColor.coral, intensity: 0.6)

            ScrollView {
                VStack(alignment: .leading, spacing: AESpacing.xl) {
                    projectHeader
                    pathwayOverview
                    levelPicker
                    if showsFeaturedProject { featuredProject }

                    HStack {
                        Text(showsFeaturedProject ? "ALL BUILDS" : "MATCHING BUILDS")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .tracking(1.1)
                            .foregroundStyle(AEColor.readableCoral(colorScheme))
                        Spacer()
                        Text("\(projects.count) PROJECT\(projects.count == 1 ? "" : "S")")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundStyle(AEColor.textTertiary(colorScheme))
                    }

                    if gridProjects.isEmpty {
                        ContentUnavailableView(
                            "No projects found",
                            systemImage: "magnifyingglass",
                            description: Text("Try another skill, title, or difficulty.")
                        )
                        .frame(maxWidth: .infinity, minHeight: 320)
                    } else {
                        LazyVGrid(
                            columns: [GridItem(.adaptive(minimum: 300, maximum: 480), spacing: AESpacing.lg)],
                            spacing: AESpacing.lg
                        ) {
                            ForEach(gridProjects) { project in
                                NavigationLink(value: project) {
                                    ProjectCard(project: project)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal, 28)
                .padding(.vertical, AESpacing.lg)
                .frame(maxWidth: 1_220)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationDestination(for: LabProject.self) { project in
            ProjectDetailView(project: project)
        }
        .searchable(text: $searchText, placement: .automatic, prompt: "Search projects and skills")
        .navigationTitle("Projects")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private var projectHeader: some View {
        VStack(alignment: .leading, spacing: AESpacing.sm) {
            HStack(spacing: AESpacing.xs) {
                Circle().fill(AEColor.coral).frame(width: 7, height: 7).aeGlow(color: AEColor.coral, radius: 8)
                Text("PROJECT LAB / LIVE")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .tracking(1.3)
                    .foregroundStyle(AEColor.readableCoral(colorScheme))
            }
            Text("Build proof, not toy demos.")
                .aeTextRole(.display)
                .foregroundStyle(AEColor.textPrimary(colorScheme))
            Text("Start with a fully guided beginner build, then progress through intermediate systems and advanced portfolio work at your own pace.")
                .aeTextRole(.body)
                .foregroundStyle(AEColor.textSecondary(colorScheme))
                .frame(maxWidth: 760, alignment: .leading)

            HStack(spacing: AESpacing.lg) {
                ProjectCatalogStat(value: "\(state.projects.count)", label: "portfolio builds")
                ProjectCatalogStat(value: "\(state.projects.reduce(0) { $0 + $1.milestones.count })", label: "milestones")
                ProjectCatalogStat(value: "\(state.projects.reduce(0) { $0 + $1.estimatedHours })h", label: "practice")
            }
            .padding(.top, AESpacing.xs)
        }
    }

    private var pathwayOverview: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 220, maximum: 380), spacing: AESpacing.md)],
            spacing: AESpacing.md
        ) {
            ProjectPathStep(
                level: "Beginner",
                detail: "Guided from basic arithmetic and first code",
                icon: "figure.walk",
                accent: AEColor.signal,
                count: state.projects.filter { $0.difficulty == "Beginner" }.count,
                isSelected: selectedLevel == "Beginner"
            ) { selectLevel("Beginner") }

            ProjectPathStep(
                level: "Intermediate",
                detail: "Connect models, data, tools, and evaluations",
                icon: "point.3.connected.trianglepath.dotted",
                accent: AEColor.violet,
                count: state.projects.filter { $0.difficulty == "Intermediate" }.count,
                isSelected: selectedLevel == "Intermediate"
            ) { selectLevel("Intermediate") }

            ProjectPathStep(
                level: "Advanced",
                detail: "Design reliable production AI systems",
                icon: "building.columns.fill",
                accent: AEColor.amber,
                count: state.projects.filter { $0.difficulty == "Advanced" }.count,
                isSelected: selectedLevel == "Advanced"
            ) { selectLevel("Advanced") }
        }
    }

    private func selectLevel(_ level: String) {
        guard levels.contains(level) else { return }
        withAnimation(AEMotion.quick) { selectedLevel = level }
    }

    private var levelPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AESpacing.xs) {
                ForEach(levels, id: \.self) { level in
                    Button(level) {
                        withAnimation(AEMotion.quick) { selectedLevel = level }
                    }
                    .font(.aeLabel)
                    .buttonStyle(.plain)
                    .foregroundStyle(selectedLevel == level ? Color.black.opacity(0.8) : AEColor.textSecondary(colorScheme))
                    .padding(.horizontal, AESpacing.md)
                    .padding(.vertical, 9)
                    .background(selectedLevel == level ? AnyShapeStyle(AEGradient.signal) : AnyShapeStyle(AEColor.subtleFill(colorScheme)), in: Capsule())
                }
            }
        }
    }

    @ViewBuilder
    private var featuredProject: some View {
        if let project = state.projects.first {
            let accent = Color(hex: project.accent)
            NavigationLink(value: project) {
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: AESpacing.xl) {
                        FeaturedProjectCopy(project: project, accent: accent)
                        Spacer()
                        ProjectArchitectureVisual(accent: accent)
                            .frame(width: 360, height: 220)
                    }
                    VStack(alignment: .leading, spacing: AESpacing.lg) {
                        FeaturedProjectCopy(project: project, accent: accent)
                        ProjectArchitectureVisual(accent: accent)
                            .frame(maxWidth: .infinity)
                            .frame(height: 190)
                    }
                }
                .padding(AESpacing.xl)
                .background(AEColor.surfaceElevated(colorScheme), in: RoundedRectangle(cornerRadius: 28))
                .overlay(RoundedRectangle(cornerRadius: 28).stroke(LinearGradient(colors: [accent.opacity(0.4), AEColor.stroke(colorScheme)], startPoint: .topLeading, endPoint: .bottomTrailing)))
            }
            .buttonStyle(.plain)
        }
    }
}

private struct ProjectCatalogStat: View {
    @Environment(\.colorScheme) private var colorScheme
    let value: String
    let label: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 5) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(AEColor.textPrimary(colorScheme))
            Text(label)
                .font(.aeCaption)
                .foregroundStyle(AEColor.textTertiary(colorScheme))
        }
    }
}

private struct ProjectPathStep: View {
    @Environment(\.colorScheme) private var colorScheme
    let level: String
    let detail: String
    let icon: String
    let accent: Color
    let count: Int
    let isSelected: Bool
    let action: () -> Void

    private var textAccent: Color {
        switch level {
        case "Beginner": AEColor.readableSignal(colorScheme)
        case "Intermediate": AEColor.readableViolet(colorScheme)
        default: AEColor.readableAmber(colorScheme)
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AESpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(textAccent)
                    .frame(width: 42, height: 42)
                    .background(accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(level)
                            .font(.aeHeading)
                            .foregroundStyle(AEColor.textPrimary(colorScheme))
                        Spacer(minLength: AESpacing.xs)
                        Text("\(count)")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundStyle(textAccent)
                    }
                    Text(detail)
                        .font(.aeCaption)
                        .foregroundStyle(AEColor.textSecondary(colorScheme))
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(AESpacing.md)
            .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
            .background(AEColor.subtleFill(colorScheme).opacity(isSelected ? 1.35 : 0.78), in: RoundedRectangle(cornerRadius: AERadius.medium))
            .overlay {
                RoundedRectangle(cornerRadius: AERadius.medium)
                    .stroke(isSelected ? accent.opacity(0.6) : AEColor.stroke(colorScheme))
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(level), \(count) projects")
    }
}

private struct FeaturedProjectCopy: View {
    @Environment(\.colorScheme) private var colorScheme
    let project: LabProject
    let accent: Color

    private var textAccent: Color { AEColor.readableAccent(project.accent, colorScheme) }

    var body: some View {
        VStack(alignment: .leading, spacing: AESpacing.md) {
            Text(project.difficulty == "Beginner" ? "START HERE · GUIDED BUILD" : "RECOMMENDED CAPSTONE")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .tracking(1.1)
                .foregroundStyle(textAccent)
            Text(project.title)
                .aeTextRole(.display)
                .foregroundStyle(AEColor.textPrimary(colorScheme))
            Text(project.summary)
                .font(.aeBody)
                .foregroundStyle(AEColor.textSecondary(colorScheme))
                .frame(maxWidth: 560, alignment: .leading)
            HStack(spacing: AESpacing.md) {
                Label("\(project.estimatedHours) hours", systemImage: "clock.fill")
                Label(project.difficulty, systemImage: "chart.bar.fill")
                Label("\(project.xp) XP", systemImage: "bolt.fill")
            }
            .font(.aeCaption)
            .foregroundStyle(AEColor.textTertiary(colorScheme))
            Label("Open project workspace", systemImage: "arrow.right")
                .font(.aeLabel)
                .foregroundStyle(textAccent)
        }
    }
}

private struct ProjectArchitectureVisual: View {
    let accent: Color

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack {
                Path { path in
                    path.move(to: CGPoint(x: size.width * 0.15, y: size.height * 0.5))
                    path.addCurve(
                        to: CGPoint(x: size.width * 0.85, y: size.height * 0.5),
                        control1: CGPoint(x: size.width * 0.35, y: size.height * 0.05),
                        control2: CGPoint(x: size.width * 0.65, y: size.height * 0.95)
                    )
                    path.move(to: CGPoint(x: size.width * 0.15, y: size.height * 0.5))
                    path.addCurve(
                        to: CGPoint(x: size.width * 0.85, y: size.height * 0.5),
                        control1: CGPoint(x: size.width * 0.35, y: size.height * 0.95),
                        control2: CGPoint(x: size.width * 0.65, y: size.height * 0.05)
                    )
                }
                .stroke(accent.opacity(0.25), style: StrokeStyle(lineWidth: 1, dash: [5, 6]))

                ArchitectureNode(icon: "person.fill", label: "USER", accent: accent)
                    .position(x: size.width * 0.13, y: size.height * 0.5)
                ArchitectureNode(icon: "brain.head.profile", label: "AGENT", accent: AEColor.violet)
                    .position(x: size.width * 0.5, y: size.height * 0.5)
                ArchitectureNode(icon: "cylinder.split.1x2.fill", label: "KNOWLEDGE", accent: AEColor.azure)
                    .position(x: size.width * 0.87, y: size.height * 0.28)
                ArchitectureNode(icon: "wrench.and.screwdriver.fill", label: "TOOLS", accent: AEColor.signal)
                    .position(x: size.width * 0.87, y: size.height * 0.72)
            }
        }
        .accessibilityHidden(true)
    }
}

private struct ArchitectureNode: View {
    @Environment(\.colorScheme) private var colorScheme
    let icon: String
    let label: String
    let accent: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(accent)
                .frame(width: 48, height: 48)
                .background(accent.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(accent.opacity(0.32)))
                .aeGlow(color: accent, radius: 14, intensity: 0.55)
            Text(label)
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .tracking(0.7)
                .foregroundStyle(AEColor.textTertiary(colorScheme))
        }
    }
}

private struct ProjectCard: View {
    @EnvironmentObject private var state: AppState
    @Environment(\.colorScheme) private var colorScheme
    let project: LabProject

    private var completed: Int {
        project.milestones.filter { state.progress.isMilestoneCompleted($0, in: project) }.count
    }

    var body: some View {
        let accent = Color(hex: project.accent)
        let textAccent = AEColor.readableAccent(project.accent, colorScheme)
        VStack(alignment: .leading, spacing: AESpacing.md) {
            HStack {
                Image(systemName: project.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(textAccent)
                    .frame(width: 48, height: 48)
                    .background(accent.opacity(0.11), in: RoundedRectangle(cornerRadius: 14))
                Spacer()
                Text(project.difficulty.uppercased())
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .tracking(0.8)
                    .foregroundStyle(textAccent)
            }

            Text(project.subtitle.uppercased())
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .tracking(0.8)
                .foregroundStyle(AEColor.textTertiary(colorScheme))
            Text(project.title)
                .font(.aeTitle)
                .foregroundStyle(AEColor.textPrimary(colorScheme))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Text(project.summary)
                .font(.aeCallout)
                .foregroundStyle(AEColor.textSecondary(colorScheme))
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            AEFlowLayout(spacing: 6) {
                ForEach(project.skills.prefix(4), id: \.self) { skill in
                    Text(skill)
                        .font(.aeCaption)
                        .foregroundStyle(AEColor.textSecondary(colorScheme))
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(AEColor.subtleFill(colorScheme), in: Capsule())
                }
            }

            Spacer(minLength: 0)
            HStack {
                Label("\(project.estimatedHours)h", systemImage: "clock.fill")
                Spacer()
                Text("\(completed)/\(project.milestones.count) milestones")
                Spacer()
                Image(systemName: "arrow.up.right").foregroundStyle(textAccent)
            }
            .font(.aeCaption)
            .foregroundStyle(AEColor.textTertiary(colorScheme))
            ProgressView(value: Double(completed), total: Double(project.milestones.count)).tint(accent)
        }
        .padding(AESpacing.lg)
        .frame(maxWidth: .infinity, minHeight: 350, alignment: .topLeading)
        .aeGlassSurface(tint: accent)
    }
}
