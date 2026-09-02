import EngineeringShared
import SwiftUI

struct CourseDetailView: View {
    @EnvironmentObject private var state: AppState
    @Environment(\.colorScheme) private var colorScheme
    @State private var showPaywall = false
    let course: Course
    private var accent: Color { Color(hex: course.accent) }
    private var textAccent: Color { AEColor.readableAccent(course.accent, colorScheme) }

    var body: some View {
        ZStack {
            AEFrontierBackground(accent: Color(hex: course.accent), intensity: 0.72)

            ScrollView {
                VStack(alignment: .leading, spacing: AESpacing.xl) {
                    courseHero
                    curriculum
                }
                .padding(.horizontal, 28)
                .padding(.vertical, AESpacing.lg)
                .frame(maxWidth: 1_050)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle(course.title)
        .sheet(isPresented: $showPaywall) {
            SubscriptionPaywallView(store: state.subscription)
                #if os(macOS)
                .frame(minWidth: 900, minHeight: 620)
                #endif
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    state.progress.toggleBookmark(course)
                } label: {
                    Image(systemName: state.progress.isBookmarked(course) ? "bookmark.fill" : "bookmark")
                }
                .help(state.progress.isBookmarked(course) ? "Remove bookmark" : "Bookmark course")
            }
        }
    }

    private var courseHero: some View {
        VStack(alignment: .leading, spacing: AESpacing.lg) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: AESpacing.lg) {
                    courseIdentity
                    Spacer(minLength: AESpacing.md)
                    courseIcon
                }
                VStack(alignment: .leading, spacing: AESpacing.lg) {
                    courseIcon
                    courseIdentity
                }
            }

            AEFlowLayout(spacing: AESpacing.xs) {
                ForEach(course.skills, id: \.self) { skill in
                    Label(skill, systemImage: "checkmark.circle.fill")
                        .font(.aeCaption)
                        .foregroundStyle(AEColor.textSecondary(colorScheme))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AEColor.subtleFill(colorScheme), in: Capsule())
                }
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), alignment: .leading)], alignment: .leading, spacing: AESpacing.md) {
                CourseHeroStat(value: "\(course.lessonCount)", label: "lessons")
                CourseHeroStat(value: "\(course.modules.count)", label: "modules")
                CourseHeroStat(value: "\(course.estimatedMinutes / 60)h", label: "estimated")
                CourseHeroStat(value: "\(course.lessons.reduce(0) { $0 + $1.xp })", label: "available XP")
            }

            ViewThatFits(in: .horizontal) {
                HStack(spacing: AESpacing.md) {
                    courseStartButton
                    courseProgress
                }
                VStack(alignment: .leading, spacing: AESpacing.md) {
                    courseStartButton
                    courseProgress.frame(maxWidth: .infinity)
                }
            }
        }
        .padding(AESpacing.xl)
        .aeGlassSurface(cornerRadius: 28, tint: accent)
    }

    private var courseIdentity: some View {
        VStack(alignment: .leading, spacing: AESpacing.md) {
            HStack(spacing: AESpacing.xs) {
                Text(course.eyebrow.uppercased())
                Text("·")
                Text(course.difficulty.uppercased())
            }
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .tracking(1.1)
            .foregroundStyle(textAccent)

            Text(course.title)
                .aeTextRole(.hero)
                .foregroundStyle(AEColor.textPrimary(colorScheme))

            Text(course.summary)
                .aeTextRole(.body)
                .foregroundStyle(AEColor.textSecondary(colorScheme))
                .frame(maxWidth: 670, alignment: .leading)
        }
    }

    private var courseIcon: some View {
        Image(systemName: course.icon)
            .font(.system(size: 34, weight: .medium))
            .foregroundStyle(accent)
            .frame(width: 82, height: 82)
            .background(accent.opacity(0.11), in: RoundedRectangle(cornerRadius: 24))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(accent.opacity(0.3)))
            .aeGlow(color: accent, radius: 24, intensity: 0.7)
    }

    @ViewBuilder
    private var courseStartButton: some View {
        if let next = nextLessonLocation {
            if next.module > 0 && !state.subscription.hasAccess {
                Button { showPaywall = true } label: {
                    Label("Unlock the full course", systemImage: "lock.fill")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.black.opacity(0.8))
                        .padding(.horizontal, AESpacing.lg)
                        .padding(.vertical, 13)
                        .background(AEGradient.signal, in: Capsule())
                }
                .buttonStyle(.plain)
            } else {
            NavigationLink {
                LessonPlayerView(course: course, moduleIndex: next.module, lessonIndex: next.lesson)
            } label: {
                Label(state.progress.courseProgress(course) > 0 ? "Continue course" : "Begin course", systemImage: "play.fill")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.black.opacity(0.8))
                    .padding(.horizontal, AESpacing.lg)
                    .padding(.vertical, 13)
                    .background(AEGradient.signal, in: Capsule())
            }
            .buttonStyle(.plain)
            }
        }
    }

    private var courseProgress: some View {
        VStack(alignment: .leading, spacing: 5) {
            ProgressView(value: state.progress.courseProgress(course)).tint(accent)
            Text("\(Int(state.progress.courseProgress(course) * 100))% complete")
                .font(.aeCaption)
                .foregroundStyle(AEColor.textTertiary(colorScheme))
        }
        .frame(maxWidth: 220)
    }

    private var curriculum: some View {
        VStack(alignment: .leading, spacing: AESpacing.lg) {
            VStack(alignment: .leading, spacing: 4) {
                Text("CURRICULUM")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .tracking(1.1)
                    .foregroundStyle(textAccent)
                Text("Build the system, layer by layer")
                    .font(.aeTitle)
                    .foregroundStyle(AEColor.textPrimary(colorScheme))
            }

            ForEach(Array(course.modules.enumerated()), id: \.element.id) { moduleIndex, module in
                ModuleCard(course: course, module: module, moduleIndex: moduleIndex)
            }
        }
    }

    private var nextLessonLocation: (module: Int, lesson: Int)? {
        for (moduleIndex, module) in course.modules.enumerated() {
            if let lessonIndex = module.lessons.firstIndex(where: { !state.progress.isCompleted($0) }) {
                return (moduleIndex, lessonIndex)
            }
        }
        return course.modules.first?.lessons.isEmpty == false ? (0, 0) : nil
    }
}

