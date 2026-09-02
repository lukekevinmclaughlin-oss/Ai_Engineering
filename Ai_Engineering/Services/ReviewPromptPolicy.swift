import EngineeringShared
import Foundation

enum ReviewPromptPolicy {
    static let lastRequestKey = "review.last-request-date"
    static let lastMilestoneKey = "review.last-request-milestone"
    static let cooldown: TimeInterval = 120 * 24 * 60 * 60

    static func shouldRequest(
        completedLessonCount: Int,
        paywallWillBePresented: Bool,
        now: Date = Date(),
        defaults: UserDefaults = .standard
    ) -> Bool {
        guard !paywallWillBePresented,
              completedLessonCount >= 3,
              completedLessonCount == 3 || completedLessonCount.isMultiple(of: 10),
              defaults.integer(forKey: lastMilestoneKey) < completedLessonCount else {
            return false
        }

        if let lastRequest = defaults.object(forKey: lastRequestKey) as? Date,
           now.timeIntervalSince(lastRequest) < cooldown {
            return false
        }

        defaults.set(now, forKey: lastRequestKey)
        defaults.set(completedLessonCount, forKey: lastMilestoneKey)
        return true
    }
}
