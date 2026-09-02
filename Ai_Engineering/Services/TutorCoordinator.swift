import EngineeringShared
import Combine
import Foundation

@MainActor
final class TutorCoordinator: ObservableObject {
    @Published private(set) var messages: [TutorMessage]
    @Published private(set) var isResponding = false
    @Published var context: TutorContext = .general
    @Published var preferences: TutorPreferences {
        didSet { persist(preferences, key: Self.preferencesKey) }
    }
    @Published var providerConfiguration: TutorProviderConfiguration {
        didSet {
            persist(providerConfiguration, key: Self.providerKey)
            credentialIsStored = TutorCredentialStore.hasCredential(for: providerConfiguration.endpoint)
        }
    }
    @Published private(set) var credentialIsStored: Bool

    let knowledgeBase: TutorKnowledgeBase
    private let defaults: UserDefaults
    private var appleRuntime: (any AppleTutorRuntime)?
    private var responseTask: Task<Void, Never>?
    private var conversationID = UUID()

    private static let preferencesKey = "tutor.preferences.v1"
    private static let providerKey = "tutor.provider.v1"

    init(
        curriculum: Curriculum,
        projects: [LabProject],
        defaults: UserDefaults = .standard
    ) {
        self.defaults = defaults
        knowledgeBase = TutorKnowledgeBase(curriculum: curriculum, projects: projects)
        let savedProvider = Self.decode(TutorProviderConfiguration.self, key: Self.providerKey, defaults: defaults) ?? TutorProviderConfiguration()
        preferences = Self.decode(TutorPreferences.self, key: Self.preferencesKey, defaults: defaults) ?? TutorPreferences()
        providerConfiguration = savedProvider
        credentialIsStored = TutorCredentialStore.hasCredential(for: savedProvider.endpoint)
        messages = [Self.welcomeMessage]
        appleRuntime = AppleOnDeviceTutor.makeRuntime()
    }

    deinit {
        responseTask?.cancel()
    }

    var appleAvailability: AppleTutorAvailability {
        AppleOnDeviceTutor.availability
    }

    var activeEngineName: String {
        switch preferences.engine {
        case .automatic:
            return appleAvailability.isAvailable ? "Apple On-Device" : "Offline Core"
        case .offlineCore:
            return "Offline Core"
        case .appleOnDevice:
            return appleAvailability.isAvailable ? "Apple On-Device" : "Offline Core fallback"
        case .connectedProvider:
            return providerIsReady ? providerConfiguration.displayName : "Offline Core fallback"
        }
    }

    var activeEngineDetail: String {
        if preferences.engine == .connectedProvider && providerIsReady {
            return "Network enabled for this optional provider"
        }
        if activeEngineName == "Apple On-Device" {
            return "Private generative model · no account or API"
        }
        return "Bundled knowledge · network off"
    }

    var usesNetwork: Bool {
        preferences.engine == .connectedProvider && providerIsReady
    }

    var providerIsReady: Bool {
        providerConfiguration.isConfigured
            && (!providerConfiguration.requiresCredential || credentialIsStored)
    }

    var starterPrompts: [String] {
        if let lessonTitle = context.lessonTitle {
            return [
                "Explain \(lessonTitle) as if I only know basic arithmetic.",
                "Give me a concrete example, then quiz me.",
                "What are the most common mistakes in this lesson?",
                "Walk me through the challenge without giving away the answer."
            ]
        }
        if let projectTitle = context.projectTitle {
            return [
                "Help me plan \(projectTitle) from zero.",
                "Review the architecture and identify failure modes.",
                "Break the first milestone into tiny steps.",
                "How should I evaluate this project?"
            ]
        }
        return [
            "What does an AI engineer actually do?",
            "Explain language models using only basic arithmetic.",
            "Teach me RAG with a simple real-world example.",
            "Design a safe AI system with me step by step."
        ]
    }

    func setContext(_ newContext: TutorContext) {
        context = newContext
    }

    func clearContext() {
        context = .general
    }

    func clearConversation() {
        responseTask?.cancel()
        responseTask = nil
        conversationID = UUID()
        isResponding = false
        appleRuntime = AppleOnDeviceTutor.makeRuntime()
        messages = [Self.welcomeMessage]
    }

    func saveCredential(_ token: String) throws {
        try TutorCredentialStore.save(token, for: providerConfiguration.endpoint)
        credentialIsStored = !token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func connectAPIProvider(apiKey: String) throws {
        guard providerConfiguration.connectionMode == .apiProvider,
              providerConfiguration.endpointMatchesConnection,
              !providerConfiguration.model.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw TutorProviderError.notConfigured
        }
        _ = try TutorEndpointPolicy.validatedURL(providerConfiguration.endpoint)
        let key = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        if key.isEmpty {
            guard TutorCredentialStore.hasCredential(for: providerConfiguration.endpoint) else {
                throw TutorProviderError.missingCredential
            }
            credentialIsStored = true
        } else {
            try TutorCredentialStore.save(key, for: providerConfiguration.endpoint)
            credentialIsStored = true
        }
        providerConfiguration.isEnabled = true
        preferences.engine = .connectedProvider
    }

