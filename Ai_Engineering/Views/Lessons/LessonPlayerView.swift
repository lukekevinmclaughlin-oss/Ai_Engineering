import SwiftUI

struct LessonPlayerView: View {
    @EnvironmentObject private var state: AppState
    @Environment(\.dismiss) private var dismiss

    let course: Course
    @State private var currentIndex: Int
    @State private var showCompletion = false
    @State private var showTutor = false

    init(course: Course, moduleIndex: Int, lessonIndex: Int) {
        self.course = course
        let precedingLessons = course.modules.prefix(moduleIndex).reduce(0) { $0 + $1.lessons.count }
        _currentIndex = State(initialValue: min(precedingLessons + lessonIndex, max(course.lessons.count - 1, 0)))
    }

    private var lesson: Lesson { course.lessons[currentIndex] }
    private var accent: Color { Color(hex: course.accent) }

    var body: some View {
        ZStack {
            AEFrontierBackground(accent: accent, intensity: 0.46)

            VStack(spacing: 0) {
                lessonHeader
                Divider().overlay(Color.white.opacity(0.07))
                lessonLayout
            }

            if showCompletion {
                LessonCompletionOverlay(
                    lesson: lesson,
                    course: course,
                    hasNext: currentIndex < course.lessons.count - 1,
                    continueAction: advance,
                    exitAction: { dismiss() }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
                .zIndex(10)
            }
        }
        .navigationBarBackButtonHidden(showCompletion)
        .sheet(isPresented: $showTutor) {
            NavigationStack {
                TutorView(initialContext: .lesson(lesson, in: course))
            }
            #if os(macOS)
            .frame(minWidth: 900, minHeight: 680)
            #endif
        }
        #if os(macOS)
        .frame(minWidth: 850, minHeight: 620)
        #endif
    }

    private var lessonHeader: some View {
        VStack(spacing: AESpacing.sm) {
            HStack(spacing: AESpacing.md) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .frame(width: 34, height: 34)
                        .background(Color.white.opacity(0.055), in: Circle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(AEColor.textSecondary(.dark))

                VStack(alignment: .leading, spacing: 2) {
                    Text(course.title.uppercased())
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .tracking(0.9)
                        .foregroundStyle(accent)
                    Text(lesson.title)
                        .font(.aeCallout)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }

                Spacer()

                Button { showTutor = true } label: {
                    ViewThatFits(in: .horizontal) {
                        Label("Ask Tutor", systemImage: "bubble.left.and.bubble.right.fill")
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                    }
                    .font(.aeLabel)
                    .foregroundStyle(AEColor.violet)
                    .padding(.horizontal, 10)
                    .frame(height: 32)
                    .background(AEColor.violet.opacity(0.09), in: Capsule())
                    .overlay(Capsule().stroke(AEColor.violet.opacity(0.18)))
                }
                .buttonStyle(.plain)

                Label("\(lesson.xp) XP", systemImage: "bolt.fill")
                    .font(.aeLabel)
                    .foregroundStyle(AEColor.signal)
                Text("\(currentIndex + 1) / \(course.lessonCount)")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(AEColor.textTertiary(.dark))
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.06))
                    Capsule()
                        .fill(AEGradient.spectral)
                        .frame(width: proxy.size.width * Double(currentIndex + 1) / Double(max(course.lessonCount, 1)))
                        .animation(AEMotion.standard, value: currentIndex)
                }
            }
            .frame(height: 4)
        }
        .padding(.horizontal, AESpacing.lg)
        .padding(.vertical, AESpacing.sm)
        .background(.ultraThinMaterial)
    }

    @ViewBuilder
    private var lessonLayout: some View {
        #if os(macOS)
        HSplitView {
            ScrollView {
                LessonContentPane(lesson: lesson, accent: accent)
                    .padding(AESpacing.xl)
                    .frame(maxWidth: 680, alignment: .leading)
                    .frame(maxWidth: .infinity, alignment: .top)
            }
            .frame(minWidth: 360, idealWidth: 500)

            ScrollView {
                ChallengePanel(lesson: lesson, accent: accent) {
                    completeLesson()
                }
                .id(lesson.id)
                .padding(AESpacing.xl)
                .frame(maxWidth: 700)
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .frame(minWidth: 420, idealWidth: 600)
            .background(Color.black.opacity(0.08))
        }
        #else
        ScrollView {
            VStack(spacing: AESpacing.xl) {
                LessonContentPane(lesson: lesson, accent: accent)
                ChallengePanel(lesson: lesson, accent: accent) {
                    completeLesson()
                }
                .id(lesson.id)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, AESpacing.lg)
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
        }
        #endif
    }

    private func completeLesson() {
        state.progress.complete(lesson, in: course)
        withAnimation(AEMotion.standard) { showCompletion = true }
    }

    private func advance() {
        guard currentIndex < course.lessons.count - 1 else {
            dismiss()
            return
        }
        withAnimation(AEMotion.standard) {
            showCompletion = false
            currentIndex += 1
        }
    }
}

