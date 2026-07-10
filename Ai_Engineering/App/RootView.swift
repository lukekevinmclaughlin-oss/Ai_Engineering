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
    @State private var selection: AppSection = .home

    var body: some View {
        #if os(macOS)
        desktopLayout
        #else
        mobileLayout
        #endif
    }

    #if os(macOS)
    private var desktopLayout: some View {
        NavigationSplitView {
            ZStack {
                AEColor.canvas(.dark)
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
        HStack(spacing: AESpacing.sm) {
            AELogoMark(size: 36)
            VStack(alignment: .leading, spacing: 1) {
                Text("AI_ENGINEERING")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                Text("LEARN · BUILD · SHIP")
                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    .tracking(1.1)
                    .foregroundStyle(AEColor.textTertiary(.dark))
            }
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
                        .foregroundStyle(AEColor.textPrimary(.dark))
                    Text("Level \(state.progress.totalXP / 500 + 1)")
                        .font(.aeCaption)
                        .foregroundStyle(AEColor.textSecondary(.dark))
                }
                Spacer()
                Image(systemName: "flame.fill")
                    .foregroundStyle(AEColor.amber)
                Text("\(state.progress.streak)")
                    .font(.aeLabel)
            }

            ProgressView(value: state.progress.dailyProgress)
                .tint(AEColor.signal)
            Text("\(state.progress.todayXP) / \(state.progress.dailyGoal) XP today")
                .font(.aeCaption)
                .foregroundStyle(AEColor.textTertiary(.dark))
        }
        .padding(AESpacing.md)
        .aeGlassSurface(cornerRadius: AERadius.medium, tint: AEColor.signal)
    }
    #endif

    #if !os(macOS)
    private var mobileLayout: some View {
        TabView(selection: $selection) {
            ForEach(AppSection.allCases) { section in
                sectionView(section)
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
        switch section {
        case .home:
            NavigationStack { DashboardView(selection: $selection) }
        case .learn:
            NavigationStack { CourseCatalogView() }
        case .tutor:
            NavigationStack { TutorView() }
        case .projects:
            NavigationStack { ProjectCatalogView() }
        case .progress:
            NavigationStack { ProgressProfileView() }
        }
    }
}

struct AELogoMark: View {
    let size: CGFloat

    var body: some View {
        Image("BrandLogo")
            .resizable()
            .interpolation(.high)
            .scaledToFill()
            .clipShape(RoundedRectangle(cornerRadius: size * 0.24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
                    .stroke(Color.white.opacity(0.14), lineWidth: max(size * 0.025, 1))
            }
            .frame(width: size, height: size)
            .aeGlow(color: AEColor.violet, radius: size * 0.4, intensity: 0.8)
            .accessibilityLabel("AI Engineering")
    }
}
