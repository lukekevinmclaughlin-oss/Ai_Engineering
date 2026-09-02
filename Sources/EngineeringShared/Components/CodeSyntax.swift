import Foundation
import SwiftUI

#if os(iOS)
import UIKit
public typealias AEPlatformColor = UIColor
public typealias AEPlatformFont = UIFont
#elseif os(macOS)
import AppKit
public typealias AEPlatformColor = NSColor
public typealias AEPlatformFont = NSFont
#endif

public enum CodeLanguage: String, CaseIterable, Sendable {
    case python
    case swift
    case json
    case shell
    case sql
    case yaml
    case markdown
    case generic

    public init(_ label: String?, fileName: String? = nil) {
        let normalized = label?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        switch normalized {
        case "py", "python", "python3": self = .python
        case "swift": self = .swift
        case "json", "jsonc": self = .json
        case "bash", "sh", "shell", "zsh", "terminal": self = .shell
        case "sql", "postgres", "postgresql", "sqlite": self = .sql
        case "yaml", "yml": self = .yaml
        case "markdown", "md", "mdown": self = .markdown
        default:
            switch (fileName as NSString?)?.pathExtension.lowercased() {
            case "py": self = .python
            case "swift": self = .swift
            case "json": self = .json
            case "sh", "bash", "zsh": self = .shell
            case "sql": self = .sql
            case "yaml", "yml": self = .yaml
            case "md", "markdown", "mdown": self = .markdown
            default: self = .generic
            }
        }
    }

    public var title: String {
        switch self {
        case .python: "Python"
        case .swift: "Swift"
        case .json: "JSON"
        case .shell: "Shell"
        case .sql: "SQL"
        case .yaml: "YAML"
        case .markdown: "Markdown"
        case .generic: "Code"
        }
    }

    public var systemImage: String {
        switch self {
        case .python: "chevron.left.forwardslash.chevron.right"
        case .swift: "swift"
        case .json: "curlybraces"
        case .shell: "terminal.fill"
        case .sql: "cylinder.split.1x2.fill"
        case .yaml: "list.bullet.indent"
        case .markdown: "text.alignleft"
        case .generic: "chevron.left.forwardslash.chevron.right"
        }
    }

    public var preferredFileName: String {
        switch self {
        case .python: "example.py"
        case .swift: "Example.swift"
        case .json: "example.json"
        case .shell: "example.sh"
        case .sql: "example.sql"
        case .yaml: "example.yaml"
        case .markdown: "README.md"
        case .generic: "example.txt"
        }
    }

    public static func inferred(from source: String, hint: String? = nil, fileName: String? = nil) -> CodeLanguage {
        let hinted = CodeLanguage(hint, fileName: fileName)
        if hinted != .generic { return hinted }

        let lowered = source.lowercased()
        if lowered.contains("import swiftui") || lowered.contains("func ") && lowered.contains("let ") {
            return .swift
        }
        if lowered.range(of: #"\b(select|insert|update|delete)\b[\s\S]*\b(from|into|set)\b"#, options: .regularExpression) != nil {
            return .sql
        }
        if lowered.hasPrefix("#!") || lowered.contains("#!/bin/") || lowered.contains("${") {
            return .shell
        }
        if let data = source.data(using: .utf8), (try? JSONSerialization.jsonObject(with: data)) != nil {
            return .json
        }
        if source.range(of: #"(?m)^#{1,6}\s+"#, options: .regularExpression) != nil
            || source.range(of: #"\[[^\]]+\]\([^)]+\)"#, options: .regularExpression) != nil {
            return .markdown
        }
        if source.range(of: #"(?m)^[A-Za-z_][A-Za-z0-9_.-]*\s*:\s*"#, options: .regularExpression) != nil {
            return .yaml
        }
        if lowered.contains("def ") || lowered.contains("from ") && lowered.contains(" import ") || lowered.contains("none") {
            return .python
        }
        return .generic
    }
}

public enum SyntaxTokenKind: String, CaseIterable, Sendable {
    case comment
    case string
    case number
    case keyword
    case type
    case function
    case key
    case constant
    case variable
    case `operator`
}

public struct SyntaxToken: Equatable, Sendable {
    public let location: Int
    public let length: Int
    public let kind: SyntaxTokenKind

    public var range: NSRange { NSRange(location: location, length: length) }


