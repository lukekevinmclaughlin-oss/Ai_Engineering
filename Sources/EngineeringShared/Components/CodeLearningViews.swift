import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public struct AESyntaxCodeBlock: View {
    public let code: String
    public let language: CodeLanguage
    public var title: String? = nil
    public var accent: Color = AEColor.azure
    public var labelAccent: Color? = nil
    public var showsCopyButton = true

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var didCopy = false

    private var palette: SyntaxPalette { SyntaxPalette(scheme: colorScheme) }
    private var lineCount: Int { max(code.components(separatedBy: .newlines).count, 1) }
    private var fontSize: CGFloat { CodeFontMetrics.size(for: dynamicTypeSize) }
    private var viewportHeight: CGFloat {
        min(max(CGFloat(lineCount) * (fontSize + 7) + 28, 86), 380)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            codeToolbar

            ScrollView([.horizontal, .vertical]) {
                HStack(alignment: .top, spacing: 0) {
                    Text(lineNumbers)
                        .font(.system(size: fontSize, weight: .regular, design: .monospaced))
                        .lineSpacing(4)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(palette.muted.color)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 14)
                        .frame(minWidth: 44, alignment: .trailing)
                        .background(palette.gutter.color)
                        .accessibilityHidden(true)

                    Divider()
                        .overlay(palette.muted.color.opacity(0.18))

                    Text(highlightedCode)
                        .textSelection(.enabled)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .fixedSize(horizontal: true, vertical: true)
                }
                .frame(minHeight: viewportHeight, alignment: .top)
            }
            .frame(height: viewportHeight)
            .background(palette.background.color)
        }
        .clipShape(RoundedRectangle(cornerRadius: AERadius.medium, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AERadius.medium, style: .continuous)
                .stroke(AEColor.stroke(colorScheme), lineWidth: 1)
        }
        .shadow(color: AEColor.shadow(colorScheme).opacity(0.35), radius: 16, y: 8)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(language.title) code sample")
    }

    private var codeToolbar: some View {
        HStack(spacing: 10) {
            HStack(spacing: 6) {
                Circle().fill(AEColor.coral.opacity(0.9)).frame(width: 7, height: 7)
                Circle().fill(AEColor.amber.opacity(0.9)).frame(width: 7, height: 7)
                Circle().fill(AEColor.signal.opacity(0.9)).frame(width: 7, height: 7)
            }
            .accessibilityHidden(true)

            if let title {
                Text(title)
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundStyle(palette.base.color.opacity(0.78))
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            CodeLanguageBadge(language: language, accent: accent, labelAccent: labelAccent ?? accent)

            if showsCopyButton {
                Button(action: copyCode) {
                    Label(didCopy ? "Copied" : "Copy", systemImage: didCopy ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.plain)
                .foregroundStyle(didCopy ? AEColor.readableSignal(colorScheme) : palette.base.color.opacity(0.78))
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(palette.background.color.opacity(0.72), in: Capsule())
                .accessibilityHint("Copies the complete code sample")
            }
        }
        .padding(.horizontal, 13)
        .frame(minHeight: 42)
        .background(palette.toolbar.color)
    }

    private var lineNumbers: String {
        (1...lineCount).map(String.init).joined(separator: "\n")
    }

    private var highlightedCode: AttributedString {
        AttributedString(
            SyntaxHighlighter.attributedText(
                code,
                language: language,
                scheme: colorScheme,
                fontSize: fontSize
            )
        )
    }

    private func copyCode() {
        #if os(iOS)
        UIPasteboard.general.string = code
        UIAccessibility.post(notification: .announcement, argument: "Code copied")
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(code, forType: .string)
        #endif
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) { didCopy = true }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.6))
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) { didCopy = false }
        }
    }


    init(
        code: String,
        language: CodeLanguage,
        title: String? = nil,
        accent: Color = AEColor.azure,
        labelAccent: Color? = nil,
        showsCopyButton: Bool = true
    ) {
        self.code = code
        self.language = language
        self.title = title
        self.accent = accent
        self.labelAccent = labelAccent
        self.showsCopyButton = showsCopyButton
    }
}

