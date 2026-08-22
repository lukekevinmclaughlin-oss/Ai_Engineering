import XCTest
@testable import Ai_Engineering

final class ReviewPromptPolicyTests: XCTestCase {
    func testRequestsAfterThirdLesson() {
        let defaults = makeDefaults()
        XCTAssertTrue(ReviewPromptPolicy.shouldRequest(
            completedLessonCount: 3,
            paywallWillBePresented: false,
            defaults: defaults
        ))
    }

    func testDoesNotRequestWithPaywallOrBeforeMilestone() {
        let defaults = makeDefaults()
        XCTAssertFalse(ReviewPromptPolicy.shouldRequest(
            completedLessonCount: 2,
            paywallWillBePresented: false,
            defaults: defaults
        ))
        XCTAssertFalse(ReviewPromptPolicy.shouldRequest(
            completedLessonCount: 3,
            paywallWillBePresented: true,
            defaults: defaults
        ))
    }

    func testCooldownPreventsRepeatedRequest() {
        let defaults = makeDefaults()
        let now = Date(timeIntervalSince1970: 10_000_000)
        XCTAssertTrue(ReviewPromptPolicy.shouldRequest(
            completedLessonCount: 3,
            paywallWillBePresented: false,
            now: now,
            defaults: defaults
        ))
        XCTAssertFalse(ReviewPromptPolicy.shouldRequest(
            completedLessonCount: 10,
            paywallWillBePresented: false,
            now: now.addingTimeInterval(ReviewPromptPolicy.cooldown - 1),
            defaults: defaults
        ))
        XCTAssertTrue(ReviewPromptPolicy.shouldRequest(
            completedLessonCount: 10,
            paywallWillBePresented: false,
            now: now.addingTimeInterval(ReviewPromptPolicy.cooldown + 1),
            defaults: defaults
        ))
    }

    private func makeDefaults() -> UserDefaults {
        let suiteName = "ReviewPromptPolicyTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }
}
