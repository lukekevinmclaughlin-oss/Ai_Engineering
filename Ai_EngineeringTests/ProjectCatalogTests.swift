import XCTest
@testable import Ai_Engineering

final class ProjectCatalogTests: XCTestCase {
    func testPortfolioContainsFortySubstantiveInteractiveProjects() {
        let projects = ProjectCatalog.all
        XCTAssertEqual(projects.count, 40)
        XCTAssertEqual(Set(projects.map(\.id)).count, 40)
        XCTAssertEqual(projects.filter { $0.difficulty == "Beginner" }.count, 12)
        XCTAssertEqual(projects.filter { $0.difficulty == "Intermediate" }.count, 14)
        XCTAssertEqual(projects.filter { $0.difficulty == "Advanced" }.count, 14)
        XCTAssertTrue(projects.prefix(12).allSatisfy { $0.difficulty == "Beginner" })
        XCTAssertTrue(projects.dropFirst(12).prefix(14).allSatisfy { $0.difficulty == "Intermediate" })
        XCTAssertTrue(projects.suffix(14).allSatisfy { $0.difficulty == "Advanced" })
        XCTAssertEqual(Set(projects.map(\.difficulty)), ["Beginner", "Intermediate", "Advanced"])

        for project in projects {
            XCTAssertGreaterThanOrEqual(project.skills.count, 4, "Thin skill set: \(project.id)")
            XCTAssertLessThanOrEqual(project.skills.count, 6, "Unfocused skill set: \(project.id)")
            XCTAssertEqual(project.outcomes.count, 4, "Each project needs four outcomes: \(project.id)")
            XCTAssertEqual(project.milestones.count, 4, "Each project needs four milestones: \(project.id)")
            XCTAssertFalse(project.brief.isEmpty, "Missing client brief: \(project.id)")
            XCTAssertFalse(project.starterFiles.isEmpty, "Missing editable starter workspace: \(project.id)")
            XCTAssertTrue(project.starterFiles.allSatisfy { !$0.contents.isEmpty })
            XCTAssertGreaterThanOrEqual(project.xp, 900)
            XCTAssertLessThanOrEqual(project.xp, 3_000)
            XCTAssertGreaterThan(project.estimatedHours, 0)
        }
    }
}
