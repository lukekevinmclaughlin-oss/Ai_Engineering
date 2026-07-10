import SwiftUI

struct ProjectDetailView: View {
    @EnvironmentObject private var state: AppState
    let project: LabProject
    @State private var selectedWorkspaceTab = 0
    @State private var selectedFileIndex = 0
    @State private var editorText = ""
    @State private var editorContents: [String: String] = [:]
    @State private var consoleLines = ["Workspace ready. Complete each milestone to finish the build."]
    @State private var isRunning = false
    @State private var showTutor = false

    private var accent: Color { Color(hex: project.accent) }
    private var completedMilestones: Int {
        project.milestones.filter { state.progress.isMilestoneCompleted($0) }.count
    }

    var body: some View {
        ZStack {
            AEFrontierBackground(accent: accent, intensity: 0.45)

            ScrollView {
                VStack(alignment: .leading, spacing: AESpacing.xl) {
                    projectHero
                    if project.difficulty == "Beginner" { beginnerGuide }
                    workspace
                }
                .padding(.horizontal, 28)
                .padding(.vertical, AESpacing.lg)
                .frame(maxWidth: 1_180)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle(project.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem {
                Button { showTutor = true } label: {
                    Label("Ask Tutor", systemImage: "bubble.left.and.bubble.right.fill")
                }
            }
        }
        .sheet(isPresented: $showTutor) {
            NavigationStack {
                TutorView(initialContext: .project(project))
            }
            #if os(macOS)
            .frame(minWidth: 900, minHeight: 680)
            #endif
        }
        .onAppear { loadSelectedFile() }
    }

    private var beginnerGuide: some View {
        VStack(alignment: .leading, spacing: AESpacing.md) {
            HStack(alignment: .top, spacing: AESpacing.md) {
                Image(systemName: "figure.walk.motion")
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundStyle(AEColor.signal)
                    .frame(width: 46, height: 46)
                    .background(AEColor.signal.opacity(0.12), in: RoundedRectangle(cornerRadius: 13))

                VStack(alignment: .leading, spacing: 4) {
                    Text("BEGINNER BUILD · FULLY GUIDED")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .tracking(1)
                        .foregroundStyle(AEColor.signal)
                    Text("No setup or previous coding experience required")
                        .font(.aeHeading)
                        .foregroundStyle(.white)
                    Text("Read the brief, complete one milestone at a time, then edit the annotated starter files. Ask Tutor can explain any word, line, or error using only basic arithmetic.")
                        .font(.aeCallout)
                        .foregroundStyle(AEColor.textSecondary(.dark))
                }
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: AESpacing.sm)], spacing: AESpacing.sm) {
                BeginnerGuideStep(number: "1", title: "Understand", detail: "Read the brief")
                BeginnerGuideStep(number: "2", title: "Build", detail: "Follow milestones")
                BeginnerGuideStep(number: "3", title: "Check", detail: "Run validation")
            }
        }
        .padding(AESpacing.lg)
        .aeGlassSurface(cornerRadius: AERadius.large, tint: AEColor.signal)
    }

    private var projectHero: some View {
        VStack(alignment: .leading, spacing: AESpacing.lg) {
            HStack(alignment: .top, spacing: AESpacing.lg) {
                Image(systemName: project.icon)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(accent)
                    .frame(width: 76, height: 76)
                    .background(accent.opacity(0.11), in: RoundedRectangle(cornerRadius: 22))
                    .overlay(RoundedRectangle(cornerRadius: 22).stroke(accent.opacity(0.28)))
                    .aeGlow(color: accent, radius: 22, intensity: 0.65)

                VStack(alignment: .leading, spacing: AESpacing.sm) {
                    Text("PROJECT BRIEF · \(project.difficulty.uppercased())")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .tracking(1.1)
                        .foregroundStyle(accent)
                    Text(project.title)
                        .aeTextRole(.display)
                        .foregroundStyle(.white)
                    Text(project.summary)
                        .font(.aeBody)
                        .foregroundStyle(AEColor.textSecondary(.dark))
                }
                Spacer()
            }

            HStack(spacing: AESpacing.lg) {
                ProjectHeroMetric(value: "\(project.estimatedHours)h", label: "build time")
                ProjectHeroMetric(value: "\(project.xp)", label: "available XP")
                ProjectHeroMetric(value: "\(completedMilestones)/\(project.milestones.count)", label: "milestones")
            }

            ProgressView(value: Double(completedMilestones), total: Double(project.milestones.count))
                .tint(accent)
        }
        .padding(AESpacing.xl)
        .aeGlassSurface(cornerRadius: 28, tint: accent)
    }

