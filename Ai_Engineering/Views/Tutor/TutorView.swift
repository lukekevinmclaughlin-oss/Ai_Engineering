import SwiftUI

struct TutorView: View {
    @EnvironmentObject private var state: AppState
    let initialContext: TutorContext?

    init(initialContext: TutorContext? = nil) {
        self.initialContext = initialContext
    }

    var body: some View {
        Group {
            if let initialContext {
                ScopedTutorWorkspace(
                    curriculum: state.curriculum,
                    projects: state.projects,
                    context: initialContext,
                    parent: state.tutor
                )
            } else {
                TutorWorkspace(tutor: state.tutor)
            }
        }
    }
}

@MainActor
private struct ScopedTutorWorkspace: View {
    @StateObject private var tutor: TutorCoordinator
    @ObservedObject private var parent: TutorCoordinator

    init(
        curriculum: Curriculum,
        projects: [LabProject],
        context: TutorContext,
        parent: TutorCoordinator
    ) {
        let coordinator = TutorCoordinator(curriculum: curriculum, projects: projects)
        coordinator.preferences = parent.preferences
        coordinator.providerConfiguration = parent.providerConfiguration
        coordinator.setContext(context)
        _tutor = StateObject(wrappedValue: coordinator)
        _parent = ObservedObject(wrappedValue: parent)
    }

    var body: some View {
        TutorWorkspace(tutor: tutor)
            .onDisappear {
                parent.preferences = tutor.preferences
                parent.providerConfiguration = tutor.providerConfiguration
            }
    }
}

private struct TutorWorkspace: View {
    @ObservedObject var tutor: TutorCoordinator
    @Environment(\.colorScheme) private var colorScheme
    @State private var draft = ""
    @State private var showSettings = false
    @FocusState private var composerFocused: Bool

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                AEFrontierBackground(accent: AEColor.violet, intensity: 0.56)

