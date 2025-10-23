import SwiftUI
import AppIntents

@main
struct KickstartIntentApp: App {
    init() {
        // Register app shortcuts on launch
        KickoffShortcuts.updateAppShortcutParameters()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 500, minHeight: 400)
        }
        .windowResizability(.contentSize)
    }
}
