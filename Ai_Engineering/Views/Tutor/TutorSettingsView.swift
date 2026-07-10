import SwiftUI

struct TutorSettingsView: View {
    @ObservedObject var tutor: TutorCoordinator
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var credential = ""
    @State private var apiStatus: String?
    @State private var localStatus: String?
    @State private var detectedModels: [String] = []
    @State private var isDetectingLocalServer = false
    @State private var detectionRequestID: UUID?
    @State private var detectionTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            AEFrontierBackground(accent: AEColor.violet, intensity: 0.48)

            ScrollView {
                VStack(alignment: .leading, spacing: AESpacing.xl) {
                    header
                    privacyPromise
                    engineSelection
                    teachingStyle
                    connectionSetup
                }
                .padding(AESpacing.xl)
                .frame(maxWidth: 920)
                .frame(maxWidth: .infinity)
            }
        }
        #if os(macOS)
        .frame(minWidth: 760, idealWidth: 880, minHeight: 680, idealHeight: 780)
        #endif
        .onDisappear { cancelLocalDetection() }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: AESpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AEColor.violet.opacity(0.14))
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 23, weight: .semibold))
                    .foregroundStyle(AEGradient.spectral)
            }
            .frame(width: 54, height: 54)

            VStack(alignment: .leading, spacing: 4) {
                Text("TUTOR SETTINGS")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .tracking(1.2)
                    .foregroundStyle(AEColor.readableViolet(colorScheme))
                Text("Choose how Tutor Core thinks")
                    .aeTextRole(.display)
                    .foregroundStyle(AEColor.textPrimary(colorScheme))
                Text("Offline is the default. No account, key, or subscription is required.")
                    .font(.aeBody)
                    .foregroundStyle(AEColor.textSecondary(colorScheme))
            }

            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark")
            }
            .buttonStyle(AEIconButtonStyle())
            .accessibilityLabel("Close settings")
        }
    }

    private var privacyPromise: some View {
        HStack(alignment: .top, spacing: AESpacing.md) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 22))
                .foregroundStyle(AEColor.readableSignal(colorScheme))
            VStack(alignment: .leading, spacing: 5) {
                Text("Local-first by design")
                    .font(.aeHeading)
                    .foregroundStyle(AEColor.textPrimary(colorScheme))
                Text("Offline Core and Apple On-Device keep questions on this device. Ai_Engineering never silently falls through to a network service. Network access occurs only after you explicitly connect an API provider or local model server and select Connected Provider.")
                    .font(.aeCallout)
                    .foregroundStyle(AEColor.textSecondary(colorScheme))
            }
        }
        .padding(AESpacing.lg)
        .aeGlassSurface(cornerRadius: AERadius.large, tint: AEColor.signal)
    }

    private var engineSelection: some View {
        SettingsSection(
            eyebrow: "REASONING ENGINE",
            title: "Your tutor, your device",
            detail: "Automatic never selects a connected provider. It chooses Apple On-Device when available and Offline Core everywhere else."
        ) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 250), spacing: AESpacing.md)], spacing: AESpacing.md) {
                ForEach(TutorEngineChoice.allCases) { engine in
                    engineCard(engine)
                }
            }
        }
    }

    private func engineCard(_ engine: TutorEngineChoice) -> some View {
        let selected = tutor.preferences.engine == engine
        let status = engineStatus(engine)

        return Button {
            withAnimation(AEMotion.quick) { tutor.preferences.engine = engine }
        } label: {
            VStack(alignment: .leading, spacing: AESpacing.md) {
                HStack {
                    Image(systemName: engine.systemImage)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(selected ? AEColor.readableSignal(colorScheme) : AEColor.readableViolet(colorScheme))
                        .frame(width: 38, height: 38)
                        .background((selected ? AEColor.signal : AEColor.violet).opacity(0.12), in: RoundedRectangle(cornerRadius: 11))
                    Spacer()
                    Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(selected ? AEColor.readableSignal(colorScheme) : AEColor.textTertiary(colorScheme))
                }

                Text(engine.title)
                    .font(.aeHeading)
                    .foregroundStyle(AEColor.textPrimary(colorScheme))
                Text(engine.detail)
                    .font(.aeCaption)
                    .foregroundStyle(AEColor.textSecondary(colorScheme))
                    .fixedSize(horizontal: false, vertical: true)
                Text(status)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(engine == .connectedProvider && tutor.providerIsReady ? AEColor.readableAmber(colorScheme) : AEColor.readableSignal(colorScheme))
            }
            .padding(AESpacing.md)
            .frame(maxWidth: .infinity, minHeight: 190, alignment: .topLeading)
            .background(AEColor.subtleFill(colorScheme).opacity(selected ? 1.3 : 0.74), in: RoundedRectangle(cornerRadius: AERadius.medium))
            .overlay {
                RoundedRectangle(cornerRadius: AERadius.medium)
                    .stroke(selected ? AEColor.signal.opacity(0.55) : AEColor.stroke(colorScheme), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private func engineStatus(_ engine: TutorEngineChoice) -> String {
        switch engine {
        case .automatic: "OFFLINE-SAFE ROUTING"
        case .offlineCore: "ALWAYS READY"
        case .appleOnDevice: tutor.appleAvailability.title.uppercased()
        case .connectedProvider:
            tutor.providerIsReady ? "OPTIONAL NETWORK ENABLED" : "NOT CONNECTED"
        }
    }

    private var teachingStyle: some View {
        SettingsSection(
            eyebrow: "TEACHING STYLE",
            title: "Meet you where you are",
            detail: "You can change these at any time without losing the conversation."
        ) {
            VStack(spacing: AESpacing.lg) {
                settingsPicker(
                    title: "Starting knowledge",
                    detail: "First steps assumes only basic arithmetic.",
                    selection: Binding(
                        get: { tutor.preferences.learnerLevel },
                        set: { tutor.preferences.learnerLevel = $0 }
                    ),
                    options: TutorLearnerLevel.allCases
                )

                settingsPicker(
                    title: "Answer depth",
                    detail: "Deep dive adds mechanics, examples, trade-offs, and failure modes.",
                    selection: Binding(
                        get: { tutor.preferences.answerDepth },
                        set: { tutor.preferences.answerDepth = $0 }
                    ),
                    options: TutorAnswerDepth.allCases
                )
            }
        }
    }

    private func settingsPicker<Option: Hashable & Identifiable>(
        title: String,
        detail: String,
        selection: Binding<Option>,
        options: [Option]
    ) -> some View where Option.ID == String {
        VStack(alignment: .leading, spacing: AESpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.aeHeading).foregroundStyle(AEColor.textPrimary(colorScheme))
                    Text(detail).font(.aeCaption).foregroundStyle(AEColor.textSecondary(colorScheme))
                }
                Spacer()
            }

            Picker(title, selection: selection) {
                ForEach(options) { option in
                    Text(optionTitle(option)).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
        }
        .padding(AESpacing.md)
        .background(AEColor.subtleFill(colorScheme), in: RoundedRectangle(cornerRadius: AERadius.medium))
    }

    private func optionTitle<Option>(_ option: Option) -> String {
        if let level = option as? TutorLearnerLevel { return level.title }
        if let depth = option as? TutorAnswerDepth { return depth.title }
        return String(describing: option)
    }

    private var connectionSetup: some View {
        SettingsSection(
            eyebrow: "OPTIONAL CONNECTIONS",
            title: "Two explicit ways to connect",
            detail: "Neither path is required. Offline Core and Apple On-Device remain the default and Automatic mode never chooses a network connection."
        ) {
            VStack(spacing: AESpacing.lg) {
                apiConnectionCard
                localServerCard

                HStack(alignment: .top, spacing: AESpacing.sm) {
                    Image(systemName: "exclamationmark.shield.fill")
                        .foregroundStyle(AEColor.readableAmber(colorScheme))
                    Text("API keys are user-supplied, stored in this device’s Keychain, and bound to the selected endpoint origin. A key is never followed across a cross-origin redirect. Never embed a shared production key in the app.")
                        .font(.aeCaption)
                        .foregroundStyle(AEColor.textSecondary(colorScheme))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var apiConnectionCard: some View {
        VStack(alignment: .leading, spacing: AESpacing.lg) {
            connectionHeader(
                number: "1",
                icon: "key.horizontal.fill",
                title: "API provider",
                detail: "Choose a provider, enter your own API key and model ID, then connect. Only tutor requests you send while Connected Provider is selected leave this device."
            )

            VStack(alignment: .leading, spacing: AESpacing.sm) {
                Text("Provider").font(.aeLabel).foregroundStyle(AEColor.textPrimary(colorScheme))
                Picker("API provider", selection: Binding(
                    get: { tutor.providerConfiguration.apiProvider },
                    set: { selectAPIProvider($0) }
                )) {
                    ForEach(TutorAPIProvider.allCases) { provider in
                        Text(provider.title).tag(provider)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AEColor.inputFill(colorScheme), in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AEColor.strokeStrong(colorScheme)))
            }

            if tutor.providerConfiguration.apiProvider == .customOpenAICompatible {
                field(
                    "Chat completions URL",
                    text: Binding(
                        get: {
                            tutor.providerConfiguration.connectionMode == .apiProvider
                                ? tutor.providerConfiguration.endpoint
                                : ""
                        },
                        set: { updateAPIEndpoint($0) }
                    ),
                    prompt: "https://your-service.example/v1/chat/completions"
                )
            } else {
                connectionValue(
                    label: "Protocol endpoint",
                    value: tutor.providerConfiguration.apiProvider.endpoint,
                    icon: protocolIcon
                )
            }

            field(
                "Model",
                text: Binding(
                    get: {
                        tutor.providerConfiguration.connectionMode == .apiProvider
                            ? tutor.providerConfiguration.model
                            : ""
                    },
                    set: { updateAPIModel($0) }
                ),
                prompt: tutor.providerConfiguration.apiProvider.modelPrompt
            )

            VStack(alignment: .leading, spacing: AESpacing.sm) {
                Text("Your API key").font(.aeLabel).foregroundStyle(AEColor.textPrimary(colorScheme))
                SecureField(
                    tutor.credentialIsStored ? "A key is already stored for this origin" : "Stored in this device’s Keychain",
                    text: $credential
                )
                .textFieldStyle(.plain)
                .padding(13)
                .background(AEColor.inputFill(colorScheme), in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AEColor.strokeStrong(colorScheme)))

                if tutor.credentialIsStored {
                    Label("Key stored for \(TutorEndpointPolicy.origin(for: (try? TutorEndpointPolicy.validatedURL(tutor.providerConfiguration.endpoint)) ?? URL(string: "https://invalid.local")!))", systemImage: "lock.fill")
                        .font(.aeCaption)
                        .foregroundStyle(AEColor.readableSignal(colorScheme))
                }
            }

            ViewThatFits(in: .horizontal) {
                HStack(spacing: AESpacing.sm) { apiActionControls }
                VStack(alignment: .leading, spacing: AESpacing.sm) { apiActionControls }
            }

            if let apiStatus {
                Text(apiStatus)
                    .font(.aeCaption)
                    .foregroundStyle(AEColor.readableSignal(colorScheme))
            }
        }
        .padding(AESpacing.lg)
        .aeGlassSurface(cornerRadius: AERadius.large, tint: AEColor.violet)
    }

    @ViewBuilder
    private var apiActionControls: some View {
        Button(tutor.providerIsReady && tutor.providerConfiguration.connectionMode == .apiProvider ? "Reconnect API provider" : "Connect API provider") {
            connectAPIProvider()
        }
        .buttonStyle(AEButtonStyle(.primary, size: .compact, tint: AEColor.violet))
        .disabled(
            tutor.providerConfiguration.model.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                || tutor.providerConfiguration.connectionMode != .apiProvider
                || !tutor.providerConfiguration.endpointMatchesConnection
                || (credential.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !tutor.credentialIsStored)
        )

        if tutor.providerConfiguration.connectionMode == .apiProvider && tutor.providerConfiguration.isEnabled {
            Button("Disconnect") {
                cancelLocalDetection()
                tutor.disconnectProvider()
                apiStatus = "Disconnected. Offline routing restored."
            }
            .buttonStyle(AEButtonStyle(.outline, size: .compact, tint: AEColor.violet))
        }

        if tutor.credentialIsStored {
            Button("Forget key") {
                do {
                    cancelLocalDetection()
                    try tutor.saveCredential("")
                    tutor.disconnectProvider()
                    apiStatus = "API key removed from Keychain."
                } catch {
                    apiStatus = error.localizedDescription
                }
            }
            .buttonStyle(.plain)
            .font(.aeCaption)
            .foregroundStyle(AEColor.textSecondary(colorScheme))
        }
    }

    private var localServerCard: some View {
        VStack(alignment: .leading, spacing: AESpacing.lg) {
            connectionHeader(
                number: "2",
                icon: "desktopcomputer.and.macbook",
                title: "Local server",
                detail: "Choose Ollama or LM Studio to detect and connect its first model on this machine. Detection uses short loopback-only requests and never scans your network."
            )

            Picker("Local server", selection: Binding(
                get: { tutor.providerConfiguration.localServer },
                set: { selectLocalServer($0) }
            )) {
                ForEach(TutorLocalServer.allCases) { server in
                    Text(server.title).tag(server)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            HStack(spacing: AESpacing.sm) {
                Button {
                    startLocalDetection()
                } label: {
                    if isDetectingLocalServer {
                        ProgressView().controlSize(.small)
                    } else {
                        Label(detectButtonTitle, systemImage: "dot.radiowaves.left.and.right")
                    }
                }
                .buttonStyle(AEButtonStyle(.secondary, size: .compact))
                .disabled(isDetectingLocalServer)

                if !detectedModels.isEmpty {
                    Label("\(detectedModels.count) model\(detectedModels.count == 1 ? "" : "s") found", systemImage: "checkmark.circle.fill")
                        .font(.aeCaption)
                        .foregroundStyle(AEColor.readableSignal(colorScheme))
                }
            }

            if !localModelOptions.isEmpty {
                VStack(alignment: .leading, spacing: AESpacing.sm) {
                    Text("Detected model").font(.aeLabel).foregroundStyle(AEColor.textPrimary(colorScheme))
                    Picker("Detected model", selection: Binding(
                        get: { tutor.providerConfiguration.model },
                        set: { updateLocalModel($0) }
                    )) {
                        ForEach(localModelOptions, id: \.self) { model in
                            Text(model).tag(model)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AEColor.inputFill(colorScheme), in: RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AEColor.strokeStrong(colorScheme)))
                }

                connectionValue(
                    label: "Local chat endpoint",
                    value: tutor.providerConfiguration.endpoint,
                    icon: "network"
                )

                HStack(spacing: AESpacing.sm) {
                    Button("Connect local server") { connectLocalServer() }
                        .buttonStyle(AEButtonStyle(.primary, size: .compact, tint: AEColor.signal))
                    if tutor.providerConfiguration.connectionMode == .localServer && tutor.providerConfiguration.isEnabled {
                        Button("Disconnect") {
                            cancelLocalDetection()
                            tutor.disconnectProvider()
                            localStatus = "Disconnected. Offline routing restored."
                        }
                        .buttonStyle(AEButtonStyle(.outline, size: .compact, tint: AEColor.signal))
                    }
                }
            }

            #if os(iOS)
            HStack(alignment: .top, spacing: AESpacing.sm) {
                Image(systemName: "iphone.gen3")
                    .foregroundStyle(AEColor.readableAzure(colorScheme))
                Text("On iPhone and iPad, localhost and 127.0.0.1 mean that iPhone or iPad—not your Mac. This same-machine detector cannot see Ollama or LM Studio running on your Mac. Use the macOS app for a Mac-hosted local server.")
                    .font(.aeCaption)
                    .foregroundStyle(AEColor.textSecondary(colorScheme))
            }
            #else
            HStack(alignment: .top, spacing: AESpacing.sm) {
                Image(systemName: "desktopcomputer")
                    .foregroundStyle(AEColor.readableAzure(colorScheme))
                Text("Detection checks only 127.0.0.1 on this Mac: Ollama on port 11434 or LM Studio on port 1234. It does not scan your LAN.")
                    .font(.aeCaption)
                    .foregroundStyle(AEColor.textSecondary(colorScheme))
            }
            #endif

            if let localStatus {
                Text(localStatus)
                    .font(.aeCaption)
                    .foregroundStyle(AEColor.readableSignal(colorScheme))
            }
        }
        .padding(AESpacing.lg)
        .aeGlassSurface(cornerRadius: AERadius.large, tint: AEColor.signal)
    }

    private var protocolIcon: String {
        switch tutor.providerConfiguration.apiProvider.protocolFamily {
        case .openAICompatible: "arrow.left.arrow.right.circle"
        case .anthropicMessages: "text.bubble.fill"
        case .geminiGenerateContent: "sparkles"
        }
    }

    private var localModelOptions: [String] {
        if !detectedModels.isEmpty { return detectedModels }
        let saved = tutor.providerConfiguration.model.trimmingCharacters(in: .whitespacesAndNewlines)
        return tutor.providerConfiguration.connectionMode == .localServer && !saved.isEmpty ? [saved] : []
    }

    private var detectButtonTitle: String {
        #if os(iOS)
        "Detect & connect on this device"
        #else
        "Detect & connect on this Mac"
        #endif
    }

    private func connectionHeader(number: String, icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: AESpacing.md) {
            Text(number)
                .font(.system(size: 11, weight: .black, design: .monospaced))
                .foregroundStyle(Color.black.opacity(0.78))
                .frame(width: 28, height: 28)
                .background(AEColor.signal, in: Circle())
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(AEColor.readableViolet(colorScheme))
                .frame(width: 34, height: 34)
                .background(AEColor.violet.opacity(0.11), in: RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.aeHeading).foregroundStyle(AEColor.textPrimary(colorScheme))
                Text(detail)
                    .font(.aeCaption)
                    .foregroundStyle(AEColor.textSecondary(colorScheme))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
    }

    private func connectionValue(label: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: AESpacing.sm) {
            Text(label).font(.aeLabel).foregroundStyle(AEColor.textPrimary(colorScheme))
            HStack(spacing: AESpacing.sm) {
                Image(systemName: icon).foregroundStyle(AEColor.readableAzure(colorScheme))
                Text(value)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(AEColor.textSecondary(colorScheme))
                    .lineLimit(2)
                    .truncationMode(.middle)
                    .textSelection(.enabled)
                Spacer()
            }
            .padding(13)
            .background(AEColor.inputFill(colorScheme), in: RoundedRectangle(cornerRadius: 12))
        }
    }

    private func field(_ label: String, text: Binding<String>, prompt: String) -> some View {
        VStack(alignment: .leading, spacing: AESpacing.sm) {
            Text(label).font(.aeLabel).foregroundStyle(AEColor.textPrimary(colorScheme))
            TextField(prompt, text: text)
                .textFieldStyle(.plain)
                .padding(13)
                .background(AEColor.inputFill(colorScheme), in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AEColor.strokeStrong(colorScheme)))
        }
    }

    private func selectAPIProvider(_ provider: TutorAPIProvider) {
        cancelLocalDetection()
        var configuration = tutor.providerConfiguration
        configuration.select(provider)
        configuration.model = ""
        tutor.providerConfiguration = configuration
        credential = ""
        detectedModels = []
        apiStatus = nil
    }

    private func updateAPIEndpoint(_ endpoint: String) {
        cancelLocalDetection()
        var configuration = tutor.providerConfiguration
        configuration.connectionMode = .apiProvider
        configuration.endpoint = endpoint
        configuration.displayName = configuration.apiProvider.title
        configuration.isEnabled = false
        tutor.providerConfiguration = configuration
        apiStatus = nil
    }

    private func updateAPIModel(_ model: String) {
        cancelLocalDetection()
        var configuration = tutor.providerConfiguration
        if configuration.connectionMode != .apiProvider {
            configuration.select(configuration.apiProvider)
        }
        configuration.model = model
        configuration.displayName = configuration.apiProvider.title
        configuration.isEnabled = false
        tutor.providerConfiguration = configuration
        apiStatus = nil
    }

    private func connectAPIProvider() {
        cancelLocalDetection()
        do {
            try tutor.connectAPIProvider(apiKey: credential)
            credential = ""
            apiStatus = "\(tutor.providerConfiguration.displayName) configured. It will be verified on your first Tutor request; Connected Provider is now selected."
        } catch {
            apiStatus = error.localizedDescription
        }
    }

    private func selectLocalServer(_ server: TutorLocalServer) {
        var configuration = tutor.providerConfiguration
        configuration.select(server)
        configuration.model = ""
        tutor.providerConfiguration = configuration
        detectedModels = []
        localStatus = nil
        startLocalDetection()
    }

    private func startLocalDetection() {
        cancelLocalDetection()
        let requestID = UUID()
        detectionRequestID = requestID
        isDetectingLocalServer = true
        localStatus = "Checking \(tutor.providerConfiguration.localServer.title) on this device…"
        let server = tutor.providerConfiguration.localServer
        detectionTask = Task {
            await detectLocalServer(server: server, requestID: requestID)
        }
    }

    private func detectLocalServer(server: TutorLocalServer, requestID: UUID) async {
        defer {
            if detectionRequestID == requestID {
                isDetectingLocalServer = false
                detectionRequestID = nil
                detectionTask = nil
            }
        }
        do {
            let result = try await LocalTutorServerDiscovery.detect(server)
            guard !Task.isCancelled,
                  detectionRequestID == requestID,
                  tutor.providerConfiguration.connectionMode == .localServer,
                  tutor.providerConfiguration.localServer == server else { return }
            var configuration = tutor.providerConfiguration
            configuration.select(result.server)
            configuration.endpoint = result.endpoint
            configuration.model = result.models[0]
            tutor.providerConfiguration = configuration
            detectedModels = result.models
            try tutor.connectLocalServer()
            localStatus = "\(result.server.title) detected and connected with \(result.models[0]). Choose another model and press Connect if you want to switch."
        } catch is CancellationError {
            return
        } catch {
            guard detectionRequestID == requestID,
                  tutor.providerConfiguration.connectionMode == .localServer,
                  tutor.providerConfiguration.localServer == server else { return }
            detectedModels = []
            localStatus = error.localizedDescription
        }
    }

    private func updateLocalModel(_ model: String) {
        cancelLocalDetection()
        var configuration = tutor.providerConfiguration
        configuration.connectionMode = .localServer
        configuration.model = model
        configuration.isEnabled = false
        tutor.providerConfiguration = configuration
    }

    private func connectLocalServer() {
        do {
            try tutor.connectLocalServer()
            localStatus = "\(tutor.providerConfiguration.displayName) connected. Connected Provider is now selected."
        } catch {
            localStatus = error.localizedDescription
        }
    }

    private func cancelLocalDetection() {
        detectionTask?.cancel()
        detectionTask = nil
        detectionRequestID = nil
        isDetectingLocalServer = false
    }
}

private struct SettingsSection<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    let eyebrow: String
    let title: String
    let detail: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: AESpacing.md) {
            VStack(alignment: .leading, spacing: 4) {
                Text(eyebrow)
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .tracking(1)
                    .foregroundStyle(AEColor.readableViolet(colorScheme))
                Text(title)
                    .font(.aeTitle)
                    .foregroundStyle(AEColor.textPrimary(colorScheme))
                Text(detail)
                    .font(.aeCallout)
                    .foregroundStyle(AEColor.textSecondary(colorScheme))
            }
            content
        }
    }
}