                if proxy.size.width >= 820 {
                    HStack(spacing: 0) {
                        tutorRail
                            .frame(width: min(310, proxy.size.width * 0.29))
                        Divider().overlay(AEColor.divider(colorScheme))
                        chatPane
                    }
                } else {
                    VStack(spacing: 0) {
                        compactHeader
                        Divider().overlay(AEColor.divider(colorScheme))
                        chatPane
                    }
                }
            }
        }
        .navigationTitle("Tutor")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .sheet(isPresented: $showSettings) {
            TutorSettingsView(tutor: tutor)
        }
    }

    private var tutorRail: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AESpacing.lg) {
                HStack(spacing: AESpacing.sm) {
                    TutorCoreMark(size: 46)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("TUTOR CORE")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .tracking(1.2)
                            .foregroundStyle(AEColor.readableViolet(colorScheme))
                        Text("Principal AI engineer")
                            .font(.aeCaption)
                            .foregroundStyle(AEColor.textSecondary(colorScheme))
                    }
                }

                contextCard
                engineCard
                teachingControls
                optionalConnection

                Button {
                    tutor.clearConversation()
                } label: {
                    Label("New conversation", systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(AEButtonStyle(.secondary))
            }
            .padding(AESpacing.lg)
        }
        .background(AEColor.railFill(colorScheme))
    }

    private var compactHeader: some View {
        HStack(spacing: AESpacing.sm) {
            TutorCoreMark(size: 38)
            VStack(alignment: .leading, spacing: 1) {
                Text("TUTOR CORE")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .tracking(1)
                    .foregroundStyle(AEColor.readableViolet(colorScheme))
                HStack(spacing: 5) {
                    Circle()
                        .fill(tutor.usesNetwork ? AEColor.amber : AEColor.signal)
                        .frame(width: 6, height: 6)
                    Text(tutor.activeEngineName)
                        .font(.aeCaption)
                        .foregroundStyle(AEColor.textSecondary(colorScheme))
                }
            }
            Spacer()
            if !tutor.context.isGeneral {
                Text(tutor.context.displayTitle)
                    .font(.aeCaption)
                    .foregroundStyle(AEColor.textSecondary(colorScheme))
                    .lineLimit(1)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AEColor.subtleFill(colorScheme), in: Capsule())
            }
            if !tutor.context.isGeneral {
                Button { showSettings = true } label: {
                    Image(systemName: "slider.horizontal.3")
                }
                .buttonStyle(AEIconButtonStyle(diameter: 36))
                .accessibilityLabel("Tutor settings")
            }
        }
        .padding(.horizontal, AESpacing.md)
        .padding(.vertical, AESpacing.sm)
        .background(.ultraThinMaterial)
    }

    private var contextCard: some View {
        VStack(alignment: .leading, spacing: AESpacing.sm) {
            HStack {
                Label("CURRENT CONTEXT", systemImage: "scope")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .tracking(0.9)
                    .foregroundStyle(AEColor.readableAzure(colorScheme))
                Spacer()
                if !tutor.context.isGeneral {
                    Button("Clear") { tutor.clearContext() }
                        .buttonStyle(.plain)
                        .font(.aeCaption)
                        .foregroundStyle(AEColor.textTertiary(colorScheme))
                }
            }
            Text(tutor.context.displayTitle)
                .font(.aeHeading)
                .foregroundStyle(AEColor.textPrimary(colorScheme))
                .fixedSize(horizontal: false, vertical: true)
            Text(tutor.context.subtitle)
                .font(.aeCaption)
                .foregroundStyle(AEColor.textSecondary(colorScheme))
        }
        .padding(AESpacing.md)
        .aeGlassSurface(cornerRadius: AERadius.medium, tint: AEColor.azure)
    }

    private var engineCard: some View {
        VStack(alignment: .leading, spacing: AESpacing.sm) {
            HStack {
                Image(systemName: tutor.usesNetwork ? "network" : "lock.fill")
                    .foregroundStyle(tutor.usesNetwork ? AEColor.amber : AEColor.signal)
                Text(tutor.activeEngineName)
                    .font(.aeHeading)
                    .foregroundStyle(AEColor.textPrimary(colorScheme))
                Spacer()
                Circle()
                    .fill(tutor.usesNetwork ? AEColor.amber : AEColor.signal)
                    .frame(width: 8, height: 8)
                    .aeGlow(color: tutor.usesNetwork ? AEColor.amber : AEColor.signal, radius: 8, intensity: 0.8)
            }
            Text(tutor.activeEngineDetail)
                .font(.aeCaption)
                .foregroundStyle(AEColor.textSecondary(colorScheme))
            Button("Engine settings") { showSettings = true }
                .buttonStyle(.plain)
                .font(.aeLabel)
                .foregroundStyle(AEColor.readableSignal(colorScheme))
        }
        .padding(AESpacing.md)
        .background(AEColor.subtleFill(colorScheme), in: RoundedRectangle(cornerRadius: AERadius.medium))
        .overlay(RoundedRectangle(cornerRadius: AERadius.medium).stroke(AEColor.stroke(colorScheme)))
    }

    private var teachingControls: some View {
        VStack(alignment: .leading, spacing: AESpacing.md) {
            Text("TEACHING MODE")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .tracking(0.9)
                .foregroundStyle(AEColor.textTertiary(colorScheme))

            Picker("Starting knowledge", selection: Binding(
                get: { tutor.preferences.learnerLevel },
                set: { tutor.preferences.learnerLevel = $0 }
            )) {
                ForEach(TutorLearnerLevel.allCases) { Text($0.title).tag($0) }
            }
            .labelsHidden()

            Picker("Answer depth", selection: Binding(
                get: { tutor.preferences.answerDepth },
                set: { tutor.preferences.answerDepth = $0 }
            )) {
                ForEach(TutorAnswerDepth.allCases) { Text($0.title).tag($0) }
            }
            .labelsHidden()
        }
    }

    private var optionalConnection: some View {
        VStack(alignment: .leading, spacing: AESpacing.sm) {
            HStack {
                Image(systemName: "link.badge.plus")
                    .foregroundStyle(AEColor.readableViolet(colorScheme))
                Text("Your favourite LLM")
                    .font(.aeLabel)
                    .foregroundStyle(AEColor.textPrimary(colorScheme))
            }
            Text("Optional. Offline tutoring remains available with no subscription.")
                .font(.aeCaption)
                .foregroundStyle(AEColor.textSecondary(colorScheme))
            Button(tutor.providerIsReady ? "Review connection" : "Connect a provider") {
                showSettings = true
            }
            .buttonStyle(AEButtonStyle(.outline, size: .compact, tint: AEColor.violet))
        }
        .padding(AESpacing.md)
        .background(AEColor.violet.opacity(0.055), in: RoundedRectangle(cornerRadius: AERadius.medium))
        .overlay(RoundedRectangle(cornerRadius: AERadius.medium).stroke(AEColor.violet.opacity(0.18)))
    }

    private var chatPane: some View {
        VStack(spacing: 0) {
            if tutor.context.isGeneral {
                chatHeader
            }
            messageList
            suggestions
            composer
        }
    }

    private var chatHeader: some View {
        HStack(alignment: .center, spacing: AESpacing.md) {
            VStack(alignment: .leading, spacing: 3) {
                Text("ASK, BUILD, UNDERSTAND")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .tracking(1.1)
                    .foregroundStyle(AEColor.readableViolet(colorScheme))
                Text("No question is too basic")
                    .font(.aeTitle)
                    .foregroundStyle(AEColor.textPrimary(colorScheme))
            }
            Spacer()
            Button { tutor.clearConversation() } label: {
                Image(systemName: "arrow.counterclockwise")
            }
            .buttonStyle(AEIconButtonStyle(diameter: 36))
            .accessibilityLabel("New conversation")
            Button { showSettings = true } label: {
                Image(systemName: "slider.horizontal.3")
            }
            .buttonStyle(AEIconButtonStyle(diameter: 36, tint: AEColor.violet))
            .accessibilityLabel("Tutor settings")
        }
        .padding(.horizontal, AESpacing.lg)
        .padding(.vertical, AESpacing.md)
        .background(.ultraThinMaterial)
    }

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: AESpacing.lg) {
                    ForEach(tutor.messages) { message in
                        TutorMessageBubble(message: message)
                            .id(message.id)
                    }

                    if tutor.isResponding {
                        TutorThinkingBubble(engine: tutor.activeEngineName)
                            .id("thinking")
                    }
                }
                .padding(.horizontal, AESpacing.lg)
                .padding(.vertical, AESpacing.lg)
                .frame(maxWidth: 880)
                .frame(maxWidth: .infinity)
            }
            .onChange(of: tutor.messages.count) { _, _ in
                if let last = tutor.messages.last {
                    withAnimation(AEMotion.gentle) { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
            .onChange(of: tutor.isResponding) { _, responding in
                if responding {
                    withAnimation(AEMotion.gentle) { proxy.scrollTo("thinking", anchor: .bottom) }
                }
            }
        }
    }

    private var suggestions: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AESpacing.sm) {
                ForEach(tutor.starterPrompts, id: \.self) { prompt in
                    Button {
                        draft = prompt
                        composerFocused = true
                    } label: {
                        Text(prompt)
                            .font(.aeCaption)
                            .lineLimit(1)
                    }
                    .buttonStyle(AEButtonStyle(.outline, size: .compact, tint: AEColor.violet))
                }
            }
            .padding(.horizontal, AESpacing.lg)
            .padding(.vertical, AESpacing.sm)
        }
        .background(AEColor.railFill(colorScheme).opacity(0.72))
    }

    private var composer: some View {
        HStack(alignment: .bottom, spacing: AESpacing.sm) {
            TextField("Ask anything about AI engineering…", text: $draft, axis: .vertical)
                .textFieldStyle(.plain)
                .font(.aeBody)
                .foregroundStyle(AEColor.textPrimary(colorScheme))
                .lineLimit(1...6)
                .focused($composerFocused)
                .padding(.horizontal, AESpacing.md)
                .padding(.vertical, 13)
                .background(AEColor.inputFill(colorScheme), in: RoundedRectangle(cornerRadius: 17))
                .overlay(RoundedRectangle(cornerRadius: 17).stroke(AEColor.strokeStrong(colorScheme)))
                .onSubmit(send)

            Button(action: send) {
                Image(systemName: tutor.isResponding ? "ellipsis" : "arrow.up")
            }
            .buttonStyle(AEIconButtonStyle(diameter: 46, tint: AEColor.signal, emphasized: true))
            .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || tutor.isResponding)
            .accessibilityLabel("Send question")
        }
        .padding(.horizontal, AESpacing.lg)
        .padding(.top, AESpacing.sm)
        .padding(.bottom, AESpacing.md)
        .background(.ultraThinMaterial)
    }

    private func send() {
        let question = draft
        draft = ""
        tutor.send(question)
    }
}

