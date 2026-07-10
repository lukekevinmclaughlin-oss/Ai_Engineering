import SwiftUI

enum AppSection: String, CaseIterable, Identifiable {
    case home
    case learn
    case tutor
    case projects
    case progress

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: "Home"
        case .learn: "Learn"
        case .tutor: "Tutor"
        case .projects: "Projects"
        case .progress: "Progress"
        }
    }

    var systemImage: String {
        switch self {
        case .home: "square.grid.2x2.fill"
        case .learn: "graduationcap.fill"
        case .tutor: "bubble.left.and.bubble.right.fill"
        case .projects: "hammer.fill"
        case .progress: "chart.bar.xaxis"
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var state: AppState
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selection: AppSection = Self.initialSection

    private static var initialSection: AppSection {
        #if DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        if let marker = arguments.firstIndex(of: "--app-store-section"),
           arguments.indices.contains(marker + 1),
           let section = AppSection(rawValue: arguments[marker + 1]) {
            return section
        }
        #endif
        return .home
    }

    var body: some View {
        Group {
            if state.subscription.isCheckingAccess {
                SubscriptionLaunchView()
            } else if state.subscription.hasAccess {
                #if os(macOS)
                desktopLayout
                #else
                mobileLayout
                #endif
            } else {
                SubscriptionPaywallView(store: state.subscription)
            }
        }
        .tint(AEColor.readableSignal(colorScheme))
        .animation(reduceMotion ? nil : AEMotion.gentle, value: state.appearance)
    }

    #if os(macOS)
    private var desktopLayout: some View {
        NavigationSplitView {
            ZStack {
                AEFrontierBackground(accent: AEColor.violet, intensity: 0.30)
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: AESpacing.lg) {
                    brand
                        .padding(.horizontal, AESpacing.md)
                        .padding(.top, AESpacing.sm)

                    List(AppSection.allCases, selection: $selection) { section in
                        Label(section.title, systemImage: section.systemImage)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .padding(.vertical, 7)
                            .tag(section)
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.sidebar)

                    learnerSummary
                        .padding(AESpacing.md)
                }
            }
            .navigationSplitViewColumnWidth(min: 210, ideal: 238, max: 270)
        } detail: {
            sectionView(selection)
        }
        .navigationSplitViewStyle(.balanced)
        .frame(minWidth: 980, minHeight: 680)
    }

    private var brand: some View {
        HStack(spacing: AESpacing.xs) {
            AELogoMark(size: 34)
            VStack(alignment: .leading, spacing: 1) {
                Text("AI_ENGINEERING")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(AEColor.textPrimary(colorScheme))
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                Text("LEARN · BUILD · SHIP")
                    .font(.system(size: 7, weight: .semibold, design: .monospaced))
                    .tracking(0.7)
                    .foregroundStyle(AEColor.textTertiary(colorScheme))
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .layoutPriority(1)
            Spacer(minLength: AESpacing.xs)
            AppearanceMenu(compact: true)
        }
    }

    private var learnerSummary: some View {
        VStack(alignment: .leading, spacing: AESpacing.sm) {
            HStack {
                ZStack {
                    Circle().fill(AEGradient.signal)
                    Text("AI")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundStyle(Color.black.opacity(0.75))
                }
                .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: 1) {
                    Text("AI Engineer path")
                        .font(.aeLabel)
                        .foregroundStyle(AEColor.textPrimary(colorScheme))
                    Text("Level \(state.progress.totalXP / 500 + 1)")
                        .font(.aeCaption)
                        .foregroundStyle(AEColor.textSecondary(colorScheme))
                }
                Spacer()
                Image(systemName: "flame.fill")
                    .foregroundStyle(AEColor.amber)
                Text("\(state.progress.streak)")
                    .font(.aeLabel)
            }

            AIConstructionMiniatureView(snapshot: assemblySnapshot)

            ProgressView(value: state.progress.dailyProgress)
                .tint(AEColor.signal)
            Text("\(state.progress.todayXP) / \(state.progress.dailyGoal) XP today")
                .font(.aeCaption)
                .foregroundStyle(AEColor.textTertiary(colorScheme))
        }
        .padding(AESpacing.md)
        .aeGlassSurface(cornerRadius: AERadius.medium, tint: AEColor.signal)
    }

    private var assemblySnapshot: AIAssemblyProgress {
        AIAssemblyProgress(
            courses: state.curriculum.courses,
            projects: state.projects,
            completedLessonIDs: state.progress.value.completedLessonIDs,
            completedMilestoneIDs: state.progress.value.completedMilestoneIDs
        )
    }
    #endif

    #if !os(macOS)
    private var mobileLayout: some View {
        TabView(selection: $selection) {
            ForEach(AppSection.allCases) { section in
                NavigationStack {
                    sectionContent(section)
                        .toolbar {
                            ToolbarItem(placement: .primaryAction) {
                                AppearanceMenu(compact: true)
                            }
                        }
                }
                    .tabItem { Label(section.title, systemImage: section.systemImage) }
                    .tag(section)
            }
        }
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
    #endif

    @ViewBuilder
    private func sectionView(_ section: AppSection) -> some View {
        NavigationStack {
            sectionContent(section)
        }
    }

    @ViewBuilder
    private func sectionContent(_ section: AppSection) -> some View {
        switch section {
        case .home:
            DashboardView(selection: $selection)
        case .learn:
            CourseCatalogView()
        case .tutor:
            TutorView()
        case .projects:
            ProjectCatalogView()
        case .progress:
            ProgressProfileView()
        }
    }
}

struct AppearanceMenu: View {
    @EnvironmentObject private var state: AppState
    @Environment(\.colorScheme) private var colorScheme

    var compact = false

    var body: some View {
        Menu {
            ForEach(AppAppearance.allCases) { appearance in
                Button {
                    state.appearance = appearance
                } label: {
                    Label(
                        appearance.title,
                        systemImage: state.appearance == appearance
                            ? "checkmark.circle.fill"
                            : appearance.systemImage
                    )
                }
            }
        } label: {
            Group {
                if compact {
                    Image(systemName: state.appearance.systemImage)
                } else {
                    Label("Appearance", systemImage: state.appearance.systemImage)
                }
            }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(AEColor.textPrimary(colorScheme))
                .frame(minWidth: 32, minHeight: 32)
                .background(AEColor.surfaceElevated(colorScheme).opacity(0.92), in: Circle())
                .overlay(Circle().stroke(AEColor.strokeStrong(colorScheme)))
        }
        .menuIndicator(.hidden)
        #if os(macOS)
        .menuStyle(.borderlessButton)
        #endif
        .help("Appearance: \(state.appearance.title)")
        .accessibilityLabel("Appearance")
        .accessibilityValue(state.appearance.title)
    }
}

struct AELogoMark: View {
    @Environment(\.colorScheme) private var colorScheme
    let size: CGFloat

    var body: some View {
        Image("BrandLogo")
            .resizable()
            .interpolation(.high)
            .scaledToFill()
            .clipShape(RoundedRectangle(cornerRadius: size * 0.24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
                    .stroke(AEColor.strokeStrong(colorScheme), lineWidth: max(size * 0.025, 1))
            }
            .frame(width: size, height: size)
            .aeGlow(color: AEColor.violet, radius: size * 0.4, intensity: 0.8)
            .accessibilityLabel("AI Engineering")
    }
}
