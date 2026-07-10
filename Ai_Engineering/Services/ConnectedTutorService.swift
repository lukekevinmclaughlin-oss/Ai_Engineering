import Foundation
import Security

enum TutorCredentialStore {
    private static let service = "com.lukemclaughlin.aiengineering.tutor-provider"
    private static let account = "bearer-token"

    private struct Record: Codable {
        let origin: String
        let token: String
    }

    static func save(_ token: String, for endpoint: String) throws {
        let trimmed = token.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            delete()
            return
        }

        let url = try TutorEndpointPolicy.validatedURL(endpoint)
        let record = Record(origin: TutorEndpointPolicy.origin(for: url), token: trimmed)
        let data = try JSONEncoder().encode(record)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        let attributes: [String: Any] = [kSecValueData as String: data]
        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        if updateStatus == errSecItemNotFound {
            var insert = query
            insert[kSecValueData as String] = data
            let status = SecItemAdd(insert as CFDictionary, nil)
            guard status == errSecSuccess else { throw TutorProviderError.keychain(status) }
        } else if updateStatus != errSecSuccess {
            throw TutorProviderError.keychain(updateStatus)
        }
    }

    static func load(for endpoint: String) -> String {
        guard let url = try? TutorEndpointPolicy.validatedURL(endpoint) else { return "" }
        let requiredOrigin = TutorEndpointPolicy.origin(for: url)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data,
              let record = try? JSONDecoder().decode(Record.self, from: data),
              record.origin == requiredOrigin else {
            return ""
        }
        return record.token
    }

    static func hasCredential(for endpoint: String) -> Bool {
        !load(for: endpoint).isEmpty
    }

    static func delete() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}

enum TutorEndpointPolicy {
    static func validatedURL(_ rawValue: String) throws -> URL {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let components = URLComponents(string: trimmed),
              let scheme = components.scheme?.lowercased(),
              let host = components.host?.lowercased(),
              !host.isEmpty,
              components.user == nil,
              components.password == nil,
              let url = components.url else {
            throw TutorProviderError.invalidEndpoint
        }

        let localHosts = ["localhost", "127.0.0.1", "::1"]
        guard scheme == "https" || (scheme == "http" && localHosts.contains(host)) else {
            throw TutorProviderError.insecureEndpoint
        }
        return url
    }

    static func origin(for url: URL) -> String {
        let scheme = url.scheme?.lowercased() ?? ""
        let host = url.host?.lowercased() ?? ""
        let port = url.port.map { ":\($0)" } ?? ""
        return "\(scheme)://\(host)\(port)"
    }
}

enum TutorProviderError: LocalizedError {
    case notConfigured
    case missingCredential
    case invalidEndpoint
    case insecureEndpoint
    case invalidResponse
    case responseTooLarge
    case server(Int, String)
    case emptyResponse
    case keychain(OSStatus)

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            "The optional tutor connection is not configured."
        case .missingCredential:
            "Enter your API key and connect this provider first."
        case .invalidEndpoint:
            "Enter a full, valid provider endpoint URL."
        case .insecureEndpoint:
            "Hosted providers require HTTPS. Plain HTTP is allowed only for localhost model servers."
        case .invalidResponse:
            "The provider returned a response Tutor Core could not read."
        case .responseTooLarge:
            "The provider response exceeded Tutor Core’s safe size limit."
        case let .server(code, message):
            "The provider returned HTTP \(code): \(message)"
        case .emptyResponse:
            "The provider returned an empty answer."
        case let .keychain(status):
            "The API key could not be stored securely (Keychain status \(status))."
        }
    }
}

enum BoundedHTTPBody {
    static func load(
        for request: URLRequest,
        using session: URLSession,
        maximumBytes: Int
    ) async throws -> (Data, URLResponse) {
        let (bytes, response) = try await session.bytes(for: request)
        try validateExpectedLength(response.expectedContentLength, maximumBytes: maximumBytes)

        var data = Data()
        if response.expectedContentLength > 0 {
            data.reserveCapacity(min(Int(response.expectedContentLength), maximumBytes))
        }
        for try await byte in bytes {
            try append(byte, to: &data, maximumBytes: maximumBytes)
        }
        return (data, response)
    }

    static func validateExpectedLength(_ length: Int64, maximumBytes: Int) throws {
        if length > Int64(maximumBytes) {
            throw TutorProviderError.responseTooLarge
        }
    }

