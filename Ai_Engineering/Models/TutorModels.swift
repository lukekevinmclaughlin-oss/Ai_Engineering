import Foundation

enum TutorMessageRole: String, Codable, Sendable {
    case user
    case tutor
}

struct TutorMessage: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let role: TutorMessageRole
    let content: String
    let createdAt: Date
    let engineName: String?
    let sources: [TutorSource]

    init(
        id: UUID = UUID(),
        role: TutorMessageRole,
        content: String,
        createdAt: Date = Date(),
        engineName: String? = nil,
        sources: [TutorSource] = []
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.createdAt = createdAt
        self.engineName = engineName
        self.sources = sources
    }
}

struct TutorSource: Identifiable, Codable, Equatable, Hashable, Sendable {
    let id: String
    let title: String
    let location: String
}

struct TutorContext: Codable, Equatable, Hashable, Sendable {
    let courseID: String?
    let courseTitle: String?
    let lessonID: String?
    let lessonTitle: String?
    let projectID: String?
    let projectTitle: String?

    static let general = TutorContext(
        courseID: nil,
        courseTitle: nil,
        lessonID: nil,
        lessonTitle: nil,
        projectID: nil,
        projectTitle: nil
    )

    static func lesson(_ lesson: Lesson, in course: Course) -> TutorContext {
        TutorContext(
            courseID: course.id,
            courseTitle: course.title,
            lessonID: lesson.id,
            lessonTitle: lesson.title,
            projectID: nil,
            projectTitle: nil
        )
    }

    static func project(_ project: LabProject) -> TutorContext {
        TutorContext(
            courseID: nil,
            courseTitle: nil,
            lessonID: nil,
            lessonTitle: nil,
            projectID: project.id,
            projectTitle: project.title
        )
    }

    var isGeneral: Bool {
        lessonID == nil && projectID == nil
    }

    var displayTitle: String {
        if let lessonTitle { return lessonTitle }
        if let projectTitle { return projectTitle }
        return "Whole curriculum"
    }

    var subtitle: String {
        if let courseTitle { return courseTitle }
        if projectID != nil { return "Portfolio project" }
        return "40 courses · 400 lessons"
    }
}

enum TutorEngineChoice: String, Codable, CaseIterable, Identifiable, Sendable {
    case automatic
    case offlineCore
    case appleOnDevice
    case connectedProvider

    var id: String { rawValue }

    var title: String {
        switch self {
        case .automatic: "Automatic"
        case .offlineCore: "Offline Core"
        case .appleOnDevice: "Apple On-Device"
        case .connectedProvider: "Connected Provider"
        }
    }

    var detail: String {
        switch self {
        case .automatic: "Use the best private engine currently available."
        case .offlineCore: "Bundled curriculum retrieval; never uses a network."
        case .appleOnDevice: "Generative tutoring with Apple Intelligence on supported devices."
        case .connectedProvider: "Use an optional API provider or same-machine local model server you connect."
        }
    }

    var systemImage: String {
        switch self {
        case .automatic: "wand.and.stars"
        case .offlineCore: "internaldrive.fill"
        case .appleOnDevice: "apple.intelligence"
        case .connectedProvider: "link.badge.plus"
        }
    }
}

enum TutorLearnerLevel: String, Codable, CaseIterable, Identifiable, Sendable {
    case firstSteps
    case guided
    case engineer

    var id: String { rawValue }

    var title: String {
        switch self {
        case .firstSteps: "First steps"
        case .guided: "Guided"
        case .engineer: "Engineer"
        }
    }

    var instruction: String {
        switch self {
        case .firstSteps:
            "Assume only basic arithmetic. Define every technical term, use a familiar analogy, and take one small step at a time."
        case .guided:
            "Assume basic Python familiarity. Build intuition before implementation details and surface common mistakes."
        case .engineer:
            "Use precise engineering language, implementation details, failure modes, and production trade-offs."
        }
    }
}

enum TutorAnswerDepth: String, Codable, CaseIterable, Identifiable, Sendable {
    case focused
    case deepDive

    var id: String { rawValue }

    var title: String {
        switch self {
        case .focused: "Focused"
        case .deepDive: "Deep dive"
        }
    }

    var instruction: String {
        switch self {
        case .focused: "Answer in roughly four concise sections."
        case .deepDive: "Teach in depth: intuition, mechanics, example, trade-offs, failure modes, and a check for understanding."
        }
    }
}

struct TutorPreferences: Codable, Equatable, Sendable {
    var engine: TutorEngineChoice = .automatic
    var learnerLevel: TutorLearnerLevel = .firstSteps
    var answerDepth: TutorAnswerDepth = .deepDive
}

enum TutorConnectionMode: String, Codable, CaseIterable, Identifiable, Sendable {
    case apiProvider
    case localServer

    var id: String { rawValue }
}