private struct CourseHeroStat: View {
    @Environment(\.colorScheme) private var colorScheme
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value).font(.aeHeading).foregroundStyle(AEColor.textPrimary(colorScheme))
            Text(label).font(.aeCaption).foregroundStyle(AEColor.textTertiary(colorScheme))
        }
    }
}

private struct ModuleCard: View {
    @EnvironmentObject private var state: AppState
    @Environment(\.colorScheme) private var colorScheme
    @State private var showPaywall = false
    let course: Course
    let module: LearningModule
    let moduleIndex: Int

    var body: some View {
        let accent = Color(hex: course.accent)
        let textAccent = AEColor.readableAccent(course.accent, colorScheme)
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: AESpacing.md) {
                Text(String(format: "%02d", moduleIndex + 1))
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(textAccent)
                    .frame(width: 36, height: 36)
                    .background(accent.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 4) {
                    Text(module.title).font(.aeHeading).foregroundStyle(AEColor.textPrimary(colorScheme))
                    Text(module.summary).font(.aeCallout).foregroundStyle(AEColor.textSecondary(colorScheme))
                }
                Spacer()
                Text("\(state.progress.completedLessons(in: module))/\(module.lessons.count)")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(AEColor.textTertiary(colorScheme))
            }
            .padding(AESpacing.lg)

            Divider().overlay(AEColor.divider(colorScheme))

            VStack(spacing: 0) {
                ForEach(Array(module.lessons.enumerated()), id: \.element.id) { lessonIndex, lesson in
                    // Freemium: module 1 is free; later modules are Pro.
                    if moduleIndex > 0 && !state.subscription.hasAccess {
                        Button { showPaywall = true } label: {
                            LessonRow(lesson: lesson, index: lessonIndex + 1, isCompleted: state.progress.isCompleted(lesson), accent: accent)
                                .overlay(alignment: .trailing) {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(AEColor.textTertiary(colorScheme))
                                        .padding(.trailing, AESpacing.lg)
                                }
                        }
                        .buttonStyle(.plain)
                    } else {
                    NavigationLink {
                        LessonPlayerView(course: course, moduleIndex: moduleIndex, lessonIndex: lessonIndex)
                    } label: {
                        LessonRow(lesson: lesson, index: lessonIndex + 1, isCompleted: state.progress.isCompleted(lesson), accent: accent)
                    }
                    .buttonStyle(.plain)
                    }

                    if lesson.id != module.lessons.last?.id {
                        Divider().overlay(AEColor.divider(colorScheme).opacity(0.72)).padding(.leading, 72)
                    }
                }
            }
        }
        .aeGlassSurface(cornerRadius: AERadius.large, tint: accent)
        .sheet(isPresented: $showPaywall) {
            SubscriptionPaywallView(store: state.subscription)
                #if os(macOS)
                .frame(minWidth: 900, minHeight: 620)
                #endif
        }
    }
}

private struct LessonRow: View {
    @Environment(\.colorScheme) private var colorScheme
    let lesson: Lesson
    let index: Int
    let isCompleted: Bool
    let accent: Color

    var body: some View {
        HStack(spacing: AESpacing.md) {
            ZStack {
                Circle()
                    .fill(isCompleted ? accent : AEColor.subtleFill(colorScheme))
                Image(systemName: isCompleted ? "checkmark" : lesson.kind.systemImage)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(isCompleted ? Color.black.opacity(0.75) : accent)
            }
            .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 3) {
                Text(lesson.title)
                    .font(.aeCallout)
                    .foregroundStyle(AEColor.textPrimary(colorScheme))
                HStack(spacing: 6) {
                    Text(lesson.kind.title)
                    Text("·")
                    Text("\(lesson.estimatedMinutes) min")
                    Text("·")
                    Text("+\(lesson.xp) XP")
                }
                .font(.aeCaption)
                .foregroundStyle(AEColor.textTertiary(colorScheme))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(AEColor.textTertiary(colorScheme))
        }
        .padding(.horizontal, AESpacing.lg)
        .padding(.vertical, AESpacing.md)
        .contentShape(Rectangle())
    }
}
