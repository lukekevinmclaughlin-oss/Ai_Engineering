import XCTest
@testable import Ai_Engineering

final class CurriculumTests: XCTestCase {
    func testCurriculumDecodesAndHasUniqueIdentifiers() throws {
        let curriculum = try loadCurriculum()
        XCTAssertEqual(curriculum.courses.count, 40)

        let modules = curriculum.courses.flatMap(\.modules)
        let lessons = curriculum.courses.flatMap(\.lessons)
        XCTAssertEqual(modules.count, 80)
        XCTAssertEqual(lessons.count, 400)
        XCTAssertTrue(curriculum.courses.allSatisfy { $0.modules.count == 2 })
        XCTAssertTrue(modules.allSatisfy { $0.lessons.count == 5 })
        XCTAssertEqual(Set(curriculum.courses.map(\.id)).count, curriculum.courses.count)
        XCTAssertEqual(Set(modules.map(\.id)).count, modules.count)
        XCTAssertEqual(Set(lessons.map(\.id)).count, lessons.count)
        XCTAssertEqual(Set(curriculum.courses.map(\.title)).count, curriculum.courses.count)
        XCTAssertEqual(Set(modules.map(\.title)).count, modules.count)
        XCTAssertEqual(Set(lessons.map(\.title)).count, lessons.count)
        XCTAssertEqual(curriculum.courses.filter(\.isFeatured).count, 1)
    }

    func testEveryLessonHasPracticeAndValidXP() throws {
        let lessons = try loadCurriculum().courses.flatMap(\.lessons)

        for lesson in lessons {
            XCTAssertFalse(lesson.title.isEmpty, "Missing title for \(lesson.id)")
            XCTAssertGreaterThanOrEqual(lesson.contentBlocks.count, 3, "Thin content for \(lesson.id)")
            XCTAssertGreaterThan(
                ([lesson.summary] + lesson.contentBlocks.map(\.text)).joined().count,
                180,
                "Lesson is not substantive: \(lesson.id)"
            )
            XCTAssertNotNil(lesson.challenge, "Missing challenge for \(lesson.id)")
            XCTAssertGreaterThanOrEqual(lesson.challenge?.hints.count ?? 0, 2, "Missing hint ladder for \(lesson.id)")
            XCTAssertFalse(lesson.challenge?.explanation.isEmpty ?? true, "Missing explanation for \(lesson.id)")
            XCTAssertGreaterThan(lesson.estimatedMinutes, 0)
            XCTAssertGreaterThan(lesson.xp, 0)

            if lesson.kind == .code {
                XCTAssertFalse(lesson.challenge?.starterCode?.isEmpty ?? true, "Missing starter code for \(lesson.id)")
                XCTAssertFalse(lesson.challenge?.solution?.isEmpty ?? true, "Missing solution for \(lesson.id)")
                XCTAssertGreaterThanOrEqual(lesson.challenge?.testCases?.count ?? 0, 2, "Missing validation cases for \(lesson.id)")
            }

            if lesson.kind == .quiz || lesson.kind == .architecture {
                let choices = lesson.challenge?.choices ?? []
                XCTAssertGreaterThanOrEqual(choices.count, 3, "Missing decisions for \(lesson.id)")
                XCTAssertTrue(choices.contains { $0.id == lesson.challenge?.correctChoiceID }, "Invalid answer key for \(lesson.id)")
            }
        }

        for kind in LessonKind.allCases {
            XCTAssertTrue(lessons.contains { $0.kind == kind }, "Missing lesson kind: \(kind.rawValue)")
        }

        XCTAssertEqual(lessons.filter { $0.kind == .code }.count, 140)
        XCTAssertEqual(lessons.filter { $0.kind == .quiz }.count, 100)
        XCTAssertEqual(lessons.filter { $0.kind == .architecture }.count, 80)
        XCTAssertEqual(lessons.filter { $0.kind == .concept }.count, 80)
        XCTAssertEqual(Set(lessons.map(\.summary)).count, lessons.count)
        XCTAssertEqual(Set(lessons.compactMap(\.challenge?.prompt)).count, lessons.count)
        XCTAssertEqual(Set(lessons.compactMap(\.challenge?.explanation)).count, lessons.count)
    }

    func testFeaturedCourseCoversProductionCore() throws {
        let curriculum = try loadCurriculum()
        let featured = try XCTUnwrap(curriculum.courses.first(where: \.isFeatured))
        let searchableText = featured.lessons
            .map { lesson in
                ([lesson.title, lesson.summary] + lesson.contentBlocks.map(\.text)).joined(separator: " ")
            }
            .joined(separator: " ")
            .lowercased()

        for concept in ["authorization", "validation", "provider", "telemetry", "backpressure", "budget", "retrieval"] {
            XCTAssertTrue(searchableText.contains(concept), "Featured course does not cover \(concept)")
        }
    }

    private func loadCurriculum() throws -> Curriculum {
        let fileURL = try XCTUnwrap(Bundle.main.url(forResource: "curriculum", withExtension: "json"))
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(Curriculum.self, from: data)
    }
}