private struct TutorMessageBubble: View {
    @Environment(\.colorScheme) private var colorScheme
    let message: TutorMessage

    private var isUser: Bool { message.role == .user }

    var body: some View {
        HStack(alignment: .top, spacing: AESpacing.sm) {
            if isUser { Spacer(minLength: 52) }

            if !isUser {
                TutorCoreMark(size: 34)
                    .padding(.top, 2)
            }

            VStack(alignment: isUser ? .trailing : .leading, spacing: AESpacing.sm) {
                TutorMarkdownText(
                    content: message.content,
                    foreground: isUser ? Color.black.opacity(0.80) : AEColor.textPrimary(colorScheme)
                )

                if !message.sources.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("RETRIEVED CONTEXT")
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                            .tracking(0.8)
                            .foregroundStyle(AEColor.textTertiary(colorScheme))
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AESpacing.xs) {
                                ForEach(message.sources) { source in
                                    Label(source.title, systemImage: source.location.contains("Portfolio") ? "hammer.fill" : "book.closed.fill")
                                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                                        .foregroundStyle(AEColor.readableAzure(colorScheme))
                                        .padding(.horizontal, 9)
                                        .padding(.vertical, 6)
                                        .background(AEColor.azure.opacity(0.08), in: Capsule())
                                        .overlay(Capsule().stroke(AEColor.azure.opacity(0.18)))
                                }
                            }
                        }
                    }
                }

                if let engine = message.engineName, !isUser {
                    Label(engine, systemImage: engine.contains("Apple") ? "apple.intelligence" : "internaldrive.fill")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(AEColor.textTertiary(colorScheme))
                }
            }
            .padding(AESpacing.md)
            .frame(maxWidth: isUser ? 620 : 760, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(isUser ? AnyShapeStyle(AEGradient.signal) : AnyShapeStyle(AEColor.subtleFill(colorScheme)))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(isUser ? Color.white.opacity(0.18) : AEColor.violet.opacity(colorScheme == .dark ? 0.18 : 0.28))
            }

            if !isUser { Spacer(minLength: 28) }
        }
        .frame(maxWidth: .infinity)
    }

}