private struct LessonContentPane: View {
    let lesson: Lesson
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: AESpacing.lg) {
            HStack(spacing: AESpacing.sm) {
                Image(systemName: lesson.kind.systemImage)
                    .foregroundStyle(accent)
                    .frame(width: 38, height: 38)
                    .background(accent.opacity(0.11), in: RoundedRectangle(cornerRadius: 11))
                VStack(alignment: .leading, spacing: 2) {
                    Text(lesson.kind.title.uppercased())
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .tracking(1)
                        .foregroundStyle(accent)
                    Text("\(lesson.estimatedMinutes) minute lesson")
                        .font(.aeCaption)
                        .foregroundStyle(AEColor.textTertiary(.dark))
                }
            }

            Text(lesson.title)
                .aeTextRole(.display)
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            Text(lesson.summary)
                .aeTextRole(.body)
                .foregroundStyle(AEColor.textSecondary(.dark))

            Divider().overlay(Color.white.opacity(0.07))

            ForEach(Array(lesson.contentBlocks.enumerated()), id: \.offset) { _, block in
                LessonBlockView(block: block, accent: accent)
            }
        }
    }
}

private struct LessonBlockView: View {
    let block: LessonContentBlock
    let accent: Color

    var body: some View {
        switch block.type {
        case .heading:
            Text(block.text)
                .font(.aeHeading)
                .foregroundStyle(.white)
                .padding(.top, AESpacing.xs)
        case .paragraph:
            Text(block.text)
                .font(.aeBody)
                .foregroundStyle(AEColor.textSecondary(.dark))
                .textSelection(.enabled)
        case .callout:
            HStack(alignment: .top, spacing: AESpacing.sm) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(accent)
                Text(block.text)
                    .font(.aeCallout)
                    .foregroundStyle(AEColor.textPrimary(.dark))
            }
            .padding(AESpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(accent.opacity(0.075), in: RoundedRectangle(cornerRadius: AERadius.medium))
            .overlay(RoundedRectangle(cornerRadius: AERadius.medium).stroke(accent.opacity(0.2)))
        case .code:
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text((block.language ?? "code").uppercased())
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .tracking(0.8)
                        .foregroundStyle(AEColor.textTertiary(.dark))
                    Spacer()
                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                        .foregroundStyle(accent)
                }
                .padding(.horizontal, AESpacing.md)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.035))

                ScrollView(.horizontal, showsIndicators: false) {
                    Text(block.text)
                        .font(.aeCode)
                        .foregroundStyle(Color(hex: "C7D6F4"))
                        .textSelection(.enabled)
                        .padding(AESpacing.md)
                }
            }
            .background(Color(hex: "070B14"), in: RoundedRectangle(cornerRadius: AERadius.medium))
            .overlay(RoundedRectangle(cornerRadius: AERadius.medium).stroke(Color.white.opacity(0.075)))
        case .bullets:
            VStack(alignment: .leading, spacing: 10) {
                if !block.text.isEmpty {
                    Text(block.text).font(.aeCallout).foregroundStyle(.white)
                }
                ForEach(block.items ?? [], id: \.self) { item in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "arrow.turn.down.right")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(accent)
                            .padding(.top, 4)
                        Text(item)
                            .font(.aeCallout)
                            .foregroundStyle(AEColor.textSecondary(.dark))
                    }
                }
            }
        }
    }
}

private enum ChallengeResult: Equatable {
    case idle
    case success
    case failure(String)
}

private struct ChallengePanel: View {
    let lesson: Lesson
    let accent: Color
    let completion: () -> Void

    @State private var selectedChoiceID: String?
    @State private var code: String
    @State private var result: ChallengeResult = .idle
    @State private var visibleHints = 0
    @State private var attempts = 0
    @State private var showSolution = false

    init(lesson: Lesson, accent: Color, completion: @escaping () -> Void) {
        self.lesson = lesson
        self.accent = accent
        self.completion = completion
        _code = State(initialValue: lesson.challenge?.starterCode ?? "")
    }

