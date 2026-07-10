import Foundation

struct TutorKnowledgeBase: Sendable {
    let documents: [TutorKnowledgeDocument]

    init(curriculum: Curriculum, projects: [LabProject]) {
        var built: [TutorKnowledgeDocument] = []

        for course in curriculum.courses {
            for module in course.modules {
                for lesson in module.lessons {
                    let blockText = lesson.contentBlocks.map { block in
                        ([block.text] + (block.items ?? [])).joined(separator: "\n")
                    }
                    let challengeText = [
                        lesson.challenge?.prompt,
                        lesson.challenge?.instructions,
                        lesson.challenge?.explanation
                    ]
                    .compactMap { $0 }

                    built.append(
                        TutorKnowledgeDocument(
                            id: lesson.id,
                            kind: .lesson,
                            title: lesson.title,
                            location: "\(course.title) · \(module.title)",
                            summary: lesson.summary,
                            body: (blockText + challengeText).joined(separator: "\n\n"),
                            keywords: course.skills + [course.title, module.title, lesson.kind.title]
                        )
                    )
                }
            }
        }

        for project in projects {
            built.append(
                TutorKnowledgeDocument(
                    id: project.id,
                    kind: .project,
                    title: project.title,
                    location: "Portfolio project · \(project.difficulty)",
                    summary: project.summary,
                    body: ([project.brief] + project.outcomes + project.milestones.map(\.detail)).joined(separator: "\n\n"),
                    keywords: project.skills + [project.subtitle, project.difficulty]
                )
            )
        }

        documents = built
    }

    func rankedDocuments(
        for question: String,
        context: TutorContext,
        limit: Int = 5
    ) -> [TutorKnowledgeDocument] {
        let queryTokens = expandedTokens(in: question)

        var ranked: [(document: TutorKnowledgeDocument, score: Double)] = []
        for document in documents {
            let value = score(
                document: document,
                queryTokens: queryTokens,
                context: context
            )
            ranked.append((document: document, score: value))
        }
        ranked.sort { lhs, rhs in
            lhs.score == rhs.score ? lhs.document.title < rhs.document.title : lhs.score > rhs.score
        }

        let matches = ranked
            .filter { $0.score >= 3 }
            .prefix(limit)
            .map { $0.document }
        if !matches.isEmpty { return matches }

        if let contextDocument = documents.first(where: { $0.id == context.lessonID || $0.id == context.projectID }) {
            return [contextDocument]
        }
        return []
    }

    func groundingPacket(
        for question: String,
        context: TutorContext,
        limit: Int = 5
    ) -> (text: String, sources: [TutorSource]) {
        let matches = rankedDocuments(for: question, context: context, limit: limit)
        let text = matches.enumerated().map { index, document in
            let body = String(document.body.prefix(2_800))
            return """
            SOURCE \(index + 1): \(document.title)
            LOCATION: \(document.location)
            SUMMARY: \(document.summary)
            MATERIAL:
            \(body)
            """
        }
        .joined(separator: "\n\n---\n\n")

        return (text, matches.map(\.source))
    }

    func offlineAnswer(
        to question: String,
        context: TutorContext,
        preferences: TutorPreferences
    ) -> TutorAnswer {
        let matches = rankedDocuments(for: question, context: context, limit: preferences.answerDepth == .deepDive ? 5 : 3)
        guard let primary = matches.first else {
            return TutorAnswer(
                content: """
                **I need one more anchor before I answer.**

                I could not match that question confidently to the bundled AI-engineering material, and I do not want to invent a connection. Tell me the concept, error message, system component, or lesson you are working on. For example: “Why does a RAG system need embeddings?” or “Explain gradient descent from basic arithmetic.”

                *Your question stayed entirely on this device.*
                """,
                engineName: "Offline Core",
                sources: []
            )
        }

        let primaryIdeas = usefulParagraphs(from: primary)
        let secondary = matches.dropFirst().prefix(preferences.answerDepth == .deepDive ? 3 : 1)
        let noviceOpening = preferences.learnerLevel == .firstSteps
            ? "You do not need advanced maths for this explanation. We will build it from one small idea at a time."
            : "Let’s anchor the answer in the course material, then connect it to engineering practice."

        var sections: [String] = [
            "**Short answer**\n\n\(primary.summary)",
            "**Build the mental model**\n\n\(noviceOpening) \(primaryIdeas.first ?? primary.summary)",
            "**A useful analogy**\n\n\(analogy(for: primary))"
        ]

        if preferences.answerDepth == .deepDive {
            let steps = ([primary] + secondary).enumerated().map { index, document in
                "\(index + 1). **\(document.title):** \(document.summary)"
            }
            sections.append("**How the pieces fit together**\n\n\(steps.joined(separator: "\n"))")

            if primaryIdeas.count > 1 {
                sections.append("**Under the hood**\n\n\(primaryIdeas.dropFirst().prefix(2).joined(separator: "\n\n"))")
            }

            sections.append("**Engineering lens**\n\n\(engineeringLens(for: primary, related: Array(secondary)))")
        }

        sections.append("**Try it now**\n\n\(practicePrompt(for: primary))")
        sections.append("**Check your understanding**\n\nExplain the idea back in one sentence, then name one input, one output, and one way it could fail. If you send me your answer, I’ll coach it step by step.")

        let note = "\n\n*Offline Core answered from bundled course material. On a supported Apple Intelligence device, Automatic mode adds fully on-device generative reasoning. Connecting another provider is always optional.*"
        return TutorAnswer(
            content: sections.joined(separator: "\n\n") + note,
            engineName: "Offline Core",
            sources: matches.map(\.source)
        )
    }

