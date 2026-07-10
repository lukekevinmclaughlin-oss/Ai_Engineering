import Combine
import Foundation

struct LearnerProgress: Codable, Equatable {
    var completedLessonIDs: Set<String> = []
    var completedMilestoneIDs: Set<String> = []
    var bookmarkedCourseIDs: Set<String> = []
    var recentLessonIDs: [String] = []
    var skillXP: [String: Int] = [:]
    var dailyXP: [String: Int] = [:]
    var totalXP = 0
    var streak = 0
    var lastActivityDay: String?
    var dailyGoal = 100
}

@MainActor
final class ProgressStore: ObservableObject {
    @Published private(set) var value: LearnerProgress

    private let defaults: UserDefaults
    private let storageKey: String
    private let calendar: Calendar

    init(
        defaults: UserDefaults = .standard,
        storageKey: String = "ai-engineering.learner-progress.v1",
        calendar: Calendar = .autoupdatingCurrent
    ) {
        self.defaults = defaults
        self.storageKey = storageKey
        self.calendar = calendar

        if let data = defaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(LearnerProgress.self, from: data) {
            value = decoded
        } else {
            value = LearnerProgress()
        }
    }

    var totalXP: Int { value.totalXP }
    var streak: Int { value.streak }
    var dailyGoal: Int { value.dailyGoal }
    var completedLessonCount: Int { value.completedLessonIDs.count }
    var todayXP: Int { value.dailyXP[dayKey(for: Date()), default: 0] }
    var dailyProgress: Double { min(Double(todayXP) / Double(max(dailyGoal, 1)), 1) }

    func isCompleted(_ lesson: Lesson) -> Bool {
        value.completedLessonIDs.contains(lesson.id)
    }

    func isMilestoneCompleted(_ milestone: ProjectMilestone, in project: LabProject) -> Bool {
        value.completedMilestoneIDs.contains(milestone.progressID(projectID: project.id))
    }

    func isBookmarked(_ course: Course) -> Bool {
        value.bookmarkedCourseIDs.contains(course.id)
    }

    func courseProgress(_ course: Course) -> Double {
        guard !course.lessons.isEmpty else { return 0 }
        let completed = course.lessons.filter { value.completedLessonIDs.contains($0.id) }.count
        return Double(completed) / Double(course.lessons.count)
    }

    func completedLessons(in module: LearningModule) -> Int {
        module.lessons.filter { value.completedLessonIDs.contains($0.id) }.count
    }

    func nextLesson(in course: Course) -> Lesson? {
        course.lessons.first { !value.completedLessonIDs.contains($0.id) } ?? course.lessons.first
    }

    func complete(_ lesson: Lesson, in course: Course) {
        guard !value.completedLessonIDs.contains(lesson.id) else {
            touchRecent(lesson.id)
            return
        }

        value.completedLessonIDs.insert(lesson.id)
        value.totalXP += lesson.xp
        value.dailyXP[dayKey(for: Date()), default: 0] += lesson.xp
        let xpPerSkill = max(lesson.xp / max(course.skills.count, 1), 1)
        for skill in course.skills {
            value.skillXP[skill, default: 0] += xpPerSkill
        }
        updateStreak()
        touchRecent(lesson.id)
        persist()
    }

    func toggleMilestone(_ milestone: ProjectMilestone, in project: LabProject) {
        let progressID = milestone.progressID(projectID: project.id)
        if value.completedMilestoneIDs.contains(progressID) {
            value.completedMilestoneIDs.remove(progressID)
        } else {
            value.completedMilestoneIDs.insert(progressID)
        }
        persist()
    }

    /// Upgrades progress written by early builds, where milestone IDs were not
    /// scoped to their project. A legacy ID is expanded to every catalog match,
    /// preserving what the learner previously saw as completed.
    func migrateLegacyMilestoneIDs(projects: [LabProject]) {
        let legacyIDs = value.completedMilestoneIDs.filter { !$0.contains("::") }
        guard !legacyIDs.isEmpty else { return }

        var migrated = value.completedMilestoneIDs
        var didChange = false

        for legacyID in legacyIDs {
            let matches = projects.flatMap { project in
                project.milestones
                    .filter { $0.id == legacyID }
                    .map { $0.progressID(projectID: project.id) }
            }
            guard !matches.isEmpty else { continue }

            migrated.remove(legacyID)
            migrated.formUnion(matches)
            didChange = true
        }

        guard didChange else { return }
        value.completedMilestoneIDs = migrated
        persist()
    }

    func toggleBookmark(_ course: Course) {
        if value.bookmarkedCourseIDs.contains(course.id) {
            value.bookmarkedCourseIDs.remove(course.id)
        } else {
            value.bookmarkedCourseIDs.insert(course.id)
        }
        persist()
    }

    func setDailyGoal(_ goal: Int) {
        value.dailyGoal = max(20, min(goal, 500))
        persist()
    }

    func activityForLastSevenDays(now: Date = Date()) -> [Int] {
        (0..<7).reversed().map { offset in
            let date = calendar.date(byAdding: .day, value: -offset, to: now) ?? now
            return value.dailyXP[dayKey(for: date), default: 0]
        }
    }

    func reset() {
        value = LearnerProgress()
        persist()
    }

    private func touchRecent(_ lessonID: String) {
        value.recentLessonIDs.removeAll { $0 == lessonID }
        value.recentLessonIDs.insert(lessonID, at: 0)
        value.recentLessonIDs = Array(value.recentLessonIDs.prefix(12))
        persist()
    }

    private func updateStreak(now: Date = Date()) {
        let today = dayKey(for: now)
        guard value.lastActivityDay != today else { return }

        let yesterday = calendar.date(byAdding: .day, value: -1, to: now).map(dayKey(for:))
        value.streak = value.lastActivityDay == yesterday ? max(value.streak + 1, 1) : 1
        value.lastActivityDay = today
    }

    private func dayKey(for date: Date) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0)
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(data, forKey: storageKey)
    }
}
