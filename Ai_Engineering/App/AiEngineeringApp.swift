import SwiftUI

@main
struct AiEngineeringApp: App {
    @StateObject private var state = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(state)
                .tint(AEColor.signal)
                .preferredColorScheme(.dark)
        }
        #if os(macOS)
        .defaultSize(width: 1_280, height: 820)
        .windowStyle(.hiddenTitleBar)
        #endif
    }
}