    private func usefulParagraphs(from document: TutorKnowledgeDocument) -> [String] {
        document.body
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.count > 55 && !$0.contains("NotImplementedError") }
            .prefix(5)
            .map { String($0.prefix(720)) }
    }

    private func score(
        document: TutorKnowledgeDocument,
        queryTokens: Set<String>,
        context: TutorContext
    ) -> Double {
        let titleTokens = Set(tokenize(document.title))
        let summaryTokens = Set(tokenize(document.summary))
        let bodyTokens = Set(tokenize(document.body))
        let keywordTokens = Set(tokenize(document.keywords.joined(separator: " ")))
        var value = 0.0

        for token in queryTokens {
            if titleTokens.contains(token) { value += 7 }
            if keywordTokens.contains(token) { value += 5 }
            if summaryTokens.contains(token) { value += 3 }
            if bodyTokens.contains(token) { value += 1 }
        }

        if document.id == context.lessonID || document.id == context.projectID { value += 80 }
        if let course = context.courseTitle, document.location.contains(course) { value += 15 }
        return value
    }

    private func analogy(for document: TutorKnowledgeDocument) -> String {
        let text = normalize([document.title, document.summary, document.keywords.joined(separator: " ")].joined(separator: " "))
        let analogies: [(keys: [String], text: String)] = [
            (["retrieval", "rag"], "Think of a closed-book exam versus an open-book exam. The language model is the student; retrieval finds the right pages before the student answers."),
            (["embedding", "vector", "semantic search"], "Imagine placing ideas on a giant map. Ideas with similar meanings get nearby coordinates, even when they use different words."),
            (["agent", "tool"], "An agent is like a careful apprentice: it can reason about the next step, but each real-world action should use a named tool with clear permissions."),
            (["evaluation", "eval", "quality"], "Evals are crash tests for AI behavior. A single pleasant demo is one drive around the block; an eval suite repeats difficult scenarios before every release."),
            (["neural", "training", "gradient"], "Training is like adjusting many tiny volume knobs. Each example tells us whether the output got better or worse, and the knobs move a little in the helpful direction."),
            (["token", "language model", "transformer"], "A language model is an extremely practiced next-piece predictor. It reads text as small pieces called tokens and repeatedly estimates what piece should follow."),
            (["api", "request", "response"], "An API works like a restaurant order slip: it defines exactly what you may request, how to write the request, and what shape of response comes back."),
            (["latency", "serving", "inference"], "Serving a model is like running a busy kitchen: batching improves throughput, but waiting too long to form a batch makes each customer feel slower."),
            (["security", "guardrail", "prompt injection"], "Treat model text like an untrusted email, not a command from your boss. Permissions and validation belong in code around the model."),
            (["data", "dataset"], "A dataset is the model’s practice workbook. If the workbook is biased, mislabeled, or unlike the final exam, practice can make the wrong behavior stronger.")
        ]

        return analogies.first(where: { entry in entry.keys.contains(where: text.contains) })?.text
            ?? "Think of an AI system as a workshop: the model is one powerful tool, while data, validation, interfaces, monitoring, and human decisions make the whole workshop dependable."
    }

    private func engineeringLens(
        for primary: TutorKnowledgeDocument,
        related: [TutorKnowledgeDocument]
    ) -> String {
        let relatedTitles = related.map(\.title)
        let connections = relatedTitles.isEmpty ? "the surrounding system" : relatedTitles.joined(separator: ", ")
        return "Do not judge **\(primary.title)** only by whether one example works. Define the desired behavior, test normal and hostile inputs, make uncertainty visible, and measure quality together with latency and cost. In production, connect it to \(connections), then decide what must be deterministic, what the model may choose, and when a human must take over."
    }

    private func practicePrompt(for document: TutorKnowledgeDocument) -> String {
        let sentences = document.body.components(separatedBy: "\n").filter { $0.count > 35 }
        if let challenge = sentences.last {
            return String(challenge.prefix(520))
        }
        return "Draw the flow as boxes and arrows. Label where data enters, where a model makes a probabilistic decision, where code validates it, and what happens when confidence is low."
    }

    private func expandedTokens(in text: String) -> Set<String> {
        var tokens = Set(tokenize(text))
        let synonyms: [String: [String]] = [
            "rag": ["retrieval", "grounding", "vector", "citation"],
            "llm": ["language", "model", "transformer", "token"],
            "hallucination": ["grounding", "evaluation", "factual", "retrieval"],
            "fast": ["latency", "inference", "caching", "serving"],
            "cheap": ["cost", "token", "caching", "routing"],
            "safe": ["safety", "guardrail", "security", "approval"],
            "chatbot": ["conversation", "assistant", "prompt", "language"],
            "database": ["data", "storage", "vector", "retrieval"],
            "math": ["probability", "vector", "gradient", "matrix"]
        ]

        for token in Array(tokens) {
            synonyms[token, default: []].forEach { tokens.insert($0) }
        }
        return tokens
    }

    private func tokenize(_ text: String) -> [String] {
        let stopWords: Set<String> = [
            "a", "an", "and", "are", "as", "at", "be", "can", "do", "does", "for", "from",
            "how", "i", "in", "is", "it", "me", "my", "of", "on", "or", "that", "the", "this",
            "to", "what", "when", "where", "which", "why", "with", "would", "you"
        ]
        return normalize(text)
            .split { !$0.isLetter && !$0.isNumber }
            .map(String.init)
            .filter { $0.count > 1 && !stopWords.contains($0) }
    }

    private func normalize(_ text: String) -> String {
        text.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()
    }
}
