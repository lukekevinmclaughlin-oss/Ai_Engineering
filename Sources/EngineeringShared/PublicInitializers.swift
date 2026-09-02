import Foundation
import SwiftUI

public extension Curriculum {
    init(courses: [Course]) {
        self.courses = courses
    }
}

public extension Course {
    init(
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

public extension LearningModule {
    init(id: String, title: String, summary: String, lessons: [Lesson]) {
        self.id = id
        self.title = title
        self.summary = summary
        self.lessons = lessons
    }
}

public extension Lesson {
    init(
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

public extension LessonContentBlock {
    init(type: ContentBlockType, text: String, language: String?, items: [String]?) {
        self.type = type
        self.text = text
        self.language = language
        self.items = items
    }
}

public extension LessonChallenge {
    init(
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

public extension ChallengeChoice {
    init(id: String, text: String) {
        self.id = id
        self.text = text
    }
}

public extension ChallengeTestCase {
    init(input: String, expected: String) {
        self.input = input
        self.expected = expected
    }
}

public extension LabProject {
    init(
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

public extension ProjectMilestone {
    init(id: String, title: String, detail: String, systemImage: String) {
        self.id = id
        self.title = title
        self.detail = detail
        self.systemImage = systemImage
    }
}

public extension StarterFile {
    init(name: String, language: String, contents: String) {
        self.name = name
        self.language = language
        self.contents = contents
    }
}

public extension SkillMetric {
    init(name: String, value: Double, delta: Int, color: String) {
        self.name = name
        self.value = value
        self.delta = delta
        self.color = color
    }
}

public extension TutorSource {
    init(id: String, title: String, location: String) {
        self.id = id
        self.title = title
        self.location = location
    }
}

public extension TutorContext {
    init(
        courseID: String? = nil,
        courseTitle: String? = nil,
        lessonID: String? = nil,
        lessonTitle: String? = nil,
        projectID: String? = nil,
        projectTitle: String? = nil
    ) {
        self.courseID = courseID
        self.courseTitle = courseTitle
        self.lessonID = lessonID
        self.lessonTitle = lessonTitle
        self.projectID = projectID
        self.projectTitle = projectTitle
    }
}

public extension TutorPreferences {
    init(
        engine: TutorEngineChoice = .automatic,
        learnerLevel: TutorLearnerLevel = .firstSteps,
        answerDepth: TutorAnswerDepth = .deepDive
    ) {
        self.engine = engine
        self.learnerLevel = learnerLevel
        self.answerDepth = answerDepth
    }
}

public extension TutorAnswer {
    init(content: String, engineName: String, sources: [TutorSource]) {
        self.content = content
        self.engineName = engineName
        self.sources = sources
    }
}

public extension TutorKnowledgeDocument {
    init(
        id: String,
        kind: Kind,
        title: String,
        location: String,
        summary: String,
        body: String,
        keywords: [String]
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.location = location
        self.summary = summary
        self.body = body
        self.keywords = keywords
    }
}

public extension TutorLocalServerDetection {
    init(server: TutorLocalServer, endpoint: String, models: [String]) {
        self.server = server
        self.endpoint = endpoint
        self.models = models
    }
}

public extension LearnerProgress {
    init(
        completedLessonIDs: Set<String> = [],
        completedMilestoneIDs: Set<String> = [],
        bookmarkedCourseIDs: Set<String> = [],
        recentLessonIDs: [String] = [],
        skillXP: [String: Int] = [:],
        dailyXP: [String: Int] = [:],
        totalXP: Int = 0,
        streak: Int = 0,
        lastActivityDay: String? = nil,
        dailyGoal: Int = 100
    ) {
        self.completedLessonIDs = completedLessonIDs
        self.completedMilestoneIDs = completedMilestoneIDs
        self.bookmarkedCourseIDs = bookmarkedCourseIDs
        self.recentLessonIDs = recentLessonIDs
        self.skillXP = skillXP
        self.dailyXP = dailyXP
        self.totalXP = totalXP
        self.streak = streak
        self.lastActivityDay = lastActivityDay
        self.dailyGoal = dailyGoal
    }
}

public extension AEFlowLayout {
    init(spacing: CGFloat = AESpacing.xs) {
        self.spacing = spacing
    }
}

public extension SyntaxToken {
    init(location: Int, length: Int, kind: SyntaxTokenKind) {
        self.location = location
        self.length = length
        self.kind = kind
    }
}

public extension SyntaxRGB {
    init(red: Double, green: Double, blue: Double) {
        self.red = red
        self.green = green
        self.blue = blue
    }
}

public extension AESyntaxCodeBlock {
    init(
        code: String,
        language: CodeLanguage,
        title: String? = nil,
        accent: Color = AEColor.azure,
        labelAccent: Color? = nil,
        showsCopyButton: Bool = true
    ) {
        self.code = code
        self.language = language
        self.title = title
        self.accent = accent
        self.labelAccent = labelAccent
        self.showsCopyButton = showsCopyButton
    }
}

public extension AESyntaxCodeEditor {
    init(
        text: Binding<String>,
        language: CodeLanguage,
        fileName: String,
        accent: Color = AEColor.azure,
        labelAccent: Color? = nil,
        minHeight: CGFloat = 260,
        isRunning: Bool = false
    ) {
        self._text = text
        self.language = language
        self.fileName = fileName
        self.accent = accent
        self.labelAccent = labelAccent
        self.minHeight = minHeight
        self.isRunning = isRunning
    }
}

public extension AECodeConsole {
    init(
        lines: [String],
        accent: Color = AEColor.signal,
        labelAccent: Color? = nil,
        isRunning: Bool = false
    ) {
        self.lines = lines
        self.accent = accent
        self.labelAccent = labelAccent
        self.isRunning = isRunning
    }
}