public struct AESyntaxCodeEditor: View {
    @Binding public var text: String
    public let language: CodeLanguage
    public let fileName: String
    public var accent: Color = AEColor.azure
    public var labelAccent: Color? = nil
    public var minHeight: CGFloat = 260
    public var isRunning = false

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var palette: SyntaxPalette { SyntaxPalette(scheme: colorScheme) }
    private var lineCount: Int { max(text.components(separatedBy: .newlines).count, 1) }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                HStack(spacing: 6) {
                    Circle().fill(AEColor.coral.opacity(0.9)).frame(width: 7, height: 7)
                    Circle().fill(AEColor.amber.opacity(0.9)).frame(width: 7, height: 7)
                    Circle().fill(AEColor.signal.opacity(0.9)).frame(width: 7, height: 7)
                }
                .accessibilityHidden(true)

                Label(fileName, systemImage: "doc.text.fill")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundStyle(palette.base.color.opacity(0.82))
                    .lineLimit(1)

                Spacer(minLength: 8)

                if isRunning {
                    ProgressView()
                        .controlSize(.small)
                        .tint(accent)
                        .transition(.scale.combined(with: .opacity))
                        .accessibilityLabel("Running local checks")
                }

                CodeLanguageBadge(language: language, accent: accent, labelAccent: labelAccent ?? accent)
            }
            .padding(.horizontal, 13)
            .frame(minHeight: 42)
            .background(palette.toolbar.color)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: isRunning)

            NativeSyntaxEditor(
                text: $text,
                language: language,
                colorScheme: colorScheme,
                fontSize: CodeFontMetrics.size(for: dynamicTypeSize)
            )
            .frame(minHeight: minHeight)

            HStack(spacing: 12) {
                Label("Editable", systemImage: "pencil.line")
                Spacer()
                Text("\(lineCount) \(lineCount == 1 ? "line" : "lines")")
                Text("\(text.count) chars")
            }
            .font(.system(size: 9, weight: .medium, design: .monospaced))
            .foregroundStyle(palette.muted.color)
            .padding(.horizontal, 13)
            .frame(height: 30)
            .background(palette.toolbar.color)
        }
        .background(palette.background.color)
        .clipShape(RoundedRectangle(cornerRadius: AERadius.medium, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AERadius.medium, style: .continuous)
                .stroke(AEColor.stroke(colorScheme), lineWidth: 1)
        }
        .shadow(color: AEColor.shadow(colorScheme).opacity(0.3), radius: 16, y: 8)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Editable \(language.title) workspace, \(fileName)")
    }


    init(
        text: Binding<String>,
        language: CodeLanguage,
        fileName: String,
        accent: Color = AEColor.azure,
        labelAccent: Color? = nil,
        minHeight: CGFloat = 260,
        isRunning: Bool = false
    ) {
        self._text = text
        self.language = language
        self.fileName = fileName
        self.accent = accent
        self.labelAccent = labelAccent
        self.minHeight = minHeight
        self.isRunning = isRunning
    }
}

public struct AECodeConsole: View {
    public let lines: [String]
    public var accent: Color = AEColor.signal
    public var labelAccent: Color? = nil
    public var isRunning = false

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var palette: SyntaxPalette { SyntaxPalette(scheme: colorScheme) }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("VALIDATION OUTPUT", systemImage: "terminal.fill")
                    .foregroundStyle(labelAccent ?? accent)
                Spacer()
                HStack(spacing: 6) {
                    Circle()
                        .fill(isRunning ? AEColor.amber : AEColor.signal)
                        .frame(width: 6, height: 6)
                        .scaleEffect(isRunning && !reduceMotion ? 1.35 : 1)
                        .animation(
                            isRunning && !reduceMotion
                                ? .easeInOut(duration: 0.65).repeatForever(autoreverses: true)
                                : nil,
                            value: isRunning
                        )
                    Text(isRunning ? "RUNNING" : "READY")
                        .foregroundStyle(palette.muted.color)
                }
            }
            .font(.system(size: 9, weight: .bold, design: .monospaced))
            .tracking(0.7)

            ForEach(Array(lines.suffix(5).enumerated()), id: \.offset) { _, line in
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Image(systemName: consoleIcon(for: line))
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(consoleColor(for: line))
                        .frame(width: 12)
                    Text(line)
                        .font(.system(size: 11, weight: .regular, design: .monospaced))
                        .foregroundStyle(palette.base.color.opacity(0.84))
                        .textSelection(.enabled)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 92, alignment: .topLeading)
        .background(palette.background.color)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.24), value: lines)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Validation output. \(lines.suffix(5).joined(separator: ". "))")
    }

    private func consoleIcon(for line: String) -> String {
        if line.contains("✓") { return "checkmark.circle.fill" }
        if line.localizedCaseInsensitiveContains("keep going") || line.localizedCaseInsensitiveContains("error") {
            return "exclamationmark.circle.fill"
        }
        if line.localizedCaseInsensitiveContains("running") { return "ellipsis.circle.fill" }
        return "chevron.right"
    }

    private func consoleColor(for line: String) -> Color {
        if line.contains("✓") { return AEColor.signal }
        if line.localizedCaseInsensitiveContains("keep going") || line.localizedCaseInsensitiveContains("error") {
            return AEColor.amber
        }
        return labelAccent ?? accent
    }


    init(
        lines: [String],
        accent: Color = AEColor.signal,
        labelAccent: Color? = nil,
        isRunning: Bool = false
    ) {
        self.lines = lines
        self.accent = accent
        self.labelAccent = labelAccent
        self.isRunning = isRunning
    }
}