    static func append(_ byte: UInt8, to data: inout Data, maximumBytes: Int) throws {
        guard data.count < maximumBytes else {
            throw TutorProviderError.responseTooLarge
        }
        data.append(byte)
    }
}

enum ConnectedTutorService {
    private static let maximumResponseBytes = 2_000_000

    private struct Message: Encodable {
        let role: String
        let content: String
    }

    private struct OpenAIRequest: Encodable {
        let model: String
        let messages: [Message]
        let maxCompletionTokens: Int

        enum CodingKeys: String, CodingKey {
            case model, messages
            case maxCompletionTokens = "max_completion_tokens"
        }
    }

    private struct CompatibleRequest: Encodable {
        let model: String
        let messages: [Message]
        let maxTokens: Int

        enum CodingKeys: String, CodingKey {
            case model, messages
            case maxTokens = "max_tokens"
        }
    }

    private struct OpenAIResponse: Decodable {
        struct Choice: Decodable {
            struct ResponseMessage: Decodable { let content: String? }
            let message: ResponseMessage
        }
        let choices: [Choice]
    }

    private struct AnthropicRequest: Encodable {
        let model: String
        let maxTokens: Int
        let system: String
        let messages: [Message]

        enum CodingKeys: String, CodingKey {
            case model, system, messages
            case maxTokens = "max_tokens"
        }
    }

    private struct AnthropicResponse: Decodable {
        struct ContentBlock: Decodable {
            let type: String
            let text: String?
        }
        let content: [ContentBlock]
    }

    private struct GeminiRequest: Encodable {
        struct Content: Encodable {
            struct Part: Encodable { let text: String }
            let role: String?
            let parts: [Part]
        }
        struct GenerationConfiguration: Encodable {
            let maxOutputTokens: Int
        }
        let systemInstruction: Content
        let contents: [Content]
        let generationConfig: GenerationConfiguration
    }

    private struct GeminiResponse: Decodable {
        struct Candidate: Decodable {
            struct Content: Decodable {
                struct Part: Decodable { let text: String? }
                let parts: [Part]
            }
            let content: Content?
        }
        let candidates: [Candidate]
    }

    static func answer(
        question: String,
        grounding: String,
        context: TutorContext,
        preferences: TutorPreferences,
        configuration: TutorProviderConfiguration,
        token: String,
        recentConversation: String
    ) async throws -> String {
        guard configuration.isConfigured else { throw TutorProviderError.notConfigured }

        let system = """
        You are Tutor Core inside Ai_Engineering: a principal AI engineer and patient teacher. \(preferences.learnerLevel.instruction) \(preferences.answerDepth.instruction) Ground the answer in the supplied curriculum. Define jargon, explain with intuition before mechanics, include a concrete example and failure modes, and end with a check-for-understanding question. Never imply that an external API, provider account, or separate LLM subscription is required for Tutor Core.
        """
        let user = """
        Context: \(context.displayTitle) — \(context.subtitle)

        Recent conversation:
        \(recentConversation.isEmpty ? "No earlier turns." : recentConversation)

        Bundled curriculum grounding:
        \(grounding)

        Learner question:
        \(question)
        """

        let request = try makeRequest(
            configuration: configuration,
            token: token,
            system: system,
            user: user,
            maxTokens: preferences.answerDepth == .deepDive ? 1_800 : 900
        )
        guard let initialURL = request.url else { throw TutorProviderError.invalidEndpoint }

        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.httpCookieAcceptPolicy = .never
        sessionConfiguration.httpShouldSetCookies = false
        sessionConfiguration.requestCachePolicy = .reloadIgnoringLocalCacheData
        sessionConfiguration.urlCache = nil
        let redirectDelegate = SameOriginRedirectDelegate(origin: TutorEndpointPolicy.origin(for: initialURL))
        let session = URLSession(configuration: sessionConfiguration, delegate: redirectDelegate, delegateQueue: nil)
        defer { session.finishTasksAndInvalidate() }

        let (data, response) = try await BoundedHTTPBody.load(
            for: request,
            using: session,
            maximumBytes: maximumResponseBytes
        )
        guard let http = response as? HTTPURLResponse else { throw TutorProviderError.invalidResponse }
        guard let finalURL = http.url,
              TutorEndpointPolicy.origin(for: finalURL) == TutorEndpointPolicy.origin(for: initialURL) else {
            throw TutorProviderError.invalidResponse
        }
        guard 200..<300 ~= http.statusCode else {
            let message = String(data: data, encoding: .utf8).map { String($0.prefix(500)) } ?? "Unknown error"
            throw TutorProviderError.server(http.statusCode, message)
        }
        return try decodeResponse(data, protocolFamily: configuration.protocolFamily)
    }