    public init(location: Int, length: Int, kind: SyntaxTokenKind) {
        self.location = location
        self.length = length
        self.kind = kind
    }
}

/// A compact lexer intended for instructional snippets and local workspaces.
/// A combined expression makes token precedence deterministic: a `#` inside a
/// quoted string is parsed as part of that string, while quotes after a comment
/// marker remain part of the comment.
public enum SyntaxHighlighter {
    public static func tokens(in source: String, language: CodeLanguage) -> [SyntaxToken] {
        guard !source.isEmpty,
              let expression = try? NSRegularExpression(pattern: pattern(for: language)) else {
            return []
        }

        let range = NSRange(source.startIndex..<source.endIndex, in: source)
        let matches = expression.matches(in: source, range: range)
        return matches.compactMap { match in
            for (kind, name) in captureGroups {
                let tokenRange = match.range(withName: name)
                if tokenRange.location != NSNotFound {
                    return SyntaxToken(location: tokenRange.location, length: tokenRange.length, kind: kind)
                }
            }
            return nil
        }
    }

    private static let captureGroups: [(SyntaxTokenKind, String)] = [
        (.comment, "comment"), (.key, "key"), (.string, "string"),
        (.number, "number"), (.keyword, "keyword"), (.type, "type"),
        (.constant, "constant"), (.variable, "variable"),
        (.function, "function"), (.operator, "operator")
    ]

