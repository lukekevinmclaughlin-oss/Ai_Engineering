import XCTest
@testable import EngineeringShared

final class EngineeringSharedTests: XCTestCase {
    func testPublicLearningModelSurface() {
        let lesson = Lesson(
            id: "lesson",
            title: "Ship safely",
            kind: .concept,
            estimatedMinutes: 15,
            xp: 25,
            summary: "A focused lesson",
            contentBlocks: [],
            challenge: nil
        )
        let module = LearningModule(id: "module", title: "Operate", summary: "Production loop", lessons: [lesson])
        let course = Course(
            id: "course",
            title: "Reliable systems",
            eyebrow: "CORE",
            summary: "Build and operate",
            icon: "gearshape.2",
            accent: "#7C6BFF",
            difficulty: "Intermediate",
            estimatedMinutes: 15,
            isFeatured: true,
            skills: ["Reliability"],
            modules: [module]
        )

        XCTAssertEqual(course.lessonCount, 1)
        XCTAssertEqual(Curriculum(courses: [course]).courses.first?.id, "course")
    }

    func testEndpointPolicyRejectsInsecureRemoteHTTP() throws {
        XCTAssertThrowsError(try TutorEndpointPolicy.validatedURL("http://example.com/v1/models"))
        XCTAssertNoThrow(try TutorEndpointPolicy.validatedURL("http://127.0.0.1:11434/api/tags"))
        XCTAssertNoThrow(try TutorEndpointPolicy.validatedURL("https://example.com/v1/models"))
    }

    func testWorkflowStagesRetainProductMeaning() {
        let stage = EngineeringWorkflowStage(
            id: "evaluate",
            title: "Evaluate",
            detail: "Measure quality before release.",
            systemImage: "checkmark.seal"
        )
        XCTAssertEqual(stage.id, "evaluate")
        XCTAssertEqual(stage.title, "Evaluate")
    }
}