    private var workspace: some View {
        VStack(alignment: .leading, spacing: AESpacing.md) {
            HStack {
                Text("PROJECT WORKSPACE")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .tracking(1.1)
                    .foregroundStyle(accent)
                Spacer()
                Label("LOCAL SANDBOX", systemImage: "lock.shield.fill")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(AEColor.textTertiary(.dark))
            }

            Picker("Workspace section", selection: $selectedWorkspaceTab) {
                Text("Brief").tag(0)
                Text("Milestones").tag(1)
                Text("Starter code").tag(2)
            }
            .pickerStyle(.segmented)

            Group {
                switch selectedWorkspaceTab {
                case 0: briefView
                case 1: milestonesView
                default: codeWorkspace
                }
            }
            .animation(AEMotion.quick, value: selectedWorkspaceTab)
        }
    }

    private var briefView: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: AESpacing.lg) {
                ProjectBriefCopy(project: project, accent: accent).frame(minWidth: 320)
                OutcomeChecklist(project: project, accent: accent).frame(minWidth: 320)
            }
            VStack(alignment: .leading, spacing: AESpacing.lg) {
                ProjectBriefCopy(project: project, accent: accent)
                OutcomeChecklist(project: project, accent: accent)
            }
        }
    }

    private var milestonesView: some View {
        VStack(spacing: AESpacing.sm) {
            ForEach(Array(project.milestones.enumerated()), id: \.element.id) { index, milestone in
                let completed = state.progress.isMilestoneCompleted(milestone)
                Button {
                    withAnimation(AEMotion.standard) { state.progress.toggleMilestone(milestone) }
                } label: {
                    HStack(spacing: AESpacing.md) {
                        ZStack {
                            Circle().fill(completed ? accent : Color.white.opacity(0.055))
                            Image(systemName: completed ? "checkmark" : milestone.systemImage)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(completed ? Color.black.opacity(0.76) : accent)
                        }
                        .frame(width: 40, height: 40)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("\(index + 1). \(milestone.title)")
                                .font(.aeHeading)
                                .foregroundStyle(.white)
                            Text(milestone.detail)
                                .font(.aeCallout)
                                .foregroundStyle(AEColor.textSecondary(.dark))
                        }
                        Spacer()
                        Image(systemName: completed ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(completed ? accent : AEColor.textTertiary(.dark))
                    }
                    .padding(AESpacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .aeGlassSurface(cornerRadius: AERadius.medium, tint: completed ? accent : nil)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var codeWorkspace: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                ForEach(Array(project.starterFiles.enumerated()), id: \.element.id) { index, file in
                    Button {
                        saveCurrentFile()
                        selectedFileIndex = index
                        loadSelectedFile()
                    } label: {
                        Label(file.name, systemImage: "doc.text.fill")
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundStyle(selectedFileIndex == index ? .white : AEColor.textTertiary(.dark))
                            .padding(.horizontal, AESpacing.md)
                            .padding(.vertical, 11)
                            .background(selectedFileIndex == index ? Color.white.opacity(0.075) : .clear)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
                Button(action: resetCurrentFile) {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundStyle(AEColor.textSecondary(.dark))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, AESpacing.sm)
                Button(action: runWorkspace) {
                    Label(isRunning ? "Running" : "Run checks", systemImage: isRunning ? "hourglass" : "play.fill")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.black.opacity(0.8))
                        .padding(.horizontal, AESpacing.md)
                        .padding(.vertical, 8)
                        .background(accent, in: Capsule())
                }
                .buttonStyle(.plain)
                .disabled(isRunning)
                .padding(.trailing, AESpacing.sm)
            }
            .background(Color.white.opacity(0.035))

            TextEditor(text: $editorText)
                .font(.aeCode)
                .foregroundStyle(Color(hex: "D0DCF4"))
                .scrollContentBackground(.hidden)
                .padding(AESpacing.md)
                .frame(minHeight: 330)
                .background(Color(hex: "060912"))
                .onChange(of: editorText) { _, newValue in
                    guard project.starterFiles.indices.contains(selectedFileIndex) else { return }
                    editorContents[project.starterFiles[selectedFileIndex].id] = newValue
                }

            VStack(alignment: .leading, spacing: 5) {
                Text("OUTPUT")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .tracking(0.8)
                    .foregroundStyle(accent)
                ForEach(Array(consoleLines.suffix(4).enumerated()), id: \.offset) { _, line in
                    Text("› \(line)")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(line.contains("✓") ? AEColor.signal : AEColor.textSecondary(.dark))
                }
            }
            .padding(AESpacing.md)
            .frame(maxWidth: .infinity, minHeight: 86, alignment: .topLeading)
            .background(Color.black.opacity(0.24))
        }
        .clipShape(RoundedRectangle(cornerRadius: AERadius.medium))
        .overlay(RoundedRectangle(cornerRadius: AERadius.medium).stroke(Color.white.opacity(0.08)))
    }

    private func loadSelectedFile() {
        guard project.starterFiles.indices.contains(selectedFileIndex) else { return }
        let file = project.starterFiles[selectedFileIndex]
        editorText = editorContents[file.id] ?? file.contents
        editorContents[file.id] = editorText
        consoleLines = ["Loaded \(file.name). Workspace ready."]
    }

    private func saveCurrentFile() {
        guard project.starterFiles.indices.contains(selectedFileIndex) else { return }
        editorContents[project.starterFiles[selectedFileIndex].id] = editorText
    }

    private func resetCurrentFile() {
        guard project.starterFiles.indices.contains(selectedFileIndex) else { return }
        let file = project.starterFiles[selectedFileIndex]
        editorContents[file.id] = file.contents
        editorText = file.contents
        consoleLines.append("Reset \(file.name) to its guided starter.")
    }

    private func runWorkspace() {
        isRunning = true
        saveCurrentFile()
        consoleLines.append("Running local structure checks…")
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(650))
            let placeholderTokens = ["NotImplementedError", "TODO", "# Your code here", "// Your code here"]
            let hasPlaceholder = placeholderTokens.contains { editorText.localizedCaseInsensitiveContains($0) }
            let changedFromStarter = project.starterFiles.indices.contains(selectedFileIndex)
                && editorText != project.starterFiles[selectedFileIndex].contents

            if editorText.count > 80, changedFromStarter, !hasPlaceholder {
                consoleLines.append("✓ You changed the guided starter")
                consoleLines.append("✓ No unfinished placeholder remains")
                consoleLines.append("✓ Ready for the milestone review")
            } else {
                consoleLines.append("Keep going: change the starter and remove its unfinished placeholder.")
                if project.difficulty == "Beginner" {
                    consoleLines.append("Open Ask Tutor if you want the next step explained.")
                }
            }
            isRunning = false
        }
    }
}

