import EngineeringShared
import XCTest
@testable import Ai_Engineering

@MainActor
final class ProgressStoreTests: XCTestCase {
    func testCompletingLessonAwardsXPOnlyOnce() {
        withIsolatedDefaults { defaults in
            let store = ProgressStore(defaults: defaults)
            let lesson = makeLesson(id: "lesson-1", xp: 80)
            let course = makeCourse(lessons: [lesson])

            store.complete(lesson, in: course)
            store.complete(lesson, in: course)

            XCTAssertEqual(store.totalXP, 80)
            XCTAssertEqual(store.completedLessonCount, 1)
            XCTAssertEqual(store.courseProgress(course), 1)
            XCTAssertEqual(store.streak, 1)
        }
    }

    func testProgressPersistsAcrossInstances() {
        withIsolatedDefaults { defaults in
            let lesson = makeLesson(id: "persisted", xp: 50)
            let course = makeCourse(lessons: [lesson])
            let first = ProgressStore(defaults: defaults)
            first.complete(lesson, in: course)

            let restored = ProgressStore(defaults: defaults)
            XCTAssertTrue(restored.isCompleted(lesson))
            XCTAssertEqual(restored.totalXP, 50)
        }
    }

    func testDailyGoalIsClampedToSupportedRange() {
        withIsolatedDefaults { defaults in
            let store = ProgressStore(defaults: defaults)
            store.setDailyGoal(5)
            XCTAssertEqual(store.dailyGoal, 20)
            store.setDailyGoal(1_000)
            XCTAssertEqual(store.dailyGoal, 500)
        }
    }

    func testMilestoneProgressIsScopedToItsProject() {
        withIsolatedDefaults { defaults in
            let store = ProgressStore(defaults: defaults)
            let first = makeProject(id: "first", milestoneID: "schema")
            let second = makeProject(id: "second", milestoneID: "schema")

            store.toggleMilestone(first.milestones[0], in: first)

            XCTAssertTrue(store.isMilestoneCompleted(first.milestones[0], in: first))
            XCTAssertFalse(store.isMilestoneCompleted(second.milestones[0], in: second))
            XCTAssertEqual(store.value.completedMilestoneIDs, ["first::schema"])
        }
    }

    func testLegacyMilestoneProgressMigratesWithoutLosingDuplicateMatches() throws {
        try withIsolatedDefaults { defaults in
            let storageKey = "legacy-progress"
            var legacy = LearnerProgress()
            legacy.completedMilestoneIDs = ["schema"]
            defaults.set(try JSONEncoder().encode(legacy), forKey: storageKey)

            let first = makeProject(id: "first", milestoneID: "schema")
            let second = makeProject(id: "second", milestoneID: "schema")
            let store = ProgressStore(defaults: defaults, storageKey: storageKey)
            store.migrateLegacyMilestoneIDs(projects: [first, second])

            XCTAssertEqual(store.value.completedMilestoneIDs, ["first::schema", "second::schema"])
            XCTAssertFalse(store.value.completedMilestoneIDs.contains("schema"))
        }
    }

    private func withIsolatedDefaults(_ body: (UserDefaults) throws -> Void) rethrows {
        let suiteName = "AiEngineeringTests.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Could not create isolated UserDefaults")
            return
        }
        defaults.removePersistentDomain(forName: suiteName)
        defer { defaults.removePersistentDomain(forName: suiteName) }
        try body(defaults)
    }

    private func makeLesson(id: String, xp: Int) -> Lesson {
        Lesson(
            id: id,
            title: "Test lesson",
            kind: .concept,
            estimatedMinutes: 5,
            xp: xp,
            summary: "A test lesson",
            contentBlocks: [.init(type: .paragraph, text: "Test", language: nil, items: nil)],
            challenge: nil
        )
    }

    private func makeCourse(lessons: [Lesson]) -> Course {
        Course(
            id: "course",
            title: "Course",
            eyebrow: "Test",
            summary: "Test course",
            icon: "sparkles",
            accent: "61FAC4",
            difficulty: "Foundation",
            estimatedMinutes: 20,
            isFeatured: true,
            skills: ["Systems"],
            modules: [.init(id: "module", title: "Module", summary: "Test", lessons: lessons)]
        )
    }


    private func makeProject(id: String, milestoneID: String) -> LabProject {
        LabProject(
            id: id,
            title: "Project \(id)",
            subtitle: "Test project",
            summary: "A project used to verify progress identity.",
            icon: "hammer.fill",
            accent: "61FAC4",
            difficulty: "Beginner",
            estimatedHours: 1,
            xp: 100,
            skills: ["Testing"],
            outcomes: ["Verify progress"],
            milestones: [
                ProjectMilestone(
                    id: milestoneID,
                    title: "Schema",
                    detail: "Define the schema.",
                    systemImage: "tablecells"
                )
            ],
            brief: "Test brief",
            starterFiles: []
        )
    }
}