    static func makeRequest(
        configuration: TutorProviderConfiguration,
        token: String,
        system: String,
        user: String,
        maxTokens: Int
    ) throws -> URLRequest {
        guard configuration.isConfigured, configuration.endpointMatchesConnection else {
            throw TutorProviderError.notConfigured
        }
        let credential = token.trimmingCharacters(in: .whitespacesAndNewlines)
        if configuration.requiresCredential && credential.isEmpty {
            throw TutorProviderError.missingCredential
        }

        let url = try requestURL(for: configuration)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 90
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        switch configuration.protocolFamily {
        case .openAICompatible:
            if !credential.isEmpty {
                request.setValue("Bearer \(credential)", forHTTPHeaderField: "Authorization")
            }
            let instructionRole = configuration.connectionMode == .apiProvider && configuration.apiProvider == .openAI
                ? "developer"
                : "system"
            let messages = [Message(role: instructionRole, content: system), Message(role: "user", content: user)]
            if configuration.connectionMode == .apiProvider && configuration.apiProvider == .openAI {
                request.httpBody = try encoder.encode(OpenAIRequest(
                    model: configuration.model,
                    messages: messages,
                    maxCompletionTokens: maxTokens
                ))
            } else {
                request.httpBody = try encoder.encode(CompatibleRequest(
                    model: configuration.model,
                    messages: messages,
                    maxTokens: maxTokens
                ))
            }

        case .anthropicMessages:
            request.setValue(credential, forHTTPHeaderField: "x-api-key")
            request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
            request.httpBody = try encoder.encode(AnthropicRequest(
                model: configuration.model,
                maxTokens: maxTokens,
                system: system,
                messages: [Message(role: "user", content: user)]
            ))

        case .geminiGenerateContent:
            request.setValue(credential, forHTTPHeaderField: "x-goog-api-key")
            request.httpBody = try encoder.encode(GeminiRequest(
                systemInstruction: .init(role: nil, parts: [.init(text: system)]),
                contents: [.init(role: "user", parts: [.init(text: user)])],
                generationConfig: .init(maxOutputTokens: maxTokens)
            ))
        }
        return request
    }

    static func decodeResponse(_ data: Data, protocolFamily: TutorProviderProtocol) throws -> String {
        let content: String
        do {
            switch protocolFamily {
            case .openAICompatible:
                content = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                    .choices.first?.message.content ?? ""
            case .anthropicMessages:
                content = try JSONDecoder().decode(AnthropicResponse.self, from: data)
                    .content.filter { $0.type == "text" }.compactMap(\.text).joined(separator: "\n")
            case .geminiGenerateContent:
                content = try JSONDecoder().decode(GeminiResponse.self, from: data)
                    .candidates.first?.content?.parts.compactMap(\.text).joined(separator: "\n") ?? ""
            }
        } catch {
            throw TutorProviderError.invalidResponse
        }

        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw TutorProviderError.emptyResponse }
        return trimmed
    }

    private static func requestURL(for configuration: TutorProviderConfiguration) throws -> URL {
        let base = try TutorEndpointPolicy.validatedURL(configuration.endpoint)
        guard configuration.protocolFamily == .geminiGenerateContent else { return base }

        var model = configuration.model.trimmingCharacters(in: .whitespacesAndNewlines)
        if model.hasPrefix("models/") { model.removeFirst("models/".count) }
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~")
        guard !model.isEmpty,
              let encodedModel = model.addingPercentEncoding(withAllowedCharacters: allowed),
              let url = URL(string: base.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/")) + "/models/\(encodedModel):generateContent") else {
            throw TutorProviderError.invalidEndpoint
        }
        return try TutorEndpointPolicy.validatedURL(url.absoluteString)
    }
}

final class SameOriginRedirectDelegate: NSObject, URLSessionTaskDelegate, @unchecked Sendable {
    private let origin: String

    init(origin: String) {
        self.origin = origin
    }

    func allows(_ url: URL) -> Bool {
        TutorEndpointPolicy.origin(for: url) == origin
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        guard let target = request.url, allows(target) else {
            completionHandler(nil)
            return
        }
        completionHandler(request)
    }
}
