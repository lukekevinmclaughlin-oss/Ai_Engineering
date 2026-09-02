import Foundation

public struct TutorLocalServerDetection: Identifiable, Equatable, Sendable {
    public let server: TutorLocalServer
    public let endpoint: String
    public let models: [String]

    public var id: String { server.id }


    init(server: TutorLocalServer, endpoint: String, models: [String]) {
        self.server = server
        self.endpoint = endpoint
        self.models = models
    }
}

public enum LocalTutorServerDiscoveryError: LocalizedError {
    case unavailable(TutorLocalServer)
    case invalidResponse(TutorLocalServer)
    case noModels(TutorLocalServer)

    public var errorDescription: String? {
        switch self {
        case let .unavailable(server):
            "\(server.title) was not found on this device. Make sure its local server is running."
        case let .invalidResponse(server):
            "\(server.title) answered, but its model list could not be read."
        case let .noModels(server):
            "\(server.title) is running, but it has no loaded or installed models."
        }
    }
}

public enum LocalTutorServerDiscovery {
    private static let maximumResponseBytes = 1_000_000

    private struct OllamaResponse: Decodable {
        struct Model: Decodable {
            let name: String?
            let model: String?
        }
        let models: [Model]
    }

    private struct OpenAIModelResponse: Decodable {
        struct Model: Decodable { let id: String }
        let data: [Model]
    }

    public static func detect(_ server: TutorLocalServer) async throws -> TutorLocalServerDetection {
        guard let url = URL(string: server.discoveryEndpoint) else {
            throw LocalTutorServerDiscoveryError.invalidResponse(server)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 1.25
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 1.25
        configuration.timeoutIntervalForResource = 2
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil
        configuration.httpCookieAcceptPolicy = .never
        configuration.httpShouldSetCookies = false
        let redirectDelegate = SameOriginRedirectDelegate(origin: TutorEndpointPolicy.origin(for: url))
        let session = URLSession(configuration: configuration, delegate: redirectDelegate, delegateQueue: nil)
        defer { session.finishTasksAndInvalidate() }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await BoundedHTTPBody.load(
                for: request,
                using: session,
                maximumBytes: maximumResponseBytes
            )
        } catch is CancellationError {
            throw CancellationError()
        } catch TutorProviderError.responseTooLarge {
            throw LocalTutorServerDiscoveryError.invalidResponse(server)
        } catch {
            throw LocalTutorServerDiscoveryError.unavailable(server)
        }

        guard let http = response as? HTTPURLResponse,
              200..<300 ~= http.statusCode,
              let finalURL = http.url,
              TutorEndpointPolicy.origin(for: finalURL) == TutorEndpointPolicy.origin(for: url) else {
            throw LocalTutorServerDiscoveryError.invalidResponse(server)
        }

        let models = try parseModels(data, for: server)
        guard !models.isEmpty else { throw LocalTutorServerDiscoveryError.noModels(server) }
        return TutorLocalServerDetection(server: server, endpoint: server.chatEndpoint, models: models)
    }

    public static func parseModels(_ data: Data, for server: TutorLocalServer) throws -> [String] {
        let models: [String]
        do {
            switch server {
            case .ollama:
                let response = try JSONDecoder().decode(OllamaResponse.self, from: data)
                models = response.models.compactMap { model in
                    let candidate = model.name ?? model.model
                    return candidate?.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            case .lmStudio:
                let response = try JSONDecoder().decode(OpenAIModelResponse.self, from: data)
                models = response.data.map { $0.id.trimmingCharacters(in: .whitespacesAndNewlines) }
            }
        } catch {
            throw LocalTutorServerDiscoveryError.invalidResponse(server)
        }

        return Array(Set(models.filter { !$0.isEmpty })).sorted()
    }
}
