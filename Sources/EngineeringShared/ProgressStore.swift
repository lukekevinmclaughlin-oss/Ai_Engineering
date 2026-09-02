import Combine
import Foundation

public struct LearnerProgress: Codable, Equatable {
    public var completedLessonIDs: Set<String> = []
    public var completedMilestoneIDs: Set<String> = []
    public var bookmarkedCourseIDs: Set<String> = []
    public var recentLessonIDs: [String] = []
    public var skillXP: [String: Int] = [:]
    public var dailyXP: [String: Int] = [:]
    public var totalXP = 0
    public var streak = 0
    public var lastActivityDay: String?
    public var dailyGoal = 100


    init(
        completedLessonIDs: Set<String> = [],
        completedMilestoneIDs: Set<String> = [],
        bookmarkedCourseIDs: Set<String> = [],
        recentLessonIDs: [String] = [],
        skillXP: [String: Int] = [:],
        dailyXP: [String: Int] = [:],
        totalXP: Int = 0,
        streak: Int = 0,
        lastActivityDay: String? = nil,
        dailyGoal: Int = 100
    ) {
        self.completedLessonIDs = completedLessonIDs
        self.completedMilestoneIDs = completedMilestoneIDs
        self.bookmarkedCourseIDs = bookmarkedCourseIDs
        self.recentLessonIDs = recentLessonIDs
        self.skillXP = skillXP
        self.dailyXP = dailyXP
        self.totalXP = totalXP
        self.streak = streak
        self.lastActivityDay = lastActivityDay
        self.dailyGoal = dailyGoal
    }
}

@MainActor
public final class ProgressStore: ObservableObject {
    @Published public private(set) var value: LearnerProgress

    private let defaults: UserDefaults
    private let storageKey: String
    private let calendar: Calendar

    public init(
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

    public var totalXP: Int { value.totalXP }
    public var streak: Int { value.streak }
    public var dailyGoal: Int { value.dailyGoal }
    public var completedLessonCount: Int { value.completedLessonIDs.count }
    public var todayXP: Int { value.dailyXP[dayKey(for: Date()), default: 0] }
    public var dailyProgress: Double { min(Double(todayXP) / Double(max(dailyGoal, 1)), 1) }

    public func isCompleted(_ lesson: Lesson) -> Bool {
        value.completedLessonIDs.contains(lesson.id)
    }

    public func isMilestoneCompleted(_ milestone: ProjectMilestone, in project: LabProject) -> Bool {
        value.completedMilestoneIDs.contains(milestone.progressID(projectID: project.id))
    }

    public func isBookmarked(_ course: Course) -> Bool {
        value.bookmarkedCourseIDs.contains(course.id)
    }

    public func courseProgress(_ course: Course) -> Double {
        guard !course.lessons.isEmpty else { return 0 }
        let completed = course.lessons.filter { value.completedLessonIDs.contains($0.id) }.count
        return Double(completed) / Double(course.lessons.count)
    }

    public func completedLessons(in module: LearningModule) -> Int {
        module.lessons.filter { value.completedLessonIDs.contains($0.id) }.count
    }

    public func nextLesson(in course: Course) -> Lesson? {
        course.lessons.first { !value.completedLessonIDs.contains($0.id) } ?? course.lessons.first
    }

    public func complete(_ lesson: Lesson, in course: Course) {
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

    public func toggleMilestone(_ milestone: ProjectMilestone, in project: LabProject) {
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
    public func migrateLegacyMilestoneIDs(projects: [LabProject]) {
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

    public func toggleBookmark(_ course: Course) {
        if value.bookmarkedCourseIDs.contains(course.id) {
            value.bookmarkedCourseIDs.remove(course.id)
        } else {
            value.bookmarkedCourseIDs.insert(course.id)
        }
        persist()
    }

    public func setDailyGoal(_ goal: Int) {
        value.dailyGoal = max(20, min(goal, 500))
        persist()
    }

    public func activityForLastSevenDays(now: Date = Date()) -> [Int] {
        (0..<7).reversed().map { offset in
            let date = calendar.date(byAdding: .day, value: -offset, to: now) ?? now
            return value.dailyXP[dayKey(for: date), default: 0]
        }
    }

    public func reset() {
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
