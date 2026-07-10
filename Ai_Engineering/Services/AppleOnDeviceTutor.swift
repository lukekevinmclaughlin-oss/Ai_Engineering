import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

protocol AppleTutorRuntime: Sendable {
    func answer(
        question: String,
        grounding: String,
        context: TutorContext,
        preferences: TutorPreferences
    ) async throws -> String
}

enum AppleOnDeviceTutor {
    static var availability: AppleTutorAvailability {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, macOS 26.0, *) {
            switch SystemLanguageModel.default.availability {
            case .available:
                return .available
            case .unavailable(.deviceNotEligible):
                return .deviceNotEligible
            case .unavailable(.appleIntelligenceNotEnabled):
                return .intelligenceDisabled
            case .unavailable(.modelNotReady):
                return .modelPreparing
            @unknown default:
                return .modelPreparing
            }
        }
        #endif
        return .unsupportedOS
    }

    static func makeRuntime() -> (any AppleTutorRuntime)? {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, macOS 26.0, *), availability.isAvailable {
            return AppleFoundationTutorRuntime()
        }
        #endif
        return nil
    }
}

#if canImport(FoundationModels)
@available(iOS 26.0, macOS 26.0, *)
actor AppleFoundationTutorRuntime: AppleTutorRuntime {
    private let session: LanguageModelSession

    init() {
        session = LanguageModelSession(instructions: """
        You are Tutor Core, a principal AI engineer and exceptionally patient teacher inside Ai_Engineering.

        Your scope is AI engineering and the computing, Python, data, mathematics, product, and systems knowledge needed to learn it. Teach accurately and practically. Define jargon before using it. Start with intuition, then a concrete example, then the technical mechanism. When the learner is new, assume only basic arithmetic and never shame them for missing prerequisites. For experienced learners, include implementation details, trade-offs, failure modes, and operational concerns.

        Treat the supplied COURSE MATERIAL as trusted grounding. Do not claim that it contains something it does not. You may use established general knowledge to connect and explain the material, but clearly distinguish facts, heuristics, and design choices. Never fabricate citations, benchmarks, APIs, or lesson content. If a question is ambiguous, state your interpretation. If it falls outside the learning scope, briefly redirect it toward a relevant AI-engineering concept.

        Check every analogy against the actual mechanism and state where the analogy stops. In particular, identifiers merely name items; embeddings are learned numeric coordinates that represent useful patterns or meaning.

        Prefer this teaching shape unless the user requests another format:
        1. Short answer
        2. Mental model or analogy
        3. Step-by-step mechanism
        4. Concrete example
        5. Engineering trade-offs and common failure modes
        6. One small check-for-understanding question

        Never request an API key or subscription. The app is offline-first. A connected provider is optional and must never be presented as required.
        """)
        session.prewarm()
    }

    func answer(
        question: String,
        grounding: String,
        context: TutorContext,
        preferences: TutorPreferences
    ) async throws -> String {
        let prompt = """
        LEARNER MODE:
        \(preferences.learnerLevel.instruction)
        \(preferences.answerDepth.instruction)

        CURRENT CONTEXT:
        \(context.displayTitle) — \(context.subtitle)

        COURSE MATERIAL:
        \(grounding)

        LEARNER QUESTION:
        \(question)

        Answer as Tutor Core. Use Markdown headings sparingly and end with one useful check-for-understanding question.
        """

        let response = try await session.respond(to: prompt)
        return response.content
    }
}
#endif