    var body: some View {
        let challenge = lesson.challenge
        VStack(alignment: .leading, spacing: AESpacing.lg) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("PRACTICE NODE")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .tracking(1.1)
                        .foregroundStyle(accent)
                    Text(challenge?.prompt ?? "Apply what you learned")
                        .font(.aeTitle)
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Image(systemName: "terminal.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(accent)
            }

            Text(challenge?.instructions ?? "Review the concept, then mark this node complete.")
                .font(.aeBody)
                .foregroundStyle(AEColor.textSecondary(.dark))

            if let choices = challenge?.choices, !choices.isEmpty {
                choiceList(choices)
            } else if challenge?.starterCode != nil {
                codeEditor(challenge: challenge)
            } else {
                ConceptConfirmation(accent: accent)
            }

            hintArea(challenge: challenge)

            if showSolution, let solution = challenge?.solution, !solution.isEmpty {
                solutionView(solution)
            }

            resultView(challenge: challenge)

            HStack(spacing: AESpacing.sm) {
                if result == .success {
                    Button(action: completion) {
                        Label("Complete & earn \(lesson.xp) XP", systemImage: "bolt.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryChallengeButtonStyle(accent: accent))
                } else {
                    Button(action: { evaluate(challenge) }) {
                        Label(challenge?.starterCode == nil && challenge?.choices == nil ? "Mark understood" : "Check answer", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryChallengeButtonStyle(accent: accent))
                    .disabled(challenge?.choices != nil && selectedChoiceID == nil)
                    .opacity(challenge?.choices != nil && selectedChoiceID == nil ? 0.55 : 1)
                }
            }
        }
        .padding(AESpacing.lg)
        .aeGlassSurface(cornerRadius: AERadius.large, tint: accent)
    }

    private func choiceList(_ choices: [ChallengeChoice]) -> some View {
        VStack(spacing: AESpacing.sm) {
            ForEach(Array(choices.enumerated()), id: \.element.id) { index, choice in
                Button {
                    withAnimation(AEMotion.quick) {
                        selectedChoiceID = choice.id
                        result = .idle
                    }
                } label: {
                    HStack(spacing: AESpacing.md) {
                        Text(String(UnicodeScalar(65 + index)!))
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundStyle(selectedChoiceID == choice.id ? Color.black.opacity(0.8) : accent)
                            .frame(width: 30, height: 30)
                            .background(selectedChoiceID == choice.id ? AnyShapeStyle(accent) : AnyShapeStyle(accent.opacity(0.1)), in: RoundedRectangle(cornerRadius: 9))
                        Text(choice.text)
                            .font(.aeCallout)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        Image(systemName: selectedChoiceID == choice.id ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(selectedChoiceID == choice.id ? accent : AEColor.textTertiary(.dark))
                    }
                    .padding(AESpacing.md)
                    .background(selectedChoiceID == choice.id ? accent.opacity(0.08) : Color.white.opacity(0.035), in: RoundedRectangle(cornerRadius: AERadius.medium))
                    .overlay(RoundedRectangle(cornerRadius: AERadius.medium).stroke(selectedChoiceID == choice.id ? accent.opacity(0.45) : Color.white.opacity(0.065)))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func codeEditor(challenge: LessonChallenge?) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack(spacing: 6) {
                    Circle().fill(AEColor.coral).frame(width: 7, height: 7)
                    Circle().fill(AEColor.amber).frame(width: 7, height: 7)
                    Circle().fill(AEColor.signal).frame(width: 7, height: 7)
                }
                Text("workspace.py")
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .foregroundStyle(AEColor.textTertiary(.dark))
                Spacer()
                Text("LOCAL CHECKS")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .tracking(0.7)
                    .foregroundStyle(accent)
            }
            .padding(.horizontal, AESpacing.md)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.035))

            TextEditor(text: $code)
                .font(.aeCode)
                .foregroundStyle(Color(hex: "D2DCF2"))
                .scrollContentBackground(.hidden)
                .padding(AESpacing.sm)
                .frame(minHeight: 230)
                .background(Color(hex: "060912"))
                .onChange(of: code) { _, _ in result = .idle }

            if let tests = challenge?.testCases, !tests.isEmpty {
                VStack(alignment: .leading, spacing: 7) {
                    ForEach(Array(tests.prefix(3).enumerated()), id: \.offset) { index, test in
                        HStack(spacing: AESpacing.xs) {
                            Image(systemName: result == .success ? "checkmark.circle.fill" : "circle.dotted")
                                .foregroundStyle(result == .success ? AEColor.signal : AEColor.textTertiary(.dark))
                            Text("Check \(index + 1)")
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                            Text("input: \(test.input) → \(test.expected)")
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundStyle(AEColor.textTertiary(.dark))
                                .lineLimit(1)
                        }
                    }
                }
                .padding(AESpacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.black.opacity(0.14))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: AERadius.medium))
        .overlay(RoundedRectangle(cornerRadius: AERadius.medium).stroke(Color.white.opacity(0.08)))
    }

    @ViewBuilder
    private func hintArea(challenge: LessonChallenge?) -> some View {
        if let hints = challenge?.hints, !hints.isEmpty {
            VStack(alignment: .leading, spacing: AESpacing.xs) {
                ForEach(Array(hints.prefix(visibleHints).enumerated()), id: \.offset) { index, hint in
                    HStack(alignment: .top, spacing: AESpacing.xs) {
                        Image(systemName: "lightbulb.fill").foregroundStyle(AEColor.amber)
                        Text("Hint \(index + 1): \(hint)")
                            .font(.aeCallout)
                            .foregroundStyle(AEColor.textSecondary(.dark))
                    }
                }

                if visibleHints < hints.count {
                    Button {
                        withAnimation(AEMotion.quick) { visibleHints += 1 }
                    } label: {
                        Label(visibleHints == 0 ? "Reveal a hint" : "Another hint", systemImage: "lightbulb")
                    }
                    .buttonStyle(.plain)
                    .font(.aeLabel)
                    .foregroundStyle(AEColor.amber)
                }
            }
        }
    }

    @ViewBuilder
    private func resultView(challenge: LessonChallenge?) -> some View {
        switch result {
        case .idle:
            EmptyView()
        case .success:
            FeedbackBanner(
                icon: "checkmark.seal.fill",
                title: "Checks passed",
                message: challenge?.explanation ?? "You’ve got it.",
                color: AEColor.signal
            )
        case .failure(let message):
            VStack(alignment: .leading, spacing: AESpacing.sm) {
                FeedbackBanner(icon: "arrow.counterclockwise", title: "Not quite yet", message: message, color: AEColor.coral)
                if attempts >= 2, challenge?.solution?.isEmpty == false, !showSolution {
                    Button("Compare with a solution") { withAnimation { showSolution = true } }
                        .buttonStyle(.plain)
                        .font(.aeLabel)
                        .foregroundStyle(accent)
                }
            }
        }
    }

    private func solutionView(_ solution: String) -> some View {
        VStack(alignment: .leading, spacing: AESpacing.xs) {
            Text("REFERENCE SOLUTION")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .tracking(0.8)
                .foregroundStyle(accent)
            ScrollView(.horizontal, showsIndicators: false) {
                Text(solution)
                    .font(.aeCode)
                    .foregroundStyle(Color(hex: "CCD7EF"))
                    .textSelection(.enabled)
            }
        }
        .padding(AESpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.18), in: RoundedRectangle(cornerRadius: AERadius.medium))
    }

    private func evaluate(_ challenge: LessonChallenge?) {
        attempts += 1
        guard let challenge else {
            result = .success
            return
        }

        if let correct = challenge.correctChoiceID {
            result = selectedChoiceID == correct
                ? .success
                : .failure("Revisit the constraints in the lesson. The strongest answer should reduce uncertainty or production risk.")
            return
        }

        if let starter = challenge.starterCode {
            let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty, trimmed != starter.trimmingCharacters(in: .whitespacesAndNewlines) else {
                result = .failure("Change the starter implementation before running the checks.")
                return
            }

            guard let solution = challenge.solution, !solution.isEmpty else {
                result = trimmed.count > 24 ? .success : .failure("Add a complete implementation, then run the checks again.")
                return
            }

            let expected = meaningfulTokens(in: solution)
            let submitted = meaningfulTokens(in: code)
            let overlap = expected.intersection(submitted)
            let ratio = Double(overlap.count) / Double(max(expected.count, 1))
            result = ratio >= 0.52
                ? .success
                : .failure("The implementation is still missing part of the expected data flow. Use a hint, then check the key inputs, outputs, and failure path.")
            return
        }

        result = .success
    }

    private func meaningfulTokens(in source: String) -> Set<String> {
        let ignored: Set<String> = ["from", "import", "return", "class", "def", "async", "await", "self", "true", "false", "none", "string", "float", "list", "dict"]
        let tokens = source.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted)
        return Set(tokens.filter { $0.count >= 4 && !ignored.contains($0) })
    }
}

