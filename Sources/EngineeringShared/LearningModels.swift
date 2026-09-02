import Foundation

public struct Curriculum: Codable, Sendable {
    public let courses: [Course]
}

public struct Course: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let eyebrow: String
    public let summary: String
    public let icon: String
    public let accent: String
    public let difficulty: String
    public let estimatedMinutes: Int
    public let isFeatured: Bool
    public let skills: [String]
    public let modules: [LearningModule]

    public var lessons: [Lesson] {
        modules.flatMap(\.lessons)
    }

    public var lessonCount: Int {
        lessons.count
    }
}

public struct LearningModule: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let summary: String
    public let lessons: [Lesson]
}

public struct Lesson: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let kind: LessonKind
    public let estimatedMinutes: Int
    public let xp: Int
    public let summary: String
    public let contentBlocks: [LessonContentBlock]
    public let challenge: LessonChallenge?
}

public enum LessonKind: String, Codable, CaseIterable, Sendable {
    case concept
    case quiz
    case code
    case architecture

    public var title: String {
        switch self {
        case .concept: "Concept"
        case .quiz: "Knowledge check"
        case .code: "Code lab"
        case .architecture: "System design"
        }
    }

    public var systemImage: String {
        switch self {
        case .concept: "sparkles"
        case .quiz: "checkmark.seal.fill"
        case .code: "chevron.left.forwardslash.chevron.right"
        case .architecture: "point.3.connected.trianglepath.dotted"
        }
    }
}

public struct LessonContentBlock: Codable, Hashable, Sendable {
    public let type: ContentBlockType
    public let text: String
    public let language: String?
    public let items: [String]?
}

public enum ContentBlockType: String, Codable, Sendable {
    case heading
    case paragraph
    case callout
    case code
    case bullets
}

public struct LessonChallenge: Codable, Hashable, Sendable {
    public let prompt: String
    public let instructions: String
    public let starterCode: String?
    public let solution: String?
    public let testCases: [ChallengeTestCase]?
    public let choices: [ChallengeChoice]?
    public let correctChoiceID: String?
    public let explanation: String
    public let hints: [String]
}

public struct ChallengeChoice: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let text: String
}

public struct ChallengeTestCase: Codable, Hashable, Sendable {
    public let input: String
    public let expected: String
}

public struct LabProject: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let summary: String
    public let icon: String
    public let accent: String
    public let difficulty: String
    public let estimatedHours: Int
    public let xp: Int
    public let skills: [String]
    public let outcomes: [String]
    public let milestones: [ProjectMilestone]
    public let brief: String
    public let starterFiles: [StarterFile]
}

public struct ProjectMilestone: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let detail: String
    public let systemImage: String

    /// Stable progress identity scoped to the project that owns this milestone.
    /// Milestone slugs are intentionally reusable across projects (for example,
    /// several builds contain a `schema` step), so the raw milestone ID alone is
    /// not safe for persistence.
    public func progressID(projectID: String) -> String {
        "\(projectID)::\(id)"
    }
}

public struct StarterFile: Identifiable, Hashable, Sendable {
    public var id: String { name }
    public let name: String
    public let language: String
    public let contents: String
}

public struct SkillMetric: Identifiable, Hashable, Sendable {
    public var id: String { name }
    public let name: String
    public let value: Double
    public let delta: Int
    public let color: String
}