    private static func pattern(for language: CodeLanguage) -> String {
        let quoted = #"\"(?:\\.|[^\"\\])*\"|'(?:\\.|[^'\\])*'"#
        let number = #"\b(?:0[xX][0-9A-Fa-f]+|\d+(?:\.\d+)?(?:[eE][+-]?\d+)?)\b"#
        let function = #"\b[A-Za-z_][A-Za-z0-9_]*(?=\s*\()"#
        let operators = #"(?:===|!==|==|!=|<=|>=|->|=>|&&|\|\||\?\?|\.\.|[+\-*\/%=<>!&|^~?:])"#

        func named(_ name: String, _ body: String) -> String { "(?<\(name)>\(body))" }
        func words(_ values: [String], insensitive: Bool = false) -> String {
            let body = #"\b(?:"# + values.joined(separator: "|") + #")\b"#
            return insensitive ? "(?i:\(body))" : body
        }

        let pieces: [String]
        switch language {
        case .python:
            pieces = [
                named("comment", #"(?m:#.*$)"#),
                named("string", #"(?:\"\"\"[\s\S]*?\"\"\"|'''[\s\S]*?'''|\"(?:\\.|[^\"\\])*\"|'(?:\\.|[^'\\])*')"#),
                named("number", number),
                named("keyword", words(["and", "as", "assert", "async", "await", "break", "case", "class", "continue", "def", "del", "elif", "else", "except", "finally", "for", "from", "global", "if", "import", "in", "is", "lambda", "match", "nonlocal", "not", "or", "pass", "raise", "return", "try", "while", "with", "yield"])),
                named("constant", words(["True", "False", "None", "Ellipsis", "NotImplemented"])),
                named("type", words(["str", "int", "float", "bool", "bytes", "list", "tuple", "dict", "set", "object"])),
                named("function", function),
                named("variable", #"@[A-Za-z_][A-Za-z0-9_]*"#),
                named("operator", operators)
            ]
        case .swift:
            pieces = [
                named("comment", #"(?:/\*[\s\S]*?\*/|(?m://.*$))"#),
                named("string", ##"(?:#*\"(?:\\.|[^\"\\])*\"#*)"##),
                named("number", number),
                named("keyword", words(["actor", "any", "as", "associatedtype", "async", "await", "break", "case", "catch", "class", "continue", "default", "defer", "deinit", "do", "else", "enum", "extension", "fallthrough", "fileprivate", "for", "func", "guard", "if", "import", "in", "indirect", "infix", "init", "inout", "internal", "is", "isolated", "let", "macro", "mutating", "nonisolated", "open", "operator", "override", "private", "protocol", "public", "repeat", "rethrows", "return", "self", "some", "static", "struct", "subscript", "super", "switch", "throw", "throws", "try", "typealias", "var", "where", "while"])),
                named("constant", words(["true", "false", "nil"])),
                named("type", #"\b[A-Z][A-Za-z0-9_]*\b"#),
                named("function", function),
                named("variable", #"@[A-Za-z_][A-Za-z0-9_]*"#),
                named("operator", operators)
            ]
        case .json:
            pieces = [
                named("key", #"\"(?:\\.|[^\"\\])*\"(?=\s*:)"#),
                named("string", #"\"(?:\\.|[^\"\\])*\""#),
                named("number", number),
                named("constant", words(["true", "false", "null"])),
                named("operator", #"[{}\[\],:]"#)
            ]
        case .shell:
            pieces = [
                named("comment", #"(?m:#.*$)"#),
                named("string", quoted),
                named("variable", #"\$(?:\{[A-Za-z_][A-Za-z0-9_]*\}|[A-Za-z_][A-Za-z0-9_]*)"#),
                named("number", number),
                named("keyword", words(["case", "do", "done", "elif", "else", "esac", "fi", "for", "function", "if", "in", "select", "then", "time", "until", "while"])),
                named("function", function),
                named("operator", operators)
            ]
        case .sql:
            pieces = [
                named("comment", #"(?:/\*[\s\S]*?\*/|(?m:--.*$))"#),
                named("string", quoted),
                named("number", number),
                named("keyword", words(["all", "alter", "and", "as", "asc", "between", "by", "case", "check", "column", "constraint", "create", "cross", "database", "default", "delete", "desc", "distinct", "drop", "else", "end", "exists", "from", "full", "group", "having", "in", "index", "inner", "insert", "into", "is", "join", "left", "like", "limit", "not", "null", "on", "or", "order", "outer", "primary", "references", "right", "select", "set", "table", "then", "union", "unique", "update", "values", "view", "when", "where", "with"], insensitive: true)),
                named("type", words(["bigint", "boolean", "date", "decimal", "float", "integer", "json", "numeric", "real", "serial", "text", "timestamp", "varchar"], insensitive: true)),
                named("function", function),
                named("operator", operators)
            ]
        case .yaml:
            pieces = [
                named("comment", #"(?m:#.*$)"#),
                named("string", quoted),
                named("key", #"\b[A-Za-z_][A-Za-z0-9_.-]*(?=\s*:)"#),
                named("number", number),
                named("constant", words(["true", "false", "null", "yes", "no", "on", "off"], insensitive: true)),
                named("variable", #"(?:&|\*)[A-Za-z_][A-Za-z0-9_-]*"#),
                named("operator", #"(?:---|\.\.\.|[-{}\[\],:|>])"#)
            ]
        case .markdown:
            pieces = [
                named("comment", #"<!--[\s\S]*?-->"#),
                named("string", #"(?:```[\s\S]*?```|`[^`\n]+`)"#),
                named("function", #"(?:!\[[^\]\n]*\]\([^)]+\)|\[[^\]\n]+\]\([^)]+\))"#),
                named("keyword", #"(?m:^(?:#{1,6})(?=\s)|^\s*(?:[-+*]|\d+\.)\s)"#),
                named("number", number),
                named("operator", #"(?:\*\*|__|~~|[*_>|])"#)
            ]
        case .generic:
            pieces = [
                named("comment", #"(?:/\*[\s\S]*?\*/|(?m://.*$|#.*$))"#),
                named("string", quoted),
                named("number", number),
                named("keyword", words(["async", "await", "break", "case", "catch", "class", "const", "continue", "default", "else", "enum", "export", "extends", "for", "from", "function", "if", "import", "in", "interface", "let", "new", "return", "static", "struct", "switch", "throw", "try", "type", "var", "while"])),
                named("constant", words(["true", "false", "null", "nil", "undefined"])),
                named("type", #"\b[A-Z][A-Za-z0-9_]*\b"#),
                named("function", function),
                named("operator", operators)
            ]
        }
        return pieces.joined(separator: "|")
    }
}

public struct SyntaxRGB {
    public let red: Double
    public let green: Double
    public let blue: Double

    public var color: Color { Color(red: red, green: green, blue: blue) }

    public var platformColor: AEPlatformColor {
        #if os(iOS)
        UIColor(red: red, green: green, blue: blue, alpha: 1)
        #else
        NSColor(srgbRed: red, green: green, blue: blue, alpha: 1)
        #endif
    }


    public init(red: Double, green: Double, blue: Double) {
        self.red = red
        self.green = green
        self.blue = blue
    }
}

public struct SyntaxPalette {
    public let background: SyntaxRGB
    public let toolbar: SyntaxRGB
    public let gutter: SyntaxRGB
    public let base: SyntaxRGB
    public let muted: SyntaxRGB
    public let comment: SyntaxRGB
    public let string: SyntaxRGB
    public let number: SyntaxRGB
    public let keyword: SyntaxRGB
    public let type: SyntaxRGB
    public let function: SyntaxRGB
    public let key: SyntaxRGB
    public let constant: SyntaxRGB
    public let variable: SyntaxRGB
    public let `operator`: SyntaxRGB

    public init(scheme: ColorScheme) {
        if scheme == .dark {
            background = .init(red: 0.026, green: 0.038, blue: 0.074)
            toolbar = .init(red: 0.045, green: 0.061, blue: 0.108)
            gutter = .init(red: 0.055, green: 0.070, blue: 0.118)
            base = .init(red: 0.855, green: 0.902, blue: 1.000)
            muted = .init(red: 0.435, green: 0.490, blue: 0.605)
            comment = .init(red: 0.415, green: 0.500, blue: 0.615)
            string = .init(red: 0.625, green: 0.910, blue: 0.630)
            number = .init(red: 0.985, green: 0.655, blue: 0.520)
            keyword = .init(red: 0.790, green: 0.625, blue: 1.000)
            type = .init(red: 0.530, green: 0.880, blue: 0.925)
            function = .init(red: 0.420, green: 0.765, blue: 0.970)
            key = .init(red: 0.970, green: 0.835, blue: 0.570)
            constant = .init(red: 0.975, green: 0.535, blue: 0.665)
            variable = .init(red: 0.565, green: 0.905, blue: 0.835)
            `operator` = .init(red: 0.585, green: 0.895, blue: 0.835)
        } else {
            background = .init(red: 0.965, green: 0.976, blue: 0.998)
            toolbar = .init(red: 0.925, green: 0.945, blue: 0.980)
            gutter = .init(red: 0.900, green: 0.925, blue: 0.970)
            base = .init(red: 0.075, green: 0.115, blue: 0.205)
            muted = .init(red: 0.400, green: 0.450, blue: 0.550)
            comment = .init(red: 0.350, green: 0.410, blue: 0.500)
            string = .init(red: 0.090, green: 0.500, blue: 0.235)
            number = .init(red: 0.735, green: 0.260, blue: 0.110)
            keyword = .init(red: 0.405, green: 0.220, blue: 0.730)
            type = .init(red: 0.000, green: 0.425, blue: 0.560)
            function = .init(red: 0.000, green: 0.365, blue: 0.710)
            key = .init(red: 0.590, green: 0.350, blue: 0.000)
            constant = .init(red: 0.705, green: 0.095, blue: 0.300)
            variable = .init(red: 0.000, green: 0.455, blue: 0.390)
            `operator` = .init(red: 0.000, green: 0.435, blue: 0.390)
        }
    }

    public func color(for kind: SyntaxTokenKind) -> SyntaxRGB {
        switch kind {
        case .comment: comment
        case .string: string
        case .number: number
        case .keyword: keyword
        case .type: type
        case .function: function
        case .key: key
        case .constant: constant
        case .variable: variable
        case .operator: `operator`
        }
    }
}

public extension SyntaxHighlighter {
    public static func attributedText(
        _ source: String,
        language: CodeLanguage,
        scheme: ColorScheme,
        fontSize: CGFloat
    ) -> NSAttributedString {
        let palette = SyntaxPalette(scheme: scheme)
        let font: AEPlatformFont
        #if os(iOS)
        font = .monospacedSystemFont(ofSize: fontSize, weight: .regular)
        #else
        font = .monospacedSystemFont(ofSize: fontSize, weight: .regular)
        #endif

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 4
        paragraph.defaultTabInterval = fontSize * 4
        let attributed = NSMutableAttributedString(
            string: source,
            attributes: [
                .font: font,
                .foregroundColor: palette.base.platformColor,
                .paragraphStyle: paragraph
            ]
        )
        for token in tokens(in: source, language: language) {
            attributed.addAttribute(.foregroundColor, value: palette.color(for: token.kind).platformColor, range: token.range)
            if token.kind == .keyword || token.kind == .key {
                #if os(iOS)
                let emphasized = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .semibold)
                #else
                let emphasized = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .semibold)
                #endif
                attributed.addAttribute(.font, value: emphasized, range: token.range)
            }
        }
        return attributed
    }
}

public enum CodeFontMetrics {
    public static func size(for dynamicTypeSize: DynamicTypeSize) -> CGFloat {
        switch dynamicTypeSize {
        case .xSmall: 12
        case .small: 12.5
        case .medium: 13
        case .large: 14
        case .xLarge: 15
        case .xxLarge: 16
        case .xxxLarge: 17.5
        case .accessibility1: 19
        case .accessibility2: 21
        case .accessibility3: 23
        case .accessibility4: 25
        case .accessibility5: 27
        @unknown default: 14
        }
    }
}
