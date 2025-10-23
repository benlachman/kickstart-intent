import SwiftUI

@main
struct KickstartIntentApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 500, minHeight: 400)
        }
        .windowResizability(.contentSize)
    }
}
