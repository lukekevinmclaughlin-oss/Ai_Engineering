import Foundation

public enum TutorEndpointPolicyError: LocalizedError, Equatable {
    case invalidEndpoint
    case insecureEndpoint

    public var errorDescription: String? {
        switch self {
        case .invalidEndpoint:
            "Enter a full, valid provider endpoint URL."
        case .insecureEndpoint:
            "Hosted providers require HTTPS. Plain HTTP is allowed only for localhost model servers."
        }
    }
}

public enum TutorEndpointPolicy {
    public static func validatedURL(_ rawValue: String) throws -> URL {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let components = URLComponents(string: trimmed),
              let scheme = components.scheme?.lowercased(),
              let host = components.host?.lowercased(),
              !host.isEmpty,
              components.user == nil,
              components.password == nil,
              let url = components.url else {
            throw TutorEndpointPolicyError.invalidEndpoint
        }

        let localHosts = ["localhost", "127.0.0.1", "::1"]
        guard scheme == "https" || (scheme == "http" && localHosts.contains(host)) else {
            throw TutorEndpointPolicyError.insecureEndpoint
        }
        return url
    }

    public static func origin(for url: URL) -> String {
        let scheme = url.scheme?.lowercased() ?? ""
        let host = url.host?.lowercased() ?? ""
        let port = url.port.map { ":\($0)" } ?? ""
        return "\(scheme)://\(host)\(port)"
    }
}

public enum BoundedHTTPBodyError: Error {
    case responseTooLarge
}

public enum BoundedHTTPBody {
    public static func load(
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
            guard data.count < maximumBytes else {
                throw BoundedHTTPBodyError.responseTooLarge
            }
            data.append(byte)
        }
        return (data, response)
    }

    private static func validateExpectedLength(_ length: Int64, maximumBytes: Int) throws {
        if length > Int64(maximumBytes) {
            throw BoundedHTTPBodyError.responseTooLarge
        }
    }
}

public final class SameOriginRedirectDelegate: NSObject, URLSessionTaskDelegate, @unchecked Sendable {
    private let origin: String

    public init(origin: String) {
        self.origin = origin
    }

    public func allows(_ url: URL) -> Bool {
        TutorEndpointPolicy.origin(for: url) == origin
    }

    public func urlSession(
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