private struct CodeLanguageBadge: View {
    let language: CodeLanguage
    let accent: Color
    let labelAccent: Color

    var body: some View {
        Label(language.title.uppercased(), systemImage: language.systemImage)
            .font(.system(size: 8, weight: .bold, design: .monospaced))
            .tracking(0.65)
            .foregroundStyle(labelAccent)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(accent.opacity(0.1), in: Capsule())
            .overlay(Capsule().stroke(accent.opacity(0.2)))
            .accessibilityLabel("Language: \(language.title)")
    }
}

#if os(iOS)
private struct NativeSyntaxEditor: UIViewRepresentable {
    @Binding var text: String
    let language: CodeLanguage
    let colorScheme: ColorScheme
    let fontSize: CGFloat

    func makeCoordinator() -> Coordinator { Coordinator(text: $text) }

    func makeUIView(context: Context) -> IOSCodeEditorView {
        let view = IOSCodeEditorView()
        view.onChange = { context.coordinator.text.wrappedValue = $0 }
        return view
    }

    func updateUIView(_ view: IOSCodeEditorView, context: Context) {
        context.coordinator.text = $text
        view.onChange = { context.coordinator.text.wrappedValue = $0 }
        view.configure(text: text, language: language, scheme: colorScheme, fontSize: fontSize)
    }

    final class Coordinator {
        var text: Binding<String>
        init(text: Binding<String>) { self.text = text }
    }
}

@MainActor
private final class IOSCodeEditorView: UIView, UITextViewDelegate, UIScrollViewDelegate {
    let gutter = UITextView()
    let editor = UITextView()
    var onChange: ((String) -> Void)?

    private var language: CodeLanguage = .generic
    private var scheme: ColorScheme = .dark
    private var fontSize: CGFloat = 14
    private var signature = ""
    private var applyingHighlight = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true

        gutter.isEditable = false
        gutter.isSelectable = false
        gutter.isScrollEnabled = true
        gutter.isUserInteractionEnabled = false
        gutter.showsVerticalScrollIndicator = false
        gutter.showsHorizontalScrollIndicator = false
        gutter.textAlignment = .right
        gutter.textContainerInset = UIEdgeInsets(top: 12, left: 2, bottom: 12, right: 6)
        gutter.textContainer.lineFragmentPadding = 0
        gutter.accessibilityElementsHidden = true
        addSubview(gutter)