enum TutorProviderProtocol: String, Codable, Sendable {
    case openAICompatible
    case anthropicMessages
    case geminiGenerateContent
}

enum TutorAPIProvider: String, Codable, CaseIterable, Identifiable, Sendable {
    case openAI
    case anthropic
    case googleGemini
    case xAI
    case deepSeek
    case mistral
    case groq
    case openRouter
    case together
    case fireworks
    case perplexity
    case cerebras
    case customOpenAICompatible

    var id: String { rawValue }

    var title: String {
        switch self {
        case .openAI: "OpenAI"
        case .anthropic: "Anthropic"
        case .googleGemini: "Google Gemini"
        case .xAI: "xAI"
        case .deepSeek: "DeepSeek"
        case .mistral: "Mistral"
        case .groq: "Groq"
        case .openRouter: "OpenRouter"
        case .together: "Together"
        case .fireworks: "Fireworks"
        case .perplexity: "Perplexity"
        case .cerebras: "Cerebras"
        case .customOpenAICompatible: "Custom OpenAI-compatible"
        }
    }

    var protocolFamily: TutorProviderProtocol {
        switch self {
        case .anthropic: .anthropicMessages
        case .googleGemini: .geminiGenerateContent
        default: .openAICompatible
        }
    }

    var endpoint: String {
        switch self {
        case .openAI: "https://api.openai.com/v1/chat/completions"
        case .anthropic: "https://api.anthropic.com/v1/messages"
        case .googleGemini: "https://generativelanguage.googleapis.com/v1beta"
        case .xAI: "https://api.x.ai/v1/chat/completions"
        case .deepSeek: "https://api.deepseek.com/chat/completions"
        case .mistral: "https://api.mistral.ai/v1/chat/completions"
        case .groq: "https://api.groq.com/openai/v1/chat/completions"
        case .openRouter: "https://openrouter.ai/api/v1/chat/completions"
        case .together: "https://api.together.xyz/v1/chat/completions"
        case .fireworks: "https://api.fireworks.ai/inference/v1/chat/completions"
        case .perplexity: "https://api.perplexity.ai/chat/completions"
        case .cerebras: "https://api.cerebras.ai/v1/chat/completions"
        case .customOpenAICompatible: ""
        }
    }

    var modelPrompt: String {
        switch self {
        case .openAI: "gpt-5.5"
        case .anthropic: "claude-sonnet-4-6"
        case .googleGemini: "gemini-3.5-flash"
        case .xAI: "grok model ID"
        case .deepSeek: "deepseek-chat"
        case .mistral: "Mistral model ID"
        case .groq: "Groq model ID"
        case .openRouter: "provider/model"
        case .together: "Together model ID"
        case .fireworks: "accounts/.../models/..."
        case .perplexity: "Perplexity model ID"
        case .cerebras: "Cerebras model ID"
        case .customOpenAICompatible: "model-name"
        }
    }

    static func inferred(from endpoint: String) -> TutorAPIProvider {
        guard let host = URLComponents(string: endpoint)?.host?.lowercased() else {
            return .customOpenAICompatible
        }
        if host == "api.openai.com" { return .openAI }
        if host == "api.anthropic.com" { return .anthropic }
        if host == "generativelanguage.googleapis.com" { return .googleGemini }
        if host == "api.x.ai" { return .xAI }
        if host == "api.deepseek.com" { return .deepSeek }
        if host == "api.mistral.ai" { return .mistral }
        if host == "api.groq.com" { return .groq }
        if host == "openrouter.ai" { return .openRouter }
        if host == "api.together.xyz" { return .together }
        if host == "api.fireworks.ai" { return .fireworks }
        if host == "api.perplexity.ai" { return .perplexity }
        if host == "api.cerebras.ai" { return .cerebras }
        return .customOpenAICompatible
    }
}

enum TutorLocalServer: String, Codable, CaseIterable, Identifiable, Sendable {
    case ollama
    case lmStudio

    var id: String { rawValue }

    var title: String {
        switch self {
        case .ollama: "Ollama"
        case .lmStudio: "LM Studio"
        }
    }

    var chatEndpoint: String {
        switch self {
        case .ollama: "http://127.0.0.1:11434/v1/chat/completions"
        case .lmStudio: "http://127.0.0.1:1234/v1/chat/completions"
        }
    }

    var discoveryEndpoint: String {
        switch self {
        case .ollama: "http://127.0.0.1:11434/api/tags"
        case .lmStudio: "http://127.0.0.1:1234/v1/models"
        }
    }

    static func inferred(from endpoint: String, displayName: String) -> TutorLocalServer? {
        let combined = "\(endpoint) \(displayName)".lowercased()
        if combined.contains(":11434") || combined.contains("ollama") { return .ollama }
        if combined.contains(":1234") || combined.contains("lm studio") { return .lmStudio }
        return nil
    }
}

