import XCTest
@testable import Ai_Engineering

final class TutorTests: XCTestCase {
    func testKnowledgeBaseIndexesEveryLessonAndProject() throws {
        let curriculum = try loadCurriculum()
        let knowledge = TutorKnowledgeBase(curriculum: curriculum, projects: ProjectCatalog.all)

        let lessonCount = curriculum.courses.flatMap(\.lessons).count
        XCTAssertEqual(knowledge.documents.filter { $0.kind == .lesson }.count, lessonCount)
        XCTAssertEqual(knowledge.documents.filter { $0.kind == .project }.count, ProjectCatalog.all.count)
        XCTAssertEqual(Set(knowledge.documents.map(\.id)).count, knowledge.documents.count)
    }

    func testOfflineTutorRetrievesRelevantGrounding() throws {
        let curriculum = try loadCurriculum()
        let knowledge = TutorKnowledgeBase(curriculum: curriculum, projects: ProjectCatalog.all)
        let results = knowledge.rankedDocuments(
            for: "How does retrieval augmented generation ground a model with sources?",
            context: .general,
            limit: 5
        )
        let searchable = results.map { "\($0.title) \($0.summary) \($0.keywords.joined(separator: " "))" }
            .joined(separator: " ")
            .lowercased()

        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(searchable.contains("retrieval") || searchable.contains("rag"))
    }

    func testOfflineTutorProducesStructuredBeginnerAnswerAndSources() throws {
        let curriculum = try loadCurriculum()
        let knowledge = TutorKnowledgeBase(curriculum: curriculum, projects: ProjectCatalog.all)
        let answer = knowledge.offlineAnswer(
            to: "What is an embedding? Explain it from zero.",
            context: .general,
            preferences: TutorPreferences(
                engine: .offlineCore,
                learnerLevel: .firstSteps,
                answerDepth: .deepDive
            )
        )

        XCTAssertEqual(answer.engineName, "Offline Core")
        XCTAssertFalse(answer.sources.isEmpty)
        XCTAssertTrue(answer.content.contains("Short answer"))
        XCTAssertTrue(answer.content.contains("analogy"))
        XCTAssertTrue(answer.content.contains("Check your understanding"))
        XCTAssertTrue(answer.content.contains("Offline Core"))
    }

    func testOfflineTutorAbstainsWhenNothingRelevantIsGrounded() throws {
        let curriculum = try loadCurriculum()
        let knowledge = TutorKnowledgeBase(curriculum: curriculum, projects: ProjectCatalog.all)
        let results = knowledge.rankedDocuments(
            for: "zygomorphic paleobotany specimen qzxv",
            context: .general,
            limit: 5
        )
        let answer = knowledge.offlineAnswer(
            to: "zygomorphic paleobotany specimen qzxv",
            context: .general,
            preferences: TutorPreferences()
        )

        XCTAssertTrue(results.isEmpty)
        XCTAssertTrue(answer.sources.isEmpty)
        XCTAssertTrue(answer.content.contains("could not match"))
    }

    func testConnectedEndpointPolicyRejectsMalformedAndInsecureOrigins() throws {
        XCTAssertThrowsError(try TutorEndpointPolicy.validatedURL("https:example.com/v1/chat/completions"))
        XCTAssertThrowsError(try TutorEndpointPolicy.validatedURL("http://example.com/v1/chat/completions"))
        XCTAssertNoThrow(try TutorEndpointPolicy.validatedURL("https://example.com/v1/chat/completions"))
        XCTAssertNoThrow(try TutorEndpointPolicy.validatedURL("http://127.0.0.1:11434/v1/chat/completions"))

        let first = try TutorEndpointPolicy.validatedURL("https://provider-a.example/v1/chat/completions")
        let second = try TutorEndpointPolicy.validatedURL("https://provider-b.example/v1/chat/completions")
        XCTAssertNotEqual(TutorEndpointPolicy.origin(for: first), TutorEndpointPolicy.origin(for: second))
    }

    @MainActor
    func testAutomaticTutorNeverEnablesNetworkProvider() throws {
        let suiteName = "TutorTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let tutor = TutorCoordinator(
            curriculum: try loadCurriculum(),
            projects: ProjectCatalog.all,
            defaults: defaults
        )
        tutor.providerConfiguration = TutorProviderConfiguration(
            isEnabled: true,
            displayName: "Optional test provider",
            endpoint: "https://example.com/v1/chat/completions",
            model: "test"
        )
        tutor.preferences.engine = .automatic

