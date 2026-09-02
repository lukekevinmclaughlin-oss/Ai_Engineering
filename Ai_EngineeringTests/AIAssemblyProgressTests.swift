import EngineeringShared
import XCTest
@testable import Ai_Engineering

final class AIAssemblyProgressTests: XCTestCase {
    func testCatalogSnapshotCountsOnlyVerifiedLearningComponents() throws {
        let curriculum = try loadCurriculum()
        let projects = ProjectCatalog.all
        let firstCourse = try XCTUnwrap(curriculum.courses.first)
        let firstProject = try XCTUnwrap(projects.first)
        let firstMilestone = try XCTUnwrap(firstProject.milestones.first)
        let firstMilestoneKey = AIAssemblyProgress.milestoneKey(
            projectID: firstProject.id,
            milestoneID: firstMilestone.id
        )

        let snapshot = AIAssemblyProgress(
            courses: curriculum.courses,
            projects: projects,
            completedLessonIDs: Set(firstCourse.lessons.map(\.id) + ["stale-lesson"]),
            completedMilestoneIDs: [firstMilestoneKey, "stale-project::stale-milestone"]
        )

        XCTAssertEqual(snapshot.completedLessons, firstCourse.lessonCount)
        XCTAssertEqual(snapshot.completedCourses, 1)
        XCTAssertEqual(snapshot.completedMilestones, 1)
        XCTAssertEqual(snapshot.totalLessons, 400)
        XCTAssertEqual(snapshot.totalCourses, 40)
        XCTAssertEqual(snapshot.totalMilestones, 160)
    }

    func testEveryCompletedUnitAdvancesAssemblyProgress() {
        let before = AIAssemblyProgress(
            completedLessons: 4,
            totalLessons: 10,
            completedCourses: 0,
            totalCourses: 2,
            completedMilestones: 1,
            totalMilestones: 4
        )
        let after = AIAssemblyProgress(
            completedLessons: 5,
            totalLessons: 10,
            completedCourses: 0,
            totalCourses: 2,
            completedMilestones: 1,
            totalMilestones: 4
        )

        XCTAssertGreaterThan(after.fractionComplete, before.fractionComplete)
        XCTAssertEqual(after.completedUnits, before.completedUnits + 1)
        XCTAssertEqual(after.remainingUnits, before.remainingUnits - 1)
    }

    func testAssemblyStagesFollowNamedThresholds() {
        func snapshot(_ completed: Int) -> AIAssemblyProgress {
            AIAssemblyProgress(
                completedLessons: completed,
                totalLessons: 100,
                completedCourses: 0,
                totalCourses: 0,
                completedMilestones: 0,
                totalMilestones: 0
            )
        }

        XCTAssertEqual(snapshot(0).stage, .blueprint)
        XCTAssertEqual(snapshot(8).stage, .neuralCore)
        XCTAssertEqual(snapshot(25).stage, .cognitiveLattice)
        XCTAssertEqual(snapshot(50).stage, .systemsIntegration)
        XCTAssertEqual(snapshot(75).stage, .autonomousReasoning)
        XCTAssertEqual(snapshot(100).stage, .commissioned)
    }

    private func loadCurriculum() throws -> Curriculum {
        let fileURL = try XCTUnwrap(Bundle.main.url(forResource: "curriculum", withExtension: "json"))
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(Curriculum.self, from: data)
    }
}
