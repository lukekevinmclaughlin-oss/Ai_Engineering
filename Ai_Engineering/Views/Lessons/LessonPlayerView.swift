import SwiftUI
#if !DIRECT_DISTRIBUTION
import StoreKit
#endif

struct LessonPlayerView: View {
    @EnvironmentObject private var state: AppState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    #if !DIRECT_DISTRIBUTION
    @Environment(\.requestReview) private var requestReview
    #endif

    let course: Course
    @State private var currentIndex: Int
    @State private var showContextualPaywall = false
    @State private var showCompletion = false
    @State private var showTutor = false

    init(course: Course, moduleIndex: Int, lessonIndex: Int) {
        self.course = course
        let precedingLessons = course.modules.prefix(moduleIndex).reduce(0) { $0 + $1.lessons.count }
        _currentIndex = State(initialValue: min(precedingLessons + lessonIndex, max(course.lessons.count - 1, 0)))
    }

    private var lesson: Lesson { course.lessons[currentIndex] }
    private var accent: Color { Color(hex: course.accent) }
    private var textAccent: Color { AEColor.readableAccent(course.accent, colorScheme) }
    private var assemblySnapshot: AIAssemblyProgress {
        AIAssemblyProgress(
            courses: state.curriculum.courses,
            projects: state.projects,
            completedLessonIDs: state.progress.value.completedLessonIDs,
            completedMilestoneIDs: state.progress.value.completedMilestoneIDs
        )
    }

