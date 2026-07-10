import Foundation

struct Curriculum: Codable, Sendable {
    let courses: [Course]
}

struct Course: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let eyebrow: String
    let summary: String
    let icon: String
    let accent: String
    let difficulty: String
    let estimatedMinutes: Int
    let isFeatured: Bool
    let skills: [String]
    let modules: [LearningModule]

    var lessons: [Lesson] {
        modules.flatMap(\.lessons)
    }

    var lessonCount: Int {
        lessons.count
    }
}

struct LearningModule: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let summary: String
    let lessons: [Lesson]
}

struct Lesson: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let kind: LessonKind
    let estimatedMinutes: Int
    let xp: Int
    let summary: String
    let contentBlocks: [LessonContentBlock]
    let challenge: LessonChallenge?
}

enum LessonKind: String, Codable, CaseIterable, Sendable {
    case concept
    case quiz
    case code
    case architecture

    var title: String {
        switch self {
        case .concept: "Concept"
        case .quiz: "Knowledge check"
        case .code: "Code lab"
        case .architecture: "System design"
        }
    }

    var systemImage: String {
        switch self {
        case .concept: "sparkles"
        case .quiz: "checkmark.seal.fill"
        case .code: "chevron.left.forwardslash.chevron.right"
        case .architecture: "point.3.connected.trianglepath.dotted"
        }
    }
}

struct LessonContentBlock: Codable, Hashable, Sendable {
    let type: ContentBlockType
    let text: String
    let language: String?
    let items: [String]?
}

enum ContentBlockType: String, Codable, Sendable {
    case heading
    case paragraph
    case callout
    case code
    case bullets
}

struct LessonChallenge: Codable, Hashable, Sendable {
    let prompt: String
    let instructions: String
    let starterCode: String?
    let solution: String?
    let testCases: [ChallengeTestCase]?
    let choices: [ChallengeChoice]?
    let correctChoiceID: String?
    let explanation: String
    let hints: [String]
}

struct ChallengeChoice: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let text: String
}

struct ChallengeTestCase: Codable, Hashable, Sendable {
    let input: String
    let expected: String
}

struct LabProject: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let summary: String
    let icon: String
    let accent: String
    let difficulty: String
    let estimatedHours: Int
    let xp: Int
    let skills: [String]
    let outcomes: [String]
    let milestones: [ProjectMilestone]
    let brief: String
    let starterFiles: [StarterFile]
}

struct ProjectMilestone: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let detail: String
    let systemImage: String
}

struct StarterFile: Identifiable, Hashable, Sendable {
    var id: String { name }
    let name: String
    let language: String
    let contents: String
}

struct SkillMetric: Identifiable, Hashable, Sendable {
    var id: String { name }
    let name: String
    let value: Double
    let delta: Int
    let color: String
}