struct TutorProviderConfiguration: Codable, Equatable, Sendable {
    var isEnabled: Bool
    var displayName: String
    var endpoint: String
    var model: String
    var connectionMode: TutorConnectionMode
    var apiProvider: TutorAPIProvider
    var localServer: TutorLocalServer

    init(
        isEnabled: Bool = false,
        displayName: String = TutorAPIProvider.openAI.title,
        endpoint: String = TutorAPIProvider.openAI.endpoint,
        model: String = "",
        connectionMode: TutorConnectionMode = .apiProvider,
        apiProvider: TutorAPIProvider = .openAI,
        localServer: TutorLocalServer = .ollama
    ) {
        self.isEnabled = isEnabled
        self.displayName = displayName
        self.endpoint = endpoint
        self.model = model
        self.connectionMode = connectionMode
        self.apiProvider = apiProvider
        self.localServer = localServer
    }

    var protocolFamily: TutorProviderProtocol {
        connectionMode == .localServer ? .openAICompatible : apiProvider.protocolFamily
    }

    var requiresCredential: Bool { connectionMode == .apiProvider }

    var endpointMatchesConnection: Bool {
        guard let endpointURL = try? TutorEndpointPolicy.validatedURL(endpoint) else { return false }

        switch connectionMode {
        case .apiProvider:
            guard endpointURL.scheme?.lowercased() == "https" else { return false }
            guard apiProvider != .customOpenAICompatible else { return true }
            guard let presetURL = try? TutorEndpointPolicy.validatedURL(apiProvider.endpoint) else { return false }
            return endpointURL == presetURL

        case .localServer:
            guard let presetURL = try? TutorEndpointPolicy.validatedURL(localServer.chatEndpoint) else { return false }
            return endpointURL == presetURL
        }
    }

    var isConfigured: Bool {
        isEnabled
            && endpointMatchesConnection
            && !model.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    mutating func select(_ provider: TutorAPIProvider) {
        connectionMode = .apiProvider
        apiProvider = provider
        displayName = provider.title
        endpoint = provider.endpoint
        isEnabled = false
    }

    mutating func select(_ server: TutorLocalServer) {
        connectionMode = .localServer
        localServer = server
        displayName = "\(server.title) (local)"
        endpoint = server.chatEndpoint
        isEnabled = false
    }

    private enum CodingKeys: String, CodingKey {
        case isEnabled, displayName, endpoint, model
        case connectionMode, apiProvider, localServer
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        isEnabled = try values.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? false
        displayName = try values.decodeIfPresent(String.self, forKey: .displayName) ?? ""
        endpoint = try values.decodeIfPresent(String.self, forKey: .endpoint) ?? ""
        model = try values.decodeIfPresent(String.self, forKey: .model) ?? ""

        if let savedMode = try values.decodeIfPresent(TutorConnectionMode.self, forKey: .connectionMode) {
            connectionMode = savedMode
            apiProvider = try values.decodeIfPresent(TutorAPIProvider.self, forKey: .apiProvider) ?? .openAI
            localServer = try values.decodeIfPresent(TutorLocalServer.self, forKey: .localServer) ?? .ollama
        } else if let inferredLocal = TutorLocalServer.inferred(from: endpoint, displayName: displayName) {
            connectionMode = .localServer
            localServer = inferredLocal
            apiProvider = .openAI
        } else {
            connectionMode = .apiProvider
            apiProvider = TutorAPIProvider.inferred(from: endpoint)
            localServer = .ollama
        }

        if displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            displayName = connectionMode == .localServer ? "\(localServer.title) (local)" : apiProvider.title
        }
        if endpoint.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            endpoint = connectionMode == .localServer ? localServer.chatEndpoint : apiProvider.endpoint
        }
    }
}

enum AppleTutorAvailability: Equatable, Sendable {
    case available
    case unsupportedOS
    case deviceNotEligible
    case intelligenceDisabled
    case modelPreparing

    var title: String {
        switch self {
        case .available: "Ready offline"
        case .unsupportedOS: "Requires iOS/macOS 26"
        case .deviceNotEligible: "Device not eligible"
        case .intelligenceDisabled: "Apple Intelligence is off"
        case .modelPreparing: "Model is preparing"
        }
    }

    var isAvailable: Bool { self == .available }
}

struct TutorAnswer: Sendable {
    let content: String
    let engineName: String
    let sources: [TutorSource]
}

struct TutorKnowledgeDocument: Identifiable, Hashable, Sendable {
    enum Kind: String, Sendable {
        case lesson
        case project
    }

    let id: String
    let kind: Kind
    let title: String
    let location: String
    let summary: String
    let body: String
    let keywords: [String]

    var source: TutorSource {
        TutorSource(id: id, title: title, location: location)
    }
}
