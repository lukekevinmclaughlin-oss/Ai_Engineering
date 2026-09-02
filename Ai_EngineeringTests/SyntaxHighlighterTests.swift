import EngineeringShared
import XCTest
@testable import Ai_Engineering

final class SyntaxHighlighterTests: XCTestCase {
    func testPythonStringOwnsCommentMarkerAndCommentOwnsQuotes() {
        let source = "message = \"not # a comment\"\n# a \"real\" comment\ndef greet(name):\n    return name"
        let tokens = SyntaxHighlighter.tokens(in: source, language: .python)

        XCTAssertTrue(lexemes(of: .string, in: source, tokens: tokens).contains("\"not # a comment\""))
        XCTAssertEqual(lexemes(of: .comment, in: source, tokens: tokens), ["# a \"real\" comment"])
        XCTAssertTrue(lexemes(of: .keyword, in: source, tokens: tokens).contains("def"))
        XCTAssertTrue(lexemes(of: .keyword, in: source, tokens: tokens).contains("return"))
    }

    func testSwiftRecognizesKeywordsTypesAndFunctions() {
        let source = "struct Tutor { let count: Int\nfunc run() -> Bool { return true } }"
        let tokens = SyntaxHighlighter.tokens(in: source, language: .swift)
        let keywords = Set(lexemes(of: .keyword, in: source, tokens: tokens))
        let types = Set(lexemes(of: .type, in: source, tokens: tokens))

        XCTAssertTrue(["struct", "let", "func", "return"].allSatisfy(keywords.contains))
        XCTAssertTrue(["Tutor", "Int", "Bool"].allSatisfy(types.contains))
        XCTAssertTrue(lexemes(of: .function, in: source, tokens: tokens).contains("run"))
    }

    func testJSONSeparatesObjectKeysFromStringValues() {
        let source = #"{"model":"small","enabled":true,"retries":3}"#
        let tokens = SyntaxHighlighter.tokens(in: source, language: .json)

        XCTAssertEqual(Set(lexemes(of: .key, in: source, tokens: tokens)), ["\"model\"", "\"enabled\"", "\"retries\""])
        XCTAssertEqual(lexemes(of: .string, in: source, tokens: tokens), ["\"small\""])
        XCTAssertTrue(lexemes(of: .constant, in: source, tokens: tokens).contains("true"))
    }

    func testSQLKeywordsAreCaseInsensitive() {
        let source = "select model_id, COUNT(*) FROM runs where score >= 0.8 GROUP by model_id"
        let tokens = SyntaxHighlighter.tokens(in: source, language: .sql)
        let keywords = Set(lexemes(of: .keyword, in: source, tokens: tokens).map { $0.lowercased() })

        XCTAssertTrue(["select", "from", "where", "group", "by"].allSatisfy(keywords.contains))
        XCTAssertTrue(lexemes(of: .function, in: source, tokens: tokens).contains("COUNT"))
    }

    func testShellVariablesAreDistinctTokens() {
        let source = "MODEL=local-ai\necho $MODEL\necho ${MODEL}"
        let tokens = SyntaxHighlighter.tokens(in: source, language: .shell)

        XCTAssertEqual(Set(lexemes(of: .variable, in: source, tokens: tokens)), ["$MODEL", "${MODEL}"])
    }

    func testLanguageAliasesFileNamesAndSourceInference() {
        XCTAssertEqual(CodeLanguage("py"), .python)
        XCTAssertEqual(CodeLanguage(nil, fileName: "query.sql"), .sql)
        XCTAssertEqual(CodeLanguage.inferred(from: "import SwiftUI\nstruct Lab: View {}"), .swift)
        XCTAssertEqual(CodeLanguage.inferred(from: "SELECT id FROM models"), .sql)
        XCTAssertEqual(CodeLanguage.inferred(from: "{\"ready\": true}"), .json)
        XCTAssertEqual(CodeLanguage.inferred(from: "#!/bin/zsh\necho ready"), .shell)
        XCTAssertEqual(CodeLanguage.inferred(from: "def train():\n    return None"), .python)
        XCTAssertEqual(CodeLanguage("yml"), .yaml)
        XCTAssertEqual(CodeLanguage(nil, fileName: "service.yaml"), .yaml)
        XCTAssertEqual(CodeLanguage("md"), .markdown)
        XCTAssertEqual(CodeLanguage(nil, fileName: "README.md"), .markdown)
        XCTAssertEqual(CodeLanguage.inferred(from: "# Runbook\nSee [the guide](https://example.com)."), .markdown)
        XCTAssertEqual(CodeLanguage.inferred(from: "model: local\nretries: 3"), .yaml)
    }

    func testYAMLRecognizesKeysCommentsAndAnchors() {
        let source = "defaults: &defaults\n  retries: 3\nmodel: local # private model\ncopy: *defaults"
        let tokens = SyntaxHighlighter.tokens(in: source, language: .yaml)

        XCTAssertTrue(["defaults", "retries", "model", "copy"].allSatisfy(
            Set(lexemes(of: .key, in: source, tokens: tokens)).contains
        ))
        XCTAssertEqual(lexemes(of: .comment, in: source, tokens: tokens), ["# private model"])
        XCTAssertEqual(Set(lexemes(of: .variable, in: source, tokens: tokens)), ["&defaults", "*defaults"])
    }

    func testMarkdownRecognizesHeadingsLinksAndInlineCode() {
        let source = "# Build notes\nUse `ollama serve`, then read [the guide](https://example.com)."
        let tokens = SyntaxHighlighter.tokens(in: source, language: .markdown)

        XCTAssertTrue(lexemes(of: .keyword, in: source, tokens: tokens).contains("#"))
        XCTAssertEqual(lexemes(of: .string, in: source, tokens: tokens), ["`ollama serve`"])
        XCTAssertEqual(lexemes(of: .function, in: source, tokens: tokens), ["[the guide](https://example.com)"])
    }

    private func lexemes(
        of kind: SyntaxTokenKind,
        in source: String,
        tokens: [SyntaxToken]
    ) -> [String] {
        let source = source as NSString
        return tokens
            .filter { $0.kind == kind }
            .map { source.substring(with: $0.range) }
    }
}
