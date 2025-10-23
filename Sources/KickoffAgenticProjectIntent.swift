import AppIntents
import Foundation

struct KickoffAgenticProjectIntent: AppIntent {
    static var title: LocalizedStringResource = "Kick off Agentic Project"

    static var description = IntentDescription("Creates a new agentic project folder with Claude Code configuration and RAG setup")

    static var openAppWhenRun: Bool = false

    @Parameter(title: "Project Intent", description: "Describe what you want to build")
    var intentText: String

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard !intentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw $intentText.needsValueError()
        }

        do {
            let result = try await ProjectRunner.runKickoff(intentText: intentText)

            return .result(
                dialog: IntentDialog("Project created at \(result.projectPath)")
            )
        } catch {
            throw error
        }
    }

    static var parameterSummary: some ParameterSummary {
        Summary("Create agentic project: \(\.$intentText)")
    }
}

// App Shortcuts Provider
struct KickoffShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: KickoffAgenticProjectIntent(),
            phrases: [
                "Kick off agentic project \(\.$intentText) in \(.applicationName)",
                "Create agentic project \(\.$intentText) with \(.applicationName)",
                "Start new project \(\.$intentText) in \(.applicationName)"
            ],
            shortTitle: "Kick off Project",
            systemImageName: "folder.badge.plus"
        )
    }
}
