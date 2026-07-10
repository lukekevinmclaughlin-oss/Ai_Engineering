import SwiftUI

struct CourseCatalogView: View {
    @EnvironmentObject private var state: AppState
    @State private var searchText = ""
    @State private var selectedDifficulty = "All"

    private var difficulties: [String] {
        ["All"] + Array(Set(state.curriculum.courses.map(\.difficulty))).sorted()
    }

    private var filteredCourses: [Course] {
        state.curriculum.courses.filter { course in
            let matchesDifficulty = selectedDifficulty == "All" || course.difficulty == selectedDifficulty
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            let matchesSearch = query.isEmpty || [course.title, course.summary, course.skills.joined(separator: " ")]
                .joined(separator: " ")
                .localizedCaseInsensitiveContains(query)
            return matchesDifficulty && matchesSearch
        }
    }

    var body: some View {
        ZStack {
            AEFrontierBackground(accent: AEColor.azure, intensity: 0.62)

            ScrollView {
                VStack(alignment: .leading, spacing: AESpacing.xl) {
                    catalogHeader
                    difficultyPicker

                    if filteredCourses.isEmpty {
                        ContentUnavailableView(
                            "No courses found",
                            systemImage: "magnifyingglass",
                            description: Text("Try another skill or difficulty.")
                        )
                        .frame(maxWidth: .infinity, minHeight: 320)
                    } else {
                        LazyVGrid(
                            columns: [GridItem(.adaptive(minimum: 300, maximum: 430), spacing: AESpacing.lg)],
                            spacing: AESpacing.lg
                        ) {
                            ForEach(filteredCourses) { course in
                                NavigationLink(value: course) {
                                    CourseCatalogCard(course: course)
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
        .navigationDestination(for: Course.self) { course in
            CourseDetailView(course: course)
        }
        .searchable(text: $searchText, placement: .automatic, prompt: "Search courses and skills")
        .navigationTitle("Learn")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private var catalogHeader: some View {
        VStack(alignment: .leading, spacing: AESpacing.sm) {
            Text("COURSE MATRIX")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .tracking(1.4)
                .foregroundStyle(AEColor.azure)
            Text("Master the AI engineering stack")
                .aeTextRole(.display)
                .foregroundStyle(.white)
            Text("Short theory, executable practice, and production trade-offs—organized around the systems you’ll actually ship.")
                .aeTextRole(.body)
                .foregroundStyle(AEColor.textSecondary(.dark))
                .frame(maxWidth: 720, alignment: .leading)

            HStack(spacing: AESpacing.lg) {
                CatalogStat(value: "\(state.curriculum.courses.count)", label: "courses")
                CatalogStat(value: "\(state.totalLessonCount)", label: "lessons")
                CatalogStat(value: "\(state.totalLearningMinutes / 60)h", label: "practice")
            }
            .padding(.top, AESpacing.xs)
        }
    }

    private var difficultyPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AESpacing.xs) {
                ForEach(difficulties, id: \.self) { difficulty in
                    Button {
                        withAnimation(AEMotion.quick) { selectedDifficulty = difficulty }
                    } label: {
                        Text(difficulty)
                            .font(.aeLabel)
                            .foregroundStyle(selectedDifficulty == difficulty ? Color.black.opacity(0.8) : AEColor.textSecondary(.dark))
                            .padding(.horizontal, AESpacing.md)
                            .padding(.vertical, 9)
                            .background(selectedDifficulty == difficulty ? AnyShapeStyle(AEGradient.signal) : AnyShapeStyle(Color.white.opacity(0.055)), in: Capsule())
                            .overlay(Capsule().stroke(Color.white.opacity(selectedDifficulty == difficulty ? 0 : 0.08)))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct CatalogStat: View {
    let value: String
    let label: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 5) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(label)
                .font(.aeCaption)
                .foregroundStyle(AEColor.textTertiary(.dark))
        }
    }
}

private struct CourseCatalogCard: View {
    @EnvironmentObject private var state: AppState
    let course: Course

    var body: some View {
        let accent = Color(hex: course.accent)
        VStack(alignment: .leading, spacing: AESpacing.md) {
            HStack(alignment: .top) {
                Image(systemName: course.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(accent)
                    .frame(width: 48, height: 48)
                    .background(accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(accent.opacity(0.22)))

                Spacer()

                HStack(spacing: 5) {
                    Circle().fill(accent).frame(width: 6, height: 6)
                    Text(course.difficulty.uppercased())
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .tracking(0.8)
                }
                .foregroundStyle(AEColor.textSecondary(.dark))
            }

            VStack(alignment: .leading, spacing: AESpacing.xs) {
                Text(course.eyebrow.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .tracking(1)
                    .foregroundStyle(accent)
                Text(course.title)
                    .font(.aeTitle)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                Text(course.summary)
                    .font(.aeCallout)
                    .foregroundStyle(AEColor.textSecondary(.dark))
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            AEFlowLayout(spacing: 6) {
                ForEach(course.skills.prefix(4), id: \.self) { skill in
                    Text(skill)
                        .font(.aeCaption)
                        .foregroundStyle(AEColor.textSecondary(.dark))
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.055), in: Capsule())
                }
            }

            Divider().overlay(Color.white.opacity(0.06))

            HStack {
                Label("\(course.lessonCount) lessons", systemImage: "rectangle.stack.fill")
                Spacer()
                Label("\(course.estimatedMinutes / 60)h \(course.estimatedMinutes % 60)m", systemImage: "clock.fill")
                Spacer()
                Image(systemName: "arrow.up.right")
                    .foregroundStyle(accent)
            }
            .font(.aeCaption)
            .foregroundStyle(AEColor.textTertiary(.dark))

            if state.progress.courseProgress(course) > 0 {
                ProgressView(value: state.progress.courseProgress(course))
                    .tint(accent)
            }
        }
        .padding(AESpacing.lg)
        .frame(maxWidth: .infinity, minHeight: 350, alignment: .topLeading)
        .aeGlassSurface(tint: accent)
    }
}
