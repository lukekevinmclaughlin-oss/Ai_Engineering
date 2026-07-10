import Combine
import Foundation

@MainActor
final class AppState: ObservableObject {
    let curriculum: Curriculum
    let projects: [LabProject]
    let progress: ProgressStore
    let tutor: TutorCoordinator
    private var cancellables: Set<AnyCancellable> = []

    init(
        curriculum: Curriculum = CurriculumStore.load(),
        projects: [LabProject] = ProjectCatalog.all,
        progress: ProgressStore = ProgressStore()
    ) {
        self.curriculum = curriculum
        self.projects = projects
        self.progress = progress
        self.tutor = TutorCoordinator(curriculum: curriculum, projects: projects)

        progress.objectWillChange
            .sink { [weak self] in self?.objectWillChange.send() }
            .store(in: &cancellables)

        tutor.objectWillChange
            .sink { [weak self] in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    var featuredCourse: Course? {
        curriculum.courses.first(where: \.isFeatured) ?? curriculum.courses.first
    }

    var totalLessonCount: Int {
        curriculum.courses.reduce(0) { $0 + $1.lessonCount }
    }

    var totalLearningMinutes: Int {
        curriculum.courses.reduce(0) { $0 + $1.estimatedMinutes }
    }

    var skillMetrics: [SkillMetric] {
        let defaults: [(String, String)] = [
            ("LLM systems", "8B7BFF"),
            ("RAG", "35D6B4"),
            ("Evaluations", "FFB45E"),
            ("Agents", "FF6E91"),
            ("Production", "64B5FF")
        ]

        return defaults.map { name, color in
            let earned = progress.value.skillXP.first { key, _ in
                key.localizedCaseInsensitiveContains(name) || name.localizedCaseInsensitiveContains(key)
            }?.value ?? 0
            let normalized = min(0.16 + Double(earned) / 1_200, 1)
            return SkillMetric(name: name, value: normalized, delta: earned > 0 ? min(earned / 10, 18) : 0, color: color)
        }
    }
}