        XCTAssertFalse(tutor.usesNetwork)
        XCTAssertNotEqual(tutor.activeEngineName, "Optional test provider")
    }

    func testAPIProviderCatalogAndProtocolFamiliesAreExplicit() {
        XCTAssertEqual(TutorAPIProvider.allCases.map(\.title), [
            "OpenAI", "Anthropic", "Google Gemini", "xAI", "DeepSeek", "Mistral", "Groq",
            "OpenRouter", "Together", "Fireworks", "Perplexity", "Cerebras", "Custom OpenAI-compatible"
        ])
        XCTAssertEqual(TutorAPIProvider.openAI.protocolFamily, .openAICompatible)
        XCTAssertEqual(TutorAPIProvider.anthropic.protocolFamily, .anthropicMessages)
        XCTAssertEqual(TutorAPIProvider.googleGemini.protocolFamily, .geminiGenerateContent)
        XCTAssertEqual(TutorAPIProvider.groq.endpoint, "https://api.groq.com/openai/v1/chat/completions")
        XCTAssertEqual(TutorAPIProvider.customOpenAICompatible.endpoint, "")
    }

    func testLegacyProviderConfigurationMigratesWithoutLosingConnection() throws {
        let hostedLegacy = Data(#"{"isEnabled":true,"displayName":"Old gateway","endpoint":"https://gateway.example/v1/chat/completions","model":"legacy-model"}"#.utf8)
        let hosted = try JSONDecoder().decode(TutorProviderConfiguration.self, from: hostedLegacy)
        XCTAssertEqual(hosted.connectionMode, .apiProvider)
        XCTAssertEqual(hosted.apiProvider, .customOpenAICompatible)
        XCTAssertEqual(hosted.displayName, "Old gateway")
        XCTAssertTrue(hosted.isConfigured)

        let localLegacy = Data(#"{"isEnabled":true,"displayName":"Ollama (local)","endpoint":"http://127.0.0.1:11434/v1/chat/completions","model":"qwen"}"#.utf8)
        let local = try JSONDecoder().decode(TutorProviderConfiguration.self, from: localLegacy)
        XCTAssertEqual(local.connectionMode, .localServer)
        XCTAssertEqual(local.localServer, .ollama)
        XCTAssertFalse(local.requiresCredential)
        XCTAssertTrue(local.isConfigured)

        let roundTrip = try JSONDecoder().decode(
            TutorProviderConfiguration.self,
            from: JSONEncoder().encode(local)
        )
        XCTAssertEqual(roundTrip, local)
    }

    func testOpenAICompatibleRequestUsesOriginBoundBearerAndChatSchema() throws {
        let configuration = TutorProviderConfiguration(
            isEnabled: true,
            displayName: "Groq",
            endpoint: TutorAPIProvider.groq.endpoint,
            model: "test-model",
            connectionMode: .apiProvider,
            apiProvider: .groq
        )
        let request = try ConnectedTutorService.makeRequest(
            configuration: configuration,
            token: "secret",
            system: "system",
            user: "question",
            maxTokens: 321
        )
        XCTAssertEqual(request.url?.absoluteString, TutorAPIProvider.groq.endpoint)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer secret")
        let json = try XCTUnwrap(try JSONSerialization.jsonObject(with: XCTUnwrap(request.httpBody)) as? [String: Any])
        XCTAssertEqual(json["model"] as? String, "test-model")
        XCTAssertEqual(json["max_tokens"] as? Int, 321)
        XCTAssertNil(json["max_completion_tokens"])
        XCTAssertEqual((json["messages"] as? [[String: Any]])?.count, 2)
        XCTAssertEqual((json["messages"] as? [[String: Any]])?.first?["role"] as? String, "system")
    }

    func testNativeOpenAIRequestUsesDeveloperInstructionRole() throws {
        let configuration = TutorProviderConfiguration(
            isEnabled: true,
            displayName: "OpenAI",
            endpoint: TutorAPIProvider.openAI.endpoint,
            model: "test-model",
            connectionMode: .apiProvider,
            apiProvider: .openAI
        )
        let request = try ConnectedTutorService.makeRequest(
            configuration: configuration,
            token: "secret",
            system: "developer instruction",
            user: "question",
            maxTokens: 321
        )
        let json = try XCTUnwrap(try JSONSerialization.jsonObject(with: XCTUnwrap(request.httpBody)) as? [String: Any])
        XCTAssertEqual((json["messages"] as? [[String: Any]])?.first?["role"] as? String, "developer")
        XCTAssertEqual(json["max_completion_tokens"] as? Int, 321)
    }

    func testAnthropicMessagesRequestUsesNativeHeadersAndBody() throws {
        let configuration = TutorProviderConfiguration(
            isEnabled: true,
            displayName: "Anthropic",
            endpoint: TutorAPIProvider.anthropic.endpoint,
            model: "claude-test",
            connectionMode: .apiProvider,
            apiProvider: .anthropic
        )
        let request = try ConnectedTutorService.makeRequest(
            configuration: configuration,
            token: "anthropic-secret",
            system: "system instruction",
            user: "learner question",
            maxTokens: 777
        )
        XCTAssertEqual(request.value(forHTTPHeaderField: "x-api-key"), "anthropic-secret")
        XCTAssertEqual(request.value(forHTTPHeaderField: "anthropic-version"), "2023-06-01")
        XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"))
        let json = try XCTUnwrap(try JSONSerialization.jsonObject(with: XCTUnwrap(request.httpBody)) as? [String: Any])
        XCTAssertEqual(json["system"] as? String, "system instruction")
        XCTAssertEqual(json["max_tokens"] as? Int, 777)
        XCTAssertEqual((json["messages"] as? [[String: Any]])?.first?["role"] as? String, "user")
    }

    func testGeminiGenerateContentRequestUsesNativeURLHeaderAndBody() throws {
        let configuration = TutorProviderConfiguration(
            isEnabled: true,
            displayName: "Google Gemini",
            endpoint: TutorAPIProvider.googleGemini.endpoint,
            model: "gemini-test",
            connectionMode: .apiProvider,
            apiProvider: .googleGemini
        )
        let request = try ConnectedTutorService.makeRequest(
            configuration: configuration,
            token: "gemini-secret",
            system: "system instruction",
            user: "learner question",
            maxTokens: 654
        )
        XCTAssertEqual(
            request.url?.absoluteString,
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-test:generateContent"
        )
        XCTAssertEqual(request.value(forHTTPHeaderField: "x-goog-api-key"), "gemini-secret")
        XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"))
        let json = try XCTUnwrap(try JSONSerialization.jsonObject(with: XCTUnwrap(request.httpBody)) as? [String: Any])
        XCTAssertNotNil(json["systemInstruction"])
        XCTAssertNotNil(json["contents"])
        XCTAssertEqual((json["generationConfig"] as? [String: Any])?["maxOutputTokens"] as? Int, 654)
    }

    func testNativeProviderResponsesDecodeText() throws {
        let openAI = Data(#"{"choices":[{"message":{"content":"OpenAI answer"}}]}"#.utf8)
        XCTAssertEqual(try ConnectedTutorService.decodeResponse(openAI, protocolFamily: .openAICompatible), "OpenAI answer")

        let anthropic = Data(#"{"content":[{"type":"text","text":"Claude answer"},{"type":"tool_use"}]}"#.utf8)
        XCTAssertEqual(try ConnectedTutorService.decodeResponse(anthropic, protocolFamily: .anthropicMessages), "Claude answer")

        let gemini = Data(#"{"candidates":[{"content":{"parts":[{"text":"Gemini answer"}]}}]}"#.utf8)
        XCTAssertEqual(try ConnectedTutorService.decodeResponse(gemini, protocolFamily: .geminiGenerateContent), "Gemini answer")
    }

    func testLocalServerDiscoveryParsesOllamaAndLMStudioModels() throws {
        let ollama = Data(#"{"models":[{"name":"qwen:4b"},{"model":"gemma:2b"},{"name":"qwen:4b"}]}"#.utf8)
        XCTAssertEqual(
            try LocalTutorServerDiscovery.parseModels(ollama, for: .ollama),
            ["gemma:2b", "qwen:4b"]
        )

        let lmStudio = Data(#"{"data":[{"id":"local/one"},{"id":"local/two"}]}"#.utf8)
        XCTAssertEqual(
            try LocalTutorServerDiscovery.parseModels(lmStudio, for: .lmStudio),
            ["local/one", "local/two"]
        )
    }

    func testAPIConnectionRequiresAUserCredentialButLocalDoesNot() throws {
        let api = TutorProviderConfiguration(
            isEnabled: true,
            displayName: "OpenAI",
            endpoint: TutorAPIProvider.openAI.endpoint,
            model: "test",
            connectionMode: .apiProvider,
            apiProvider: .openAI
        )
        XCTAssertThrowsError(try ConnectedTutorService.makeRequest(
            configuration: api,
            token: "",
            system: "system",
            user: "user",
            maxTokens: 10
        ))

        let local = TutorProviderConfiguration(
            isEnabled: true,
            displayName: "Ollama (local)",
            endpoint: TutorLocalServer.ollama.chatEndpoint,
            model: "local-model",
            connectionMode: .localServer,
            localServer: .ollama
        )
        XCTAssertNoThrow(try ConnectedTutorService.makeRequest(
            configuration: local,
            token: "",
            system: "system",
            user: "user",
            maxTokens: 10
        ))
    }

    func testAPIProviderCannotReuseASelectedLocalServerEndpoint() throws {
        var configuration = TutorProviderConfiguration(
            isEnabled: true,
            displayName: "Ollama (local)",
            endpoint: TutorLocalServer.ollama.chatEndpoint,
            model: "local-model",
            connectionMode: .localServer,
            apiProvider: .openAI,
            localServer: .ollama
        )
        XCTAssertTrue(configuration.endpointMatchesConnection)

        configuration.connectionMode = .apiProvider
        configuration.displayName = TutorAPIProvider.openAI.title
        XCTAssertFalse(configuration.endpointMatchesConnection)
        XCTAssertFalse(configuration.isConfigured)
        XCTAssertThrowsError(try ConnectedTutorService.makeRequest(
            configuration: configuration,
            token: "must-not-reach-localhost",
            system: "system",
            user: "user",
            maxTokens: 10
        ))
    }

    func testPresetConnectionsRequireTheirExactEndpoint() {
        var api = TutorProviderConfiguration(
            isEnabled: true,
            displayName: "OpenAI",
            endpoint: "https://example.com/v1/chat/completions",
            model: "test",
            connectionMode: .apiProvider,
            apiProvider: .openAI
        )
        XCTAssertFalse(api.endpointMatchesConnection)
        api.apiProvider = .customOpenAICompatible
        XCTAssertTrue(api.endpointMatchesConnection)

        let wrongLocal = TutorProviderConfiguration(
            isEnabled: true,
            displayName: "Ollama (local)",
            endpoint: TutorLocalServer.lmStudio.chatEndpoint,
            model: "test",
            connectionMode: .localServer,
            localServer: .ollama
        )
        XCTAssertFalse(wrongLocal.endpointMatchesConnection)
    }

    func testRedirectPolicyAllowsOnlyTheOriginalOrigin() throws {
        let delegate = SameOriginRedirectDelegate(origin: "http://127.0.0.1:11434")
        XCTAssertTrue(delegate.allows(try XCTUnwrap(URL(string: "http://127.0.0.1:11434/api/tags"))))
        XCTAssertFalse(delegate.allows(try XCTUnwrap(URL(string: "http://127.0.0.1:1234/v1/models"))))
        XCTAssertFalse(delegate.allows(try XCTUnwrap(URL(string: "https://example.com/models"))))
    }

    func testBoundedResponseRejectsDeclaredAndChunkedOversizeBodies() throws {
        XCTAssertNoThrow(try BoundedHTTPBody.validateExpectedLength(-1, maximumBytes: 16))
        XCTAssertNoThrow(try BoundedHTTPBody.validateExpectedLength(16, maximumBytes: 16))
        XCTAssertThrowsError(try BoundedHTTPBody.validateExpectedLength(17, maximumBytes: 16))

        var data = Data()
        for byte in Data(repeating: 65, count: 16) {
            try BoundedHTTPBody.append(byte, to: &data, maximumBytes: 16)
        }
        XCTAssertEqual(data.count, 16)
        XCTAssertThrowsError(try BoundedHTTPBody.append(65, to: &data, maximumBytes: 16))
        XCTAssertEqual(data.count, 16)
    }

    private func loadCurriculum() throws -> Curriculum {
        let fileURL = try XCTUnwrap(Bundle.main.url(forResource: "curriculum", withExtension: "json"))
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(Curriculum.self, from: data)
    }
}