        editor.delegate = self
        editor.keyboardDismissMode = .interactive
        editor.autocapitalizationType = .none
        editor.autocorrectionType = .no
        editor.smartDashesType = .no
        editor.smartQuotesType = .no
        editor.spellCheckingType = .no
        editor.alwaysBounceHorizontal = true
        editor.showsHorizontalScrollIndicator = true
        editor.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 18)
        editor.textContainer.lineFragmentPadding = 0
        editor.textContainer.widthTracksTextView = false
        editor.textContainer.size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        editor.accessibilityLabel = "Code editor"
        editor.accessibilityHint = "Edit the starter code, then run the local checks"
        addSubview(editor)
    }

    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()
        gutter.frame = CGRect(x: 0, y: 0, width: 48, height: bounds.height)
        editor.frame = CGRect(x: 49, y: 0, width: max(bounds.width - 49, 1), height: bounds.height)
    }

    func configure(text: String, language: CodeLanguage, scheme: ColorScheme, fontSize: CGFloat) {
        self.language = language
        self.scheme = scheme
        self.fontSize = fontSize
        let palette = SyntaxPalette(scheme: scheme)
        backgroundColor = palette.background.platformColor
        gutter.backgroundColor = palette.gutter.platformColor
        editor.backgroundColor = palette.background.platformColor
        editor.tintColor = palette.function.platformColor

        let newSignature = "\(language.rawValue)-\(scheme == .dark)-\(fontSize)-\(text.hashValue)"
        if editor.text != text || signature != newSignature {
            apply(text)
            signature = newSignature
        }
        updateGutter(for: text)
    }

    func textViewDidChange(_ textView: UITextView) {
        guard !applyingHighlight else { return }
        let source = textView.text ?? ""
        onChange?(source)
        updateGutter(for: source)
        guard textView.markedTextRange == nil else { return }
        apply(source)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === editor else { return }
        var offset = gutter.contentOffset
        offset.y = editor.contentOffset.y
        gutter.setContentOffset(offset, animated: false)
    }

    private func apply(_ source: String) {
        applyingHighlight = true
        let selection = editor.selectedRange
        let offset = editor.contentOffset
        let attributed = SyntaxHighlighter.attributedText(source, language: language, scheme: scheme, fontSize: fontSize)
        editor.attributedText = attributed
        editor.selectedRange = NSRange(location: min(selection.location, attributed.length), length: 0)
        if selection.location + selection.length <= attributed.length { editor.selectedRange = selection }
        editor.contentOffset = offset
        editor.typingAttributes = SyntaxHighlighter.attributedText(" ", language: language, scheme: scheme, fontSize: fontSize).attributes(at: 0, effectiveRange: nil)
        applyingHighlight = false
    }

    private func updateGutter(for source: String) {
        let palette = SyntaxPalette(scheme: scheme)
        let count = max(source.components(separatedBy: .newlines).count, 1)
        let numbers = (1...count).map(String.init).joined(separator: "\n")
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 4
        paragraph.alignment = .right
        gutter.attributedText = NSAttributedString(
            string: numbers,
            attributes: [
                .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
                .foregroundColor: palette.muted.platformColor,
                .paragraphStyle: paragraph
            ]
        )
        scrollViewDidScroll(editor)
    }
}
#elseif os(macOS)
private struct NativeSyntaxEditor: NSViewRepresentable {
    @Binding var text: String
    let language: CodeLanguage
    let colorScheme: ColorScheme
    let fontSize: CGFloat

    func makeCoordinator() -> Coordinator { Coordinator(text: $text) }

    func makeNSView(context: Context) -> MacCodeEditorView {
        let view = MacCodeEditorView()
        view.onChange = { context.coordinator.text.wrappedValue = $0 }
        return view
    }

    func updateNSView(_ view: MacCodeEditorView, context: Context) {
        context.coordinator.text = $text
        view.onChange = { context.coordinator.text.wrappedValue = $0 }
        view.configure(text: text, language: language, scheme: colorScheme, fontSize: fontSize)
    }

    final class Coordinator {
        var text: Binding<String>
        init(text: Binding<String>) { self.text = text }
    }
}

@MainActor
private final class MacCodeEditorView: NSView, NSTextViewDelegate {
    let gutterScroll = NSScrollView()
    let gutter = NSTextView()
    let editorScroll = NSScrollView()
    let editor = NSTextView()
    var onChange: ((String) -> Void)?

    private var language: CodeLanguage = .generic
    private var scheme: ColorScheme = .dark
    private var fontSize: CGFloat = 14
    private var signature = ""
    private var applyingHighlight = false

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.masksToBounds = true

        gutter.isEditable = false
        gutter.isSelectable = false
        gutter.isRichText = true
        gutter.drawsBackground = true
        gutter.alignment = .right
        gutter.textContainerInset = NSSize(width: 5, height: 12)
        gutter.textContainer?.lineFragmentPadding = 0
        gutter.isVerticallyResizable = true
        gutter.isHorizontallyResizable = false
        gutterScroll.documentView = gutter
        gutterScroll.hasVerticalScroller = false
        gutterScroll.hasHorizontalScroller = false
        gutterScroll.drawsBackground = false
        addSubview(gutterScroll)

