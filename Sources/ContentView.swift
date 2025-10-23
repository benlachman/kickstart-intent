import SwiftUI

struct ContentView: View {
    @State private var intentText: String = ""
    @State private var isRunning: Bool = false
    @State private var statusMessage: String = ""
    @State private var showStatus: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Agentic Project Kickoff")
                .font(.title)
                .fontWeight(.bold)

            Text("Describe your project intent:")
                .font(.headline)

            TextEditor(text: $intentText)
                .font(.system(.body, design: .monospaced))
                .frame(minHeight: 200)
                .border(Color.gray.opacity(0.3), width: 1)
                .disabled(isRunning)

            HStack {
                Button(action: runKickoff) {
                    HStack {
                        if isRunning {
                            ProgressView()
                                .scaleEffect(0.8)
                                .frame(width: 16, height: 16)
                        }
                        Text(isRunning ? "Running..." : "Run Kickoff")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(intentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isRunning)
                .controlSize(.large)
            }

            if showStatus {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                    Text(statusMessage)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(statusMessage.contains("Error") ? .red : .secondary)
                        .textSelection(.enabled)
                }
            }

            Spacer()
        }
        .padding(24)
        .frame(minWidth: 500, minHeight: 400)
    }

    private func runKickoff() {
        isRunning = true
        showStatus = true
        statusMessage = "Creating project..."

        Task {
            do {
                let result = try await ProjectRunner.runKickoff(intentText: intentText)
                await MainActor.run {
                    statusMessage = """
                    Success!
                    Project created at:
                    \(result.projectPath)

                    Opened in Finder.
                    """
                    isRunning = false
                }
            } catch {
                await MainActor.run {
                    statusMessage = "Error: \(error.localizedDescription)"
                    isRunning = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
