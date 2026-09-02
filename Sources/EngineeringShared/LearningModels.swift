import Foundation

public struct Curriculum: Codable, Sendable {
    public let courses: [Course]


    public init(courses: [Course]) {
        self.courses = courses
    }
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


    public init(
        id: String,
        title: String,
        eyebrow: String,
        summary: String,
        icon: String,
        accent: String,
        difficulty: String,
        estimatedMinutes: Int,
        isFeatured: Bool,
        skills: [String],
        modules: [LearningModule]
    ) {
        self.id = id
        self.title = title
        self.eyebrow = eyebrow
        self.summary = summary
        self.icon = icon
        self.accent = accent
        self.difficulty = difficulty
        self.estimatedMinutes = estimatedMinutes
        self.isFeatured = isFeatured
        self.skills = skills
        self.modules = modules
    }
}

public struct LearningModule: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let summary: String
    public let lessons: [Lesson]


    public init(id: String, title: String, summary: String, lessons: [Lesson]) {
        self.id = id
        self.title = title
        self.summary = summary
        self.lessons = lessons
    }
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


    public init(
        id: String,
        title: String,
        kind: LessonKind,
        estimatedMinutes: Int,
        xp: Int,
        summary: String,
        contentBlocks: [LessonContentBlock],
        challenge: LessonChallenge?
    ) {
        self.id = id
        self.title = title
        self.kind = kind
        self.estimatedMinutes = estimatedMinutes
        self.xp = xp
        self.summary = summary
        self.contentBlocks = contentBlocks
        self.challenge = challenge
    }
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


    public init(type: ContentBlockType, text: String, language: String?, items: [String]?) {
        self.type = type
        self.text = text
        self.language = language
        self.items = items
    }
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


    public init(
        prompt: String,
        instructions: String,
        starterCode: String?,
        solution: String?,
        testCases: [ChallengeTestCase]?,
        choices: [ChallengeChoice]?,
        correctChoiceID: String?,
        explanation: String,
        hints: [String]
    ) {
        self.prompt = prompt
        self.instructions = instructions
        self.starterCode = starterCode
        self.solution = solution
        self.testCases = testCases
        self.choices = choices
        self.correctChoiceID = correctChoiceID
        self.explanation = explanation
        self.hints = hints
    }
}

public struct ChallengeChoice: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let text: String


    public init(id: String, text: String) {
        self.id = id
        self.text = text
    }
}

public struct ChallengeTestCase: Codable, Hashable, Sendable {
    public let input: String
    public let expected: String


    public init(input: String, expected: String) {
        self.input = input
        self.expected = expected
    }
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


    public init(
        id: String,
        title: String,
        subtitle: String,
        summary: String,
        icon: String,
        accent: String,
        difficulty: String,
        estimatedHours: Int,
        xp: Int,
        skills: [String],
        outcomes: [String],
        milestones: [ProjectMilestone],
        brief: String,
        starterFiles: [StarterFile]
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.summary = summary
        self.icon = icon
        self.accent = accent
        self.difficulty = difficulty
        self.estimatedHours = estimatedHours
        self.xp = xp
        self.skills = skills
        self.outcomes = outcomes
        self.milestones = milestones
        self.brief = brief
        self.starterFiles = starterFiles
    }
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


    public init(id: String, title: String, detail: String, systemImage: String) {
        self.id = id
        self.title = title
        self.detail = detail
        self.systemImage = systemImage
    }
}

public struct StarterFile: Identifiable, Hashable, Sendable {
    public var id: String { name }
    public let name: String
    public let language: String
    public let contents: String


    public init(name: String, language: String, contents: String) {
        self.name = name
        self.language = language
        self.contents = contents
    }
}

public struct SkillMetric: Identifiable, Hashable, Sendable {
    public var id: String { name }
    public let name: String
    public let value: Double
    public let delta: Int
    public let color: String


    public init(name: String, value: Double, delta: Int, color: String) {
        self.name = name
        self.value = value
        self.delta = delta
        self.color = color
    }
}