    func connectLocalServer() throws {
        guard providerConfiguration.connectionMode == .localServer,
              providerConfiguration.endpointMatchesConnection,
              !providerConfiguration.model.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw TutorProviderError.notConfigured
        }
        _ = try TutorEndpointPolicy.validatedURL(providerConfiguration.endpoint)
        providerConfiguration.isEnabled = true
        preferences.engine = .connectedProvider
    }

    func disconnectProvider(forgetCredential: Bool = false) {
        if forgetCredential, providerConfiguration.requiresCredential {
            TutorCredentialStore.delete()
            credentialIsStored = false
        }
        providerConfiguration.isEnabled = false
        if preferences.engine == .connectedProvider {
            preferences.engine = .automatic
        }
    }

    func send(_ rawQuestion: String) {
        let question = rawQuestion.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty, !isResponding else { return }

        messages.append(TutorMessage(role: .user, content: question))
        isResponding = true
        let requestContext = context
        let requestPreferences = preferences
        let requestProvider = providerConfiguration
        let conversation = recentConversation(excludingLatestQuestion: true)
        let requestConversationID = conversationID

        responseTask = Task { [weak self] in
            guard let self else { return }
            let answer = await self.makeAnswer(
                question: question,
                context: requestContext,
                preferences: requestPreferences,
                provider: requestProvider,
                recentConversation: conversation
            )
            guard !Task.isCancelled, self.conversationID == requestConversationID else { return }
            self.messages.append(
                TutorMessage(
                    role: .tutor,
                    content: answer.content,
                    engineName: answer.engineName,
                    sources: answer.sources
                )
            )
            self.isResponding = false
            self.responseTask = nil
        }
    }

    private func makeAnswer(
        question: String,
        context: TutorContext,
        preferences: TutorPreferences,
        provider: TutorProviderConfiguration,
        recentConversation: String
    ) async -> TutorAnswer {
        let packet = knowledgeBase.groundingPacket(for: question, context: context)

        switch preferences.engine {
        case .offlineCore:
            return knowledgeBase.offlineAnswer(to: question, context: context, preferences: preferences)

        case .automatic:
            guard appleAvailability.isAvailable else {
                return knowledgeBase.offlineAnswer(to: question, context: context, preferences: preferences)
            }
            return await appleAnswer(
                question: question,
                packet: packet,
                context: context,
                preferences: preferences
            )

        case .appleOnDevice:
            guard appleAvailability.isAvailable else {
                var fallback = knowledgeBase.offlineAnswer(to: question, context: context, preferences: preferences)
                fallback = TutorAnswer(
                    content: "*Apple On-Device is currently unavailable (\(appleAvailability.title)), so I answered with the bundled Offline Core.*\n\n" + fallback.content,
                    engineName: "Offline Core fallback",
                    sources: fallback.sources
                )
                return fallback
            }
            return await appleAnswer(
                question: question,
                packet: packet,
                context: context,
                preferences: preferences
            )

        case .connectedProvider:
            let token = provider.requiresCredential ? TutorCredentialStore.load(for: provider.endpoint) : ""
            guard provider.isConfigured, !provider.requiresCredential || !token.isEmpty else {
                let fallback = knowledgeBase.offlineAnswer(to: question, context: context, preferences: preferences)
                return TutorAnswer(
                    content: "*No connected provider is enabled, so your question stayed offline.*\n\n" + fallback.content,
                    engineName: "Offline Core fallback",
                    sources: fallback.sources
                )
            }
            do {
                let content = try await ConnectedTutorService.answer(
                    question: question,
                    grounding: packet.text,
                    context: context,
                    preferences: preferences,
                    configuration: provider,
                    token: token,
                    recentConversation: recentConversation
                )
                return TutorAnswer(content: content, engineName: provider.displayName, sources: packet.sources)
            } catch {
                let fallback = knowledgeBase.offlineAnswer(to: question, context: context, preferences: preferences)
                return TutorAnswer(
                    content: "*The optional provider could not answer: \(error.localizedDescription) I switched back to Offline Core.*\n\n" + fallback.content,
                    engineName: "Offline Core fallback",
                    sources: fallback.sources
                )
            }
        }
    }

    private func appleAnswer(
        question: String,
        packet: (text: String, sources: [TutorSource]),
        context: TutorContext,
        preferences: TutorPreferences
    ) async -> TutorAnswer {
        if appleRuntime == nil {
            appleRuntime = AppleOnDeviceTutor.makeRuntime()
        }
        guard let appleRuntime else {
            return knowledgeBase.offlineAnswer(to: question, context: context, preferences: preferences)
        }
        do {
            let content = try await appleRuntime.answer(
                question: question,
                grounding: packet.text,
                context: context,
                preferences: preferences
            )
            return TutorAnswer(content: content, engineName: "Apple On-Device", sources: packet.sources)
        } catch {
            let fallback = knowledgeBase.offlineAnswer(to: question, context: context, preferences: preferences)
            return TutorAnswer(
                content: "*The on-device generative model was temporarily unavailable, so I answered from the bundled curriculum.*\n\n" + fallback.content,
                engineName: "Offline Core fallback",
                sources: fallback.sources
            )
        }
    }

    private func recentConversation(excludingLatestQuestion: Bool) -> String {
        let source = excludingLatestQuestion ? messages.dropLast() : messages[...]
        return source.suffix(6).map { message in
            "\(message.role == .user ? "Learner" : "Tutor"): \(message.content.prefix(700))"
        }
        .joined(separator: "\n")
    }

    private func persist<T: Encodable>(_ value: T, key: String) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    private static func decode<T: Decodable>(_ type: T.Type, key: String, defaults: UserDefaults) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    private static let welcomeMessage = TutorMessage(
        role: .tutor,
        content: """
        **Tutor Core is ready — fully offline.**

        Ask me anything about AI engineering. I can begin with basic arithmetic, define every new word, work through code or architecture, and keep going until the idea clicks.

        Offline Core is included and never sends your questions anywhere. On supported devices, Apple On-Device adds private generative reasoning. You can also connect a favourite LLM in Settings, but that is optional and will never turn on by itself.
        """,
        engineName: "Offline Core"
    )
}
