import EngineeringShared
import Combine
import Foundation
import SwiftUI

enum AppAppearance: String, CaseIterable, Identifiable, Sendable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var systemImage: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light: "sun.max.fill"
        case .dark: "moon.stars.fill"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

@MainActor
final class AppState: ObservableObject {
    static let appearanceDefaultsKey = "app.appearance"

    let curriculum: Curriculum
    let projects: [LabProject]
    let progress: ProgressStore
    let tutor: TutorCoordinator
    let subscription: SubscriptionStore
    @Published var appearance: AppAppearance {
        didSet {
            userDefaults.set(appearance.rawValue, forKey: Self.appearanceDefaultsKey)
        }
    }

    private let userDefaults: UserDefaults
    private var cancellables: Set<AnyCancellable> = []

    init(
        curriculum: Curriculum = CurriculumStore.load(),
        projects: [LabProject] = ProjectCatalog.all,
        progress: ProgressStore = ProgressStore(),
        userDefaults: UserDefaults = .standard
    ) {
        self.userDefaults = userDefaults
        self.appearance = AppAppearance(
            rawValue: userDefaults.string(forKey: Self.appearanceDefaultsKey) ?? ""
        ) ?? .system
        self.curriculum = curriculum
        self.projects = projects
        self.progress = progress
        self.progress.migrateLegacyMilestoneIDs(projects: projects)
        self.tutor = TutorCoordinator(curriculum: curriculum, projects: projects, defaults: userDefaults)
        self.subscription = SubscriptionStore()

        progress.objectWillChange
            .sink { [weak self] in self?.objectWillChange.send() }
            .store(in: &cancellables)

        tutor.objectWillChange
            .sink { [weak self] in self?.objectWillChange.send() }
            .store(in: &cancellables)

        subscription.objectWillChange
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