private struct ConceptConfirmation: View {
    let accent: Color

    var body: some View {
        HStack(alignment: .top, spacing: AESpacing.md) {
            Image(systemName: "point.3.filled.connected.trianglepath.dotted")
                .font(.system(size: 24))
                .foregroundStyle(accent)
            VStack(alignment: .leading, spacing: 4) {
                Text("Reason before you continue")
                    .font(.aeHeading)
                    .foregroundStyle(.white)
                Text("State the trade-off in your own words. The goal is a durable mental model, not memorized syntax.")
                    .font(.aeCallout)
                    .foregroundStyle(AEColor.textSecondary(.dark))
            }
        }
        .padding(AESpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(accent.opacity(0.07), in: RoundedRectangle(cornerRadius: AERadius.medium))
    }
}

private struct FeedbackBanner: View {
    let icon: String
    let title: String
    let message: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: AESpacing.sm) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.aeLabel).foregroundStyle(color)
                Text(message).font(.aeCallout).foregroundStyle(AEColor.textSecondary(.dark))
            }
        }
        .padding(AESpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.075), in: RoundedRectangle(cornerRadius: AERadius.medium))
        .overlay(RoundedRectangle(cornerRadius: AERadius.medium).stroke(color.opacity(0.22)))
    }
}

private struct PrimaryChallengeButtonStyle: ButtonStyle {
    let accent: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .foregroundStyle(Color.black.opacity(0.82))
            .padding(.horizontal, AESpacing.lg)
            .padding(.vertical, 14)
            .background(LinearGradient(colors: [AEColor.signal, accent], startPoint: .leading, endPoint: .trailing), in: RoundedRectangle(cornerRadius: AERadius.medium))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(AEMotion.quick, value: configuration.isPressed)
    }
}