        editor.delegate = self
        editor.isRichText = true
        editor.importsGraphics = false
        editor.isAutomaticQuoteSubstitutionEnabled = false
        editor.isAutomaticDashSubstitutionEnabled = false
        editor.isAutomaticSpellingCorrectionEnabled = false
        editor.isContinuousSpellCheckingEnabled = false
        editor.isHorizontallyResizable = true
        editor.isVerticallyResizable = true
        editor.minSize = NSSize(width: 0, height: 0)
        editor.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        editor.textContainerInset = NSSize(width: 12, height: 12)
        editor.textContainer?.lineFragmentPadding = 0
        editor.textContainer?.containerSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        editor.textContainer?.widthTracksTextView = false
        editor.setAccessibilityLabel("Code editor")
        editor.setAccessibilityHelp("Edit the starter code, then run the local checks")

        let synchronizedClipView = SynchronizedCodeClipView()
        synchronizedClipView.onBoundsChange = { [weak self] in self?.syncGutter() }
        editorScroll.contentView = synchronizedClipView
        editorScroll.documentView = editor
        editorScroll.hasVerticalScroller = true
        editorScroll.hasHorizontalScroller = true
        editorScroll.autohidesScrollers = true
        editorScroll.drawsBackground = false
        addSubview(editorScroll)
    }

    required init?(coder: NSCoder) { nil }

    override func layout() {
        super.layout()
        gutterScroll.frame = NSRect(x: 0, y: 0, width: 48, height: bounds.height)
        editorScroll.frame = NSRect(x: 49, y: 0, width: max(bounds.width - 49, 1), height: bounds.height)
    }

    func configure(text: String, language: CodeLanguage, scheme: ColorScheme, fontSize: CGFloat) {
        self.language = language
        self.scheme = scheme
        self.fontSize = fontSize
        let palette = SyntaxPalette(scheme: scheme)
        layer?.backgroundColor = palette.background.platformColor.cgColor
        gutter.backgroundColor = palette.gutter.platformColor
        editor.backgroundColor = palette.background.platformColor
        editor.insertionPointColor = palette.function.platformColor

        let newSignature = "\(language.rawValue)-\(scheme == .dark)-\(fontSize)-\(text.hashValue)"
        if editor.string != text || signature != newSignature {
            apply(text)
            signature = newSignature
        }
        updateGutter(for: text)
    }

    func textDidChange(_ notification: Notification) {
        guard !applyingHighlight else { return }
        let source = editor.string
        onChange?(source)
        updateGutter(for: source)
        guard editor.hasMarkedText() == false else { return }
        apply(source)
    }

    private func apply(_ source: String) {
        applyingHighlight = true
        let selections = editor.selectedRanges
        let visible = editorScroll.contentView.bounds.origin
        let attributed = SyntaxHighlighter.attributedText(source, language: language, scheme: scheme, fontSize: fontSize)
        editor.textStorage?.setAttributedString(attributed)
        let validSelections = selections.filter { NSMaxRange($0.rangeValue) <= attributed.length }
        editor.selectedRanges = validSelections.isEmpty ? [NSValue(range: NSRange(location: attributed.length, length: 0))] : validSelections
        editor.typingAttributes = SyntaxHighlighter.attributedText(" ", language: language, scheme: scheme, fontSize: fontSize).attributes(at: 0, effectiveRange: nil)
        editorScroll.contentView.scroll(to: visible)
        editorScroll.reflectScrolledClipView(editorScroll.contentView)
        applyingHighlight = false
    }

    private func updateGutter(for source: String) {
        let palette = SyntaxPalette(scheme: scheme)
        let count = max(source.components(separatedBy: .newlines).count, 1)
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 4
        paragraph.alignment = .right
        gutter.textStorage?.setAttributedString(NSAttributedString(
            string: (1...count).map(String.init).joined(separator: "\n"),
            attributes: [
                .font: NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
                .foregroundColor: palette.muted.platformColor,
                .paragraphStyle: paragraph
            ]
        ))
        gutter.sizeToFit()
        gutter.frame.size.width = 48
        syncGutter()
    }

    private func syncGutter() {
        let editorOrigin = editorScroll.contentView.bounds.origin
        gutterScroll.contentView.scroll(to: NSPoint(x: 0, y: editorOrigin.y))
        gutterScroll.reflectScrolledClipView(gutterScroll.contentView)
    }
}

@MainActor
private final class SynchronizedCodeClipView: NSClipView {
    var onBoundsChange: (() -> Void)?

    override func setBoundsOrigin(_ newOrigin: NSPoint) {
        super.setBoundsOrigin(newOrigin)
        onBoundsChange?()
    }
}
#endif