private struct BeginnerGuideStep: View {
    let number: String
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(number)
                .font(.system(size: 10, weight: .black, design: .monospaced))
                .foregroundStyle(Color.black.opacity(0.8))
                .frame(width: 24, height: 24)
                .background(AEColor.signal, in: Circle())
            Text(title)
                .font(.aeLabel)
                .foregroundStyle(.white)
            Text(detail)
                .font(.aeCaption)
                .foregroundStyle(AEColor.textTertiary(.dark))
        }
        .padding(AESpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.035), in: RoundedRectangle(cornerRadius: AERadius.small))
    }
}

private struct ProjectHeroMetric: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value).font(.aeHeading).foregroundStyle(.white)
            Text(label).font(.aeCaption).foregroundStyle(AEColor.textTertiary(.dark))
        }
    }
}

private struct ProjectBriefCopy: View {
    let project: LabProject
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: AESpacing.md) {
            Label("The assignment", systemImage: "doc.text.fill")
                .font(.aeHeading)
                .foregroundStyle(.white)
            Text(project.brief)
                .font(.aeBody)
                .foregroundStyle(AEColor.textSecondary(.dark))
            AEFlowLayout(spacing: 6) {
                ForEach(project.skills, id: \.self) { skill in
                    Text(skill)
                        .font(.aeCaption)
                        .foregroundStyle(accent)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(accent.opacity(0.075), in: Capsule())
                }
            }
        }
        .padding(AESpacing.lg)
        .frame(maxWidth: .infinity, minHeight: 250, alignment: .topLeading)
        .aeGlassSurface(tint: accent)
    }
}

private struct OutcomeChecklist: View {
    let project: LabProject
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: AESpacing.md) {
            Label("You will demonstrate", systemImage: "checkmark.seal.fill")
                .font(.aeHeading)
                .foregroundStyle(.white)
            ForEach(project.outcomes, id: \.self) { outcome in
                HStack(alignment: .top, spacing: AESpacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(accent)
                        .padding(.top, 2)
                    Text(outcome)
                        .font(.aeCallout)
                        .foregroundStyle(AEColor.textSecondary(.dark))
                }
            }
        }
        .padding(AESpacing.lg)
        .frame(maxWidth: .infinity, minHeight: 250, alignment: .topLeading)
        .aeGlassSurface(tint: accent)
    }
}