private struct LessonCompletionOverlay: View {
    let lesson: Lesson
    let course: Course
    let hasNext: Bool
    let continueAction: () -> Void
    let exitAction: () -> Void

    @State private var animate = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.78).ignoresSafeArea()
            CompletionParticles(accent: Color(hex: course.accent), animate: animate)
                .ignoresSafeArea()

            VStack(spacing: AESpacing.lg) {
                ZStack {
                    Circle()
                        .fill(AEGradient.signal)
                        .frame(width: 92, height: 92)
                        .aeGlow(color: AEColor.signal, radius: 36)
                        .scaleEffect(animate ? 1 : 0.5)
                    Image(systemName: "checkmark")
                        .font(.system(size: 34, weight: .black))
                        .foregroundStyle(Color.black.opacity(0.78))
                }

                VStack(spacing: AESpacing.xs) {
                    Text("NODE COMPLETE")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .tracking(1.4)
                        .foregroundStyle(AEColor.signal)
                    Text("+\(lesson.xp) XP")
                        .aeTextRole(.hero)
                        .foregroundStyle(.white)
                    Text(lesson.title)
                        .font(.aeHeading)
                        .foregroundStyle(AEColor.textSecondary(.dark))
                }

                Button(action: continueAction) {
                    Label(hasNext ? "Continue to next lesson" : "Finish course", systemImage: "arrow.right")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryChallengeButtonStyle(accent: Color(hex: course.accent)))

                Button("Back to course", action: exitAction)
                    .buttonStyle(.plain)
                    .font(.aeLabel)
                    .foregroundStyle(AEColor.textSecondary(.dark))
            }
            .padding(AESpacing.xl)
            .frame(maxWidth: 440)
            .aeGlassSurface(cornerRadius: 30, tint: Color(hex: course.accent), borderOpacity: 0.3)
            .padding(24)
        }
        .onAppear {
            withAnimation(.spring(response: 0.65, dampingFraction: 0.68)) { animate = true }
        }
    }
}

private struct CompletionParticles: View {
    let accent: Color
    let animate: Bool

    var body: some View {
        GeometryReader { proxy in
            ForEach(0..<18, id: \.self) { index in
                let angle = Double(index) / 18 * Double.pi * 2
                let distance = min(proxy.size.width, proxy.size.height) * (0.28 + Double(index % 3) * 0.06)
                Circle()
                    .fill(index.isMultiple(of: 2) ? accent : AEColor.signal)
                    .frame(width: CGFloat(4 + index % 4), height: CGFloat(4 + index % 4))
                    .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
                    .offset(
                        x: animate ? cos(angle) * distance : 0,
                        y: animate ? sin(angle) * distance : 0
                    )
                    .opacity(animate ? 0 : 0.9)
                    .animation(.easeOut(duration: 1.2).delay(Double(index) * 0.018), value: animate)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