    var body: some View {
        ZStack {
            AEFrontierBackground(accent: accent, intensity: 0.46)

            VStack(spacing: 0) {
                lessonHeader
                Divider().overlay(AEColor.stroke(colorScheme))
                lessonLayout
            }

            if showCompletion {
                LessonCompletionOverlay(
                    lesson: lesson,
                    course: course,
                    assemblyProgress: assemblySnapshot.fractionComplete,
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
        .sheet(isPresented: $showContextualPaywall) {
            SubscriptionPaywallView(store: state.subscription)
                #if os(macOS)
                .frame(minWidth: 900, minHeight: 620)
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
                        .background(AEColor.surface(colorScheme), in: Circle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(AEColor.textSecondary(colorScheme))

                VStack(alignment: .leading, spacing: 2) {
                    Text(course.title.uppercased())
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .tracking(0.9)
                        .foregroundStyle(textAccent)
                    Text(lesson.title)
                        .font(.aeCallout)
                        .foregroundStyle(AEColor.textPrimary(colorScheme))
                        .lineLimit(1)
                }

                Spacer()

                Button { showTutor = true } label: {
                    ViewThatFits(in: .horizontal) {
                        Label("Ask Tutor", systemImage: "bubble.left.and.bubble.right.fill")
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                    }
                    .font(.aeLabel)
                    .foregroundStyle(AEColor.readableViolet(colorScheme))
                    .padding(.horizontal, 10)
                    .frame(height: 32)
                    .background(AEColor.violet.opacity(0.09), in: Capsule())
                    .overlay(Capsule().stroke(AEColor.violet.opacity(0.18)))
                }
                .buttonStyle(.plain)

                Label("\(lesson.xp) XP", systemImage: "bolt.fill")
                    .font(.aeLabel)
                    .foregroundStyle(AEColor.readableSignal(colorScheme))
                Text("\(currentIndex + 1) / \(course.lessonCount)")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(AEColor.textTertiary(colorScheme))
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(AEColor.stroke(colorScheme))
                    Capsule()
                        .fill(AEGradient.spectral)
                        .frame(width: proxy.size.width * Double(currentIndex + 1) / Double(max(course.lessonCount, 1)))
                        .animation(reduceMotion ? nil : AEMotion.standard, value: currentIndex)
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
                LessonContentPane(lesson: lesson, accent: accent, textAccent: textAccent)
                    .padding(AESpacing.xl)
                    .frame(maxWidth: 680, alignment: .leading)
                    .frame(maxWidth: .infinity, alignment: .top)
            }
            .frame(minWidth: 360, idealWidth: 500)

            ScrollView {
                ChallengePanel(lesson: lesson, accent: accent, textAccent: textAccent) {
                    completeLesson()
                }
                .id(lesson.id)
                .padding(AESpacing.xl)
                .frame(maxWidth: 700)
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .frame(minWidth: 420, idealWidth: 600)
            .background(AEColor.surface(colorScheme).opacity(0.32))
        }
        #else
        ScrollView {
            VStack(spacing: AESpacing.xl) {
                LessonContentPane(lesson: lesson, accent: accent, textAccent: textAccent)
                ChallengePanel(lesson: lesson, accent: accent, textAccent: textAccent) {
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
        // Freemium: one contextual Pro offer, right after the first finished lesson.
        if !state.subscription.hasAccess,
           !state.subscription.isCheckingAccess,
           !UserDefaults.standard.bool(forKey: "freemium.offer.shown") {
            UserDefaults.standard.set(true, forKey: "freemium.offer.shown")
            showContextualPaywall = true
        }
        #if !DIRECT_DISTRIBUTION
        if ReviewPromptPolicy.shouldRequest(
            completedLessonCount: state.progress.completedLessonCount,
            paywallWillBePresented: showContextualPaywall
        ) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                requestReview()
            }
        }
        #endif
        withAnimation(reduceMotion ? nil : AEMotion.standard) { showCompletion = true }
    }

    private func advance() {
        guard currentIndex < course.lessons.count - 1 else {
            dismiss()
            return
        }
        withAnimation(reduceMotion ? nil : AEMotion.standard) {
            showCompletion = false
            currentIndex += 1
        }
    }
}

private struct LessonContentPane: View {
    let lesson: Lesson
    let accent: Color
    let textAccent: Color

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: AESpacing.lg) {
            HStack(spacing: AESpacing.sm) {
                Image(systemName: lesson.kind.systemImage)
                    .foregroundStyle(textAccent)
                    .frame(width: 38, height: 38)
                    .background(accent.opacity(0.11), in: RoundedRectangle(cornerRadius: 11))
                VStack(alignment: .leading, spacing: 2) {
                    Text(lesson.kind.title.uppercased())
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .tracking(1)
                        .foregroundStyle(textAccent)
                    Text("\(lesson.estimatedMinutes) minute lesson")
                        .font(.aeCaption)
                        .foregroundStyle(AEColor.textTertiary(colorScheme))
                }
            }

            LessonKindVisual(kind: lesson.kind, accent: accent, textAccent: textAccent)

            Text(lesson.title)
                .aeTextRole(.display)
                .foregroundStyle(AEColor.textPrimary(colorScheme))
                .fixedSize(horizontal: false, vertical: true)

            Text(lesson.summary)
                .aeTextRole(.body)
                .foregroundStyle(AEColor.textSecondary(colorScheme))

            Divider().overlay(AEColor.stroke(colorScheme))

            ForEach(Array(lesson.contentBlocks.enumerated()), id: \.offset) { _, block in
                LessonBlockView(block: block, accent: accent, textAccent: textAccent)
            }
        }
    }
}

private struct LessonBlockView: View {
    let block: LessonContentBlock
    let accent: Color
    let textAccent: Color

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        switch block.type {
        case .heading:
            Text(block.text)
                .font(.aeHeading)
                .foregroundStyle(AEColor.textPrimary(colorScheme))
                .padding(.top, AESpacing.xs)
        case .paragraph:
            Text(block.text)
                .font(.aeBody)
                .foregroundStyle(AEColor.textSecondary(colorScheme))
                .textSelection(.enabled)
        case .callout:
            HStack(alignment: .top, spacing: AESpacing.md) {
                Image(systemName: calloutIcon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(textAccent)
                    .frame(width: 34, height: 34)
                    .background(accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                VStack(alignment: .leading, spacing: 4) {
                    Text(calloutLabel)
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .tracking(0.85)
                        .foregroundStyle(textAccent)
                    Text(block.text)
                        .font(.aeCallout)
                        .foregroundStyle(AEColor.textPrimary(colorScheme))
                }
            }
            .padding(AESpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(accent.opacity(0.075), in: RoundedRectangle(cornerRadius: AERadius.medium))
            .overlay(RoundedRectangle(cornerRadius: AERadius.medium).stroke(accent.opacity(0.2)))
        case .code:
            let language = CodeLanguage.inferred(from: block.text, hint: block.language)
            AESyntaxCodeBlock(
                code: block.text,
                language: language,
                title: language.preferredFileName,
                accent: accent,
                labelAccent: textAccent
            )
        case .bullets:
            VStack(alignment: .leading, spacing: 10) {
                if !block.text.isEmpty {
                    Text(block.text)
                        .font(.aeCallout)
                        .foregroundStyle(AEColor.textPrimary(colorScheme))
                }
                let items = block.items ?? []
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    NumberedLearningPoint(
                        index: index + 1,
                        text: item,
                        isLast: index == items.count - 1,
                        accent: accent,
                        textAccent: textAccent
                    )
                }
            }
        }
    }

    private var calloutIcon: String {
        let normalized = block.text.lowercased()
        if normalized.contains("risk") || normalized.contains("warning") || normalized.contains("avoid") {
            return "exclamationmark.triangle.fill"
        }
        if normalized.contains("example") { return "eye.fill" }
        if normalized.contains("remember") || normalized.contains("key ") { return "key.fill" }
        return "lightbulb.fill"
    }

    private var calloutLabel: String {
        let normalized = block.text.lowercased()
        if normalized.contains("risk") || normalized.contains("warning") || normalized.contains("avoid") {
            return "WATCH FOR THIS"
        }
        if normalized.contains("example") { return "EXAMPLE LENS" }
        if normalized.contains("remember") || normalized.contains("key ") { return "KEY IDEA" }
        return "FIELD NOTE"
    }
}

private struct LessonKindVisual: View {
    let kind: LessonKind
    let accent: Color
    let textAccent: Color

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var label: String {
        switch kind {
        case .concept: "CONNECT THE IDEA"
        case .quiz: "TEST THE SIGNAL"
        case .code: "TRACE THE DATA FLOW"
        case .architecture: "MAP THE SYSTEM"
        }
    }

    private var detail: String {
        switch kind {
        case .concept: "Mental model"
        case .quiz: "Recall loop"
        case .code: "Executable path"
        case .architecture: "System topology"
        }
    }

    var body: some View {
        TimelineView(
            .animation(
                minimumInterval: ProcessInfo.processInfo.isLowPowerModeEnabled ? 0.5 : 1.0 / 15.0,
                paused: reduceMotion
            )
        ) { timeline in
            let phase = reduceMotion ? 0.25 : timeline.date.timeIntervalSinceReferenceDate
            ZStack(alignment: .topLeading) {
                Canvas { context, size in
                    drawGrid(context: context, size: size)
                    switch kind {
                    case .concept: drawConcept(context: context, size: size, phase: phase)
                    case .quiz: drawQuiz(context: context, size: size, phase: phase)
                    case .code: drawCode(context: context, size: size, phase: phase)
                    case .architecture: drawArchitecture(context: context, size: size, phase: phase)
                    }
                }
                .accessibilityHidden(true)

                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(label)
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .tracking(1)
                            .foregroundStyle(textAccent)
                        Text(detail)
                            .font(.aeCaption)
                            .foregroundStyle(AEColor.textSecondary(colorScheme))
                    }
                    Spacer()
                    Image(systemName: kind.systemImage)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(textAccent)
                        .frame(width: 34, height: 34)
                        .background(accent.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
                }
                .padding(13)
            }
        }
        .frame(height: 116)
        .background(
            LinearGradient(
                colors: [AEColor.surface(colorScheme).opacity(0.92), accent.opacity(colorScheme == .dark ? 0.07 : 0.045)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: AERadius.medium, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: AERadius.medium, style: .continuous)
                .stroke(AEColor.stroke(colorScheme), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: AERadius.medium, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(kind.title), \(detail)")
    }

    private func drawGrid(context: GraphicsContext, size: CGSize) {
        var grid = Path()
        stride(from: CGFloat(18), through: size.width, by: 36).forEach { x in
            grid.move(to: CGPoint(x: x, y: 0))
            grid.addLine(to: CGPoint(x: x, y: size.height))
        }
        stride(from: CGFloat(18), through: size.height, by: 36).forEach { y in
            grid.move(to: CGPoint(x: 0, y: y))
            grid.addLine(to: CGPoint(x: size.width, y: y))
        }
        context.stroke(grid, with: .color(AEColor.stroke(colorScheme).opacity(0.45)), lineWidth: 0.5)
    }

    private func drawConcept(context: GraphicsContext, size: CGSize, phase: Double) {
        let center = CGPoint(x: size.width * 0.68, y: size.height * 0.58)
        let radius = min(size.width * 0.2, 44)
        let points = (0..<6).map { index -> CGPoint in
            let angle = Double(index) / 6 * .pi * 2 + phase * 0.12
            return CGPoint(x: center.x + cos(angle) * radius, y: center.y + sin(angle) * radius * 0.65)
        }
        var links = Path()
        for index in points.indices {
            links.move(to: points[index])
            links.addLine(to: points[(index + 2) % points.count])
            links.move(to: center)
            links.addLine(to: points[index])
        }
        context.stroke(links, with: .color(accent.opacity(0.28)), lineWidth: 1)
        node(context: context, point: center, radius: 6 + sin(phase * 2) * 1.2, color: AEColor.signal)
        for (index, point) in points.enumerated() {
            node(context: context, point: point, radius: index.isMultiple(of: 2) ? 4 : 3, color: index.isMultiple(of: 2) ? accent : AEColor.azure)
        }
    }

    private func drawQuiz(context: GraphicsContext, size: CGSize, phase: Double) {
        let startX = size.width * 0.5
        let midY = size.height * 0.62
        var signal = Path()
        signal.move(to: CGPoint(x: startX, y: midY))
        let width = max(size.width - startX - 18, 1)
        for step in 0...36 {
            let fraction = CGFloat(step) / 36
            let x = startX + width * fraction
            let envelope = sin(Double(fraction) * .pi)
            let y = midY + sin(Double(fraction) * .pi * 7 + phase * 2.2) * 15 * envelope
            signal.addLine(to: CGPoint(x: x, y: y))
        }
        context.stroke(signal, with: .color(accent.opacity(0.8)), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        let scanX = startX + width * CGFloat((phase * 0.18).truncatingRemainder(dividingBy: 1))
        node(context: context, point: CGPoint(x: scanX, y: midY), radius: 4, color: AEColor.signal)
        let ring = CGRect(x: size.width * 0.72 - 18, y: midY - 18, width: 36, height: 36)
        context.stroke(Path(ellipseIn: ring), with: .color(AEColor.azure.opacity(0.22)), lineWidth: 1)
    }

    private func drawCode(context: GraphicsContext, size: CGSize, phase: Double) {
        let y = size.height * 0.64
        let startX = size.width * 0.48
        let endX = size.width - 22
        let points = (0..<4).map { index in
            CGPoint(x: startX + (endX - startX) * CGFloat(index) / 3, y: y + (index.isMultiple(of: 2) ? -10 : 10))
        }
        var path = Path()
        path.move(to: points[0])
        points.dropFirst().forEach { path.addLine(to: $0) }
        context.stroke(path, with: .color(accent.opacity(0.38)), style: StrokeStyle(lineWidth: 1.5, dash: [4, 5]))
        for (index, point) in points.enumerated() {
            let rect = CGRect(x: point.x - 13, y: point.y - 9, width: 26, height: 18)
            context.fill(Path(roundedRect: rect, cornerRadius: 5), with: .color((index == 3 ? AEColor.signal : accent).opacity(0.18)))
            context.stroke(Path(roundedRect: rect, cornerRadius: 5), with: .color(index == 3 ? AEColor.signal : accent.opacity(0.62)), lineWidth: 1)
        }
        let t = CGFloat((phase * 0.22).truncatingRemainder(dividingBy: 1))
        let segment = min(Int(t * 3), 2)
        let local = t * 3 - CGFloat(segment)
        let a = points[segment]
        let b = points[segment + 1]
        node(context: context, point: CGPoint(x: a.x + (b.x - a.x) * local, y: a.y + (b.y - a.y) * local), radius: 3.5, color: AEColor.signal)
    }

    private func drawArchitecture(context: GraphicsContext, size: CGSize, phase: Double) {
        let columns: [[CGPoint]] = [
            [CGPoint(x: size.width * 0.50, y: 62)],
            [CGPoint(x: size.width * 0.68, y: 47), CGPoint(x: size.width * 0.68, y: 83)],
            [CGPoint(x: size.width * 0.87, y: 38), CGPoint(x: size.width * 0.87, y: 62), CGPoint(x: size.width * 0.87, y: 88)]
        ]
        var links = Path()
        for columnIndex in 0..<(columns.count - 1) {
            for source in columns[columnIndex] {
                for destination in columns[columnIndex + 1] {
                    links.move(to: source)
                    links.addLine(to: destination)
                }
            }
        }
        context.stroke(links, with: .color(accent.opacity(0.27 + sin(phase) * 0.05)), lineWidth: 1)
        for (column, points) in columns.enumerated() {
            for point in points {
                node(context: context, point: point, radius: column == 0 ? 5 : 3.5, color: column == 2 ? AEColor.azure : accent)
            }
        }
    }

    private func node(context: GraphicsContext, point: CGPoint, radius: CGFloat, color: Color) {
        let rect = CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)
        context.fill(Path(ellipseIn: rect), with: .color(color))
        context.stroke(Path(ellipseIn: rect.insetBy(dx: -3, dy: -3)), with: .color(color.opacity(0.18)), lineWidth: 1)
    }
}

private struct NumberedLearningPoint: View {
    let index: Int
    let text: String
    let isLast: Bool
    let accent: Color
    let textAccent: Color

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(alignment: .top, spacing: AESpacing.sm) {
            VStack(spacing: 4) {
                Text("\(index)")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(textAccent)
                    .frame(width: 26, height: 26)
                    .background(accent.opacity(0.1), in: Circle())
                    .overlay(Circle().stroke(accent.opacity(0.28)))
                if !isLast {
                    Rectangle()
                        .fill(LinearGradient(colors: [accent.opacity(0.42), accent.opacity(0.06)], startPoint: .top, endPoint: .bottom))
                        .frame(width: 1)
                        .frame(minHeight: 18)
                }
            }
            Text(text)
                .font(.aeCallout)
                .foregroundStyle(AEColor.textSecondary(colorScheme))
                .padding(.top, 3)
                .padding(.bottom, isLast ? 0 : 8)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Step \(index). \(text)")
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
    let textAccent: Color
    let completion: () -> Void

    @State private var selectedChoiceID: String?
    @State private var code: String
    @State private var result: ChallengeResult = .idle
    @State private var visibleHints = 0
    @State private var attempts = 0
    @State private var showSolution = false
    @State private var isEvaluating = false

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var challengeLanguage: CodeLanguage {
        let hint = lesson.contentBlocks.first(where: { $0.type == .code })?.language
        return CodeLanguage.inferred(from: code, hint: hint)
    }

    init(lesson: Lesson, accent: Color, textAccent: Color, completion: @escaping () -> Void) {
        self.lesson = lesson
        self.accent = accent
        self.textAccent = textAccent
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
                        .foregroundStyle(textAccent)
                    Text(challenge?.prompt ?? "Apply what you learned")
                        .font(.aeTitle)
                        .foregroundStyle(AEColor.textPrimary(colorScheme))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Image(systemName: "terminal.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(textAccent)
            }

            Text(challenge?.instructions ?? "Review the concept, then mark this node complete.")
                .font(.aeBody)
                .foregroundStyle(AEColor.textSecondary(colorScheme))

            if let choices = challenge?.choices, !choices.isEmpty {
                choiceList(choices)
            } else if challenge?.starterCode != nil {
                codeEditor(challenge: challenge)
            } else {
                ConceptConfirmation(accent: textAccent)
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
                        Group {
                            if isEvaluating {
                                HStack(spacing: 9) {
                                    ProgressView().controlSize(.small).tint(Color.black.opacity(0.8))
                                    Text("Running local checks…")
                                }
                            } else {
                                Label(challenge?.starterCode == nil && challenge?.choices == nil ? "Mark understood" : "Check answer", systemImage: "play.fill")
                            }
                        }
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryChallengeButtonStyle(accent: accent))
                    .disabled(isEvaluating || (challenge?.choices != nil && selectedChoiceID == nil))
                    .opacity(challenge?.choices != nil && selectedChoiceID == nil ? 0.55 : 1)
                }
            }
        }
        .padding(AESpacing.lg)
        .aeGlassSurface(cornerRadius: AERadius.large, tint: accent)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.24), value: result)
    }

    private func choiceList(_ choices: [ChallengeChoice]) -> some View {
        VStack(spacing: AESpacing.sm) {
            ForEach(Array(choices.enumerated()), id: \.element.id) { index, choice in
                Button {
                    withAnimation(reduceMotion ? nil : AEMotion.quick) {
                        selectedChoiceID = choice.id
                        result = .idle
                    }
                } label: {
                    HStack(spacing: AESpacing.md) {
                        Text(String(UnicodeScalar(65 + index)!))
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundStyle(selectedChoiceID == choice.id ? Color.black.opacity(0.8) : textAccent)
                            .frame(width: 30, height: 30)
                            .background(selectedChoiceID == choice.id ? AnyShapeStyle(accent) : AnyShapeStyle(accent.opacity(0.1)), in: RoundedRectangle(cornerRadius: 9))
                        Text(choice.text)
                            .font(.aeCallout)
                            .foregroundStyle(AEColor.textPrimary(colorScheme))
                            .multilineTextAlignment(.leading)
                        Spacer()
                        Image(systemName: selectedChoiceID == choice.id ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(selectedChoiceID == choice.id ? textAccent : AEColor.textTertiary(colorScheme))
                    }
                    .padding(AESpacing.md)
                    .background(selectedChoiceID == choice.id ? accent.opacity(0.08) : AEColor.surface(colorScheme).opacity(0.7), in: RoundedRectangle(cornerRadius: AERadius.medium))
                    .overlay(RoundedRectangle(cornerRadius: AERadius.medium).stroke(selectedChoiceID == choice.id ? accent.opacity(0.45) : AEColor.stroke(colorScheme)))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func codeEditor(challenge: LessonChallenge?) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            AESyntaxCodeEditor(
                text: $code,
                language: challengeLanguage,
                fileName: challengeLanguage.preferredFileName.replacingOccurrences(of: "example", with: "workspace"),
                accent: accent,
                labelAccent: textAccent,
                minHeight: 230,
                isRunning: isEvaluating
            )
            .onChange(of: code) { _, _ in result = .idle }

            if let tests = challenge?.testCases, !tests.isEmpty {
                VStack(alignment: .leading, spacing: 7) {
                    ForEach(Array(tests.prefix(3).enumerated()), id: \.offset) { index, test in
                        HStack(spacing: AESpacing.xs) {
                            Image(systemName: result == .success ? "checkmark.circle.fill" : "circle.dotted")
                                .foregroundStyle(result == .success ? AEColor.readableSignal(colorScheme) : AEColor.textTertiary(colorScheme))
                            Text("Check \(index + 1)")
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                            Text("input: \(test.input) → \(test.expected)")
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundStyle(AEColor.textTertiary(colorScheme))
                                .lineLimit(1)
                        }
                    }
                }
                .padding(AESpacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AEColor.surface(colorScheme).opacity(0.72))
            }
        }
    }

    @ViewBuilder
    private func hintArea(challenge: LessonChallenge?) -> some View {
        if let hints = challenge?.hints, !hints.isEmpty {
            VStack(alignment: .leading, spacing: AESpacing.xs) {
                ForEach(Array(hints.prefix(visibleHints).enumerated()), id: \.offset) { index, hint in
                    HStack(alignment: .top, spacing: AESpacing.xs) {
                        Image(systemName: "lightbulb.fill").foregroundStyle(AEColor.readableAmber(colorScheme))
                        Text("Hint \(index + 1): \(hint)")
                            .font(.aeCallout)
                            .foregroundStyle(AEColor.textSecondary(colorScheme))
                    }
                }

                if visibleHints < hints.count {
                    Button {
                        withAnimation(reduceMotion ? nil : AEMotion.quick) { visibleHints += 1 }
                    } label: {
                        Label(visibleHints == 0 ? "Reveal a hint" : "Another hint", systemImage: "lightbulb")
                    }
                    .buttonStyle(.plain)
                    .font(.aeLabel)
                    .foregroundStyle(AEColor.readableAmber(colorScheme))
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
                color: AEColor.readableSignal(colorScheme)
            )
        case .failure(let message):
            VStack(alignment: .leading, spacing: AESpacing.sm) {
                FeedbackBanner(icon: "arrow.counterclockwise", title: "Not quite yet", message: message, color: AEColor.readableCoral(colorScheme))
                if attempts >= 2, challenge?.solution?.isEmpty == false, !showSolution {
                    Button("Compare with a solution") {
                        withAnimation(reduceMotion ? nil : AEMotion.quick) { showSolution = true }
                    }
                        .buttonStyle(.plain)
                        .font(.aeLabel)
                        .foregroundStyle(textAccent)
                }
            }
        }
    }

    private func solutionView(_ solution: String) -> some View {
        VStack(alignment: .leading, spacing: AESpacing.sm) {
            Text("REFERENCE SOLUTION")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .tracking(0.8)
                .foregroundStyle(textAccent)
            AESyntaxCodeBlock(
                code: solution,
                language: CodeLanguage.inferred(from: solution, hint: challengeLanguage.rawValue),
                title: "solution.\(challengeLanguage.preferredFileName.components(separatedBy: ".").last ?? "txt")",
                accent: accent,
                labelAccent: textAccent
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func evaluate(_ challenge: LessonChallenge?) {
        attempts += 1
        isEvaluating = true
        result = .idle
        Task { @MainActor in
            if !reduceMotion { try? await Task.sleep(for: .milliseconds(320)) }
            withAnimation(reduceMotion ? nil : .spring(response: 0.34, dampingFraction: 0.82)) {
                performEvaluation(challenge)
                isEvaluating = false
            }
        }
    }

    private func performEvaluation(_ challenge: LessonChallenge?) {
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

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(alignment: .top, spacing: AESpacing.md) {
            Image(systemName: "point.3.filled.connected.trianglepath.dotted")
                .font(.system(size: 24))
                .foregroundStyle(accent)
            VStack(alignment: .leading, spacing: 4) {
                Text("Reason before you continue")
                    .font(.aeHeading)
                    .foregroundStyle(AEColor.textPrimary(colorScheme))
                Text("State the trade-off in your own words. The goal is a durable mental model, not memorized syntax.")
                    .font(.aeCallout)
                    .foregroundStyle(AEColor.textSecondary(colorScheme))
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

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(alignment: .top, spacing: AESpacing.sm) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.aeLabel).foregroundStyle(color)
                Text(message).font(.aeCallout).foregroundStyle(AEColor.textSecondary(colorScheme))
            }
        }
        .padding(AESpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.075), in: RoundedRectangle(cornerRadius: AERadius.medium))
        .overlay(RoundedRectangle(cornerRadius: AERadius.medium).stroke(color.opacity(0.22)))
    }
}

private struct PrimaryChallengeButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let accent: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .foregroundStyle(Color.black.opacity(0.82))
            .padding(.horizontal, AESpacing.lg)
            .padding(.vertical, 14)
            .background(LinearGradient(colors: [AEColor.signal, accent], startPoint: .leading, endPoint: .trailing), in: RoundedRectangle(cornerRadius: AERadius.medium))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(reduceMotion ? nil : AEMotion.quick, value: configuration.isPressed)
    }
}

private struct LessonCompletionOverlay: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let lesson: Lesson
    let course: Course
    let assemblyProgress: Double
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

                AIComponentInstalledBadge(
                    progress: assemblyProgress,
                    componentName: "Lesson component installed"
                )

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
            withAnimation(reduceMotion ? nil : .spring(response: 0.65, dampingFraction: 0.68)) {
                animate = true
            }
        }
    }
}

private struct CompletionParticles: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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
                    .animation(
                        reduceMotion ? nil : .easeOut(duration: 1.2).delay(Double(index) * 0.018),
                        value: animate
                    )
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