private struct TutorMarkdownText: View {
    let content: String
    let foreground: Color

    private var blocks: [String] {
        content
            .components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                Text(markdown(block))
                    .font(.aeBody)
                    .foregroundStyle(foreground)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func markdown(_ block: String) -> AttributedString {
        let hardWrapped = block.replacingOccurrences(of: "\n", with: "  \n")
        return (try? AttributedString(markdown: hardWrapped)) ?? AttributedString(block)
    }
}

private struct TutorThinkingBubble: View {
    @Environment(\.colorScheme) private var colorScheme
    let engine: String

    var body: some View {
        HStack(alignment: .center, spacing: AESpacing.sm) {
            TutorCoreMark(size: 34)
            HStack(spacing: AESpacing.sm) {
                ProgressView()
                    .controlSize(.small)
                    .tint(AEColor.signal)
                Text("\(engine) is building the explanation…")
                    .font(.aeCallout)
                    .foregroundStyle(AEColor.textSecondary(colorScheme))
            }
            .padding(AESpacing.md)
            .background(AEColor.subtleFill(colorScheme), in: RoundedRectangle(cornerRadius: 18))
            Spacer()
        }
    }
}

private struct TutorCoreMark: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.34, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [AEColor.violet.opacity(0.24), AEColor.azure.opacity(0.10)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: size * 0.34, style: .continuous)
                        .stroke(AEGradient.spectral, lineWidth: 1.4)
                }
            Image(systemName: "brain.head.profile.fill")
                .font(.system(size: size * 0.46, weight: .semibold))
                .foregroundStyle(AEGradient.spectral)
        }
        .frame(width: size, height: size)
        .aeGlow(color: AEColor.violet, radius: size * 0.35, intensity: 0.65)
        .accessibilityHidden(true)
    }
}
