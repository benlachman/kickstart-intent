import Foundation
import AppKit

struct ProjectRunner {
    struct KickoffResult {
        let projectPath: String
    }

    enum KickoffError: LocalizedError {
        case failedToCreateDirectory
        case failedToWriteSpec
        case failedToCopyScript
        case failedToRunScript(String)
        case scriptNotFound

        var errorDescription: String? {
            switch self {
            case .failedToCreateDirectory:
                return "Failed to create project directory"
            case .failedToWriteSpec:
                return "Failed to write SPEC.md file"
            case .failedToCopyScript:
                return "Failed to copy kickoff.sh script"
            case .failedToRunScript(let message):
                return "Failed to run kickoff.sh: \(message)"
            case .scriptNotFound:
                return "kickoff.sh script not found in app bundle or ~/AgenticKickoffs"
            }
        }
    }

    static func runKickoff(intentText: String) async throws -> KickoffResult {
        // 1. Create project folder
        let projectPath = try createProjectFolder(intentText: intentText)

        // 2. Write SPEC.md
        try writeSpec(intentText: intentText, to: projectPath)

        // 3. Copy kickoff.sh to project folder
        let scriptPath = try copyKickoffScript(to: projectPath)

        // 4. Run kickoff.sh
        try await runKickoffScript(at: scriptPath, projectPath: projectPath)

        // 5. Open in Finder and try to launch Claude Desktop
        openInFinderAndLaunchClaude(projectPath: projectPath)

        return KickoffResult(projectPath: projectPath)
    }

    private static func createProjectFolder(intentText: String) throws -> String {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let agenticKickoffsDir = homeDir.appendingPathComponent("AgenticKickoffs")

        // Create AgenticKickoffs directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: agenticKickoffsDir.path) {
            try? FileManager.default.createDirectory(
                at: agenticKickoffsDir,
                withIntermediateDirectories: true
            )
        }

        // Generate timestamp and slug
        let timestamp = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: ":", with: "-")
        let slug = generateSlug(from: intentText)
        let folderName = "\(timestamp)-\(slug)"

        let projectPath = agenticKickoffsDir.appendingPathComponent(folderName)

        do {
            try FileManager.default.createDirectory(
                at: projectPath,
                withIntermediateDirectories: true
            )
        } catch {
            throw KickoffError.failedToCreateDirectory
        }

        return projectPath.path
    }

    private static func generateSlug(from text: String) -> String {
        // Take first few words and create a slug
        let words = text
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .prefix(5)

        let slug = words
            .joined(separator: "-")
            .lowercased()
            .replacingOccurrences(of: "[^a-z0-9-]", with: "", options: .regularExpression)

        return slug.isEmpty ? "project" : String(slug.prefix(50))
    }

    private static func writeSpec(intentText: String, to projectPath: String) throws {
        let specPath = URL(fileURLWithPath: projectPath).appendingPathComponent("SPEC.md")
        let specContent = """
        # Project Specification

        \(intentText)

        ---
        Generated: \(Date().formatted())
        """

        do {
            try specContent.write(to: specPath, atomically: true, encoding: .utf8)
        } catch {
            throw KickoffError.failedToWriteSpec
        }
    }

    private static func copyKickoffScript(to projectPath: String) throws -> String {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let agenticKickoffsDir = homeDir.appendingPathComponent("AgenticKickoffs")
        let sharedScriptPath = agenticKickoffsDir.appendingPathComponent("kickoff.sh")

        // First, try to find script in app bundle
        var sourcePath: URL?
        if let bundleScriptPath = Bundle.main.path(forResource: "kickoff", ofType: "sh") {
            sourcePath = URL(fileURLWithPath: bundleScriptPath)
        } else if FileManager.default.fileExists(atPath: sharedScriptPath.path) {
            // Fall back to shared location
            sourcePath = sharedScriptPath
        }

        guard let scriptSource = sourcePath else {
            throw KickoffError.scriptNotFound
        }

        let destinationPath = URL(fileURLWithPath: projectPath).appendingPathComponent("kickoff.sh")

        do {
            try FileManager.default.copyItem(at: scriptSource, to: destinationPath)
            // Make it executable
            try FileManager.default.setAttributes(
                [.posixPermissions: 0o755],
                ofItemAtPath: destinationPath.path
            )
        } catch {
            throw KickoffError.failedToCopyScript
        }

        return destinationPath.path
    }

    private static func runKickoffScript(at scriptPath: String, projectPath: String) async throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = [scriptPath]
        process.currentDirectoryURL = URL(fileURLWithPath: projectPath)

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        do {
            try process.run()
            process.waitUntilExit()

            if process.terminationStatus != 0 {
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                let errorMessage = String(data: errorData, encoding: .utf8) ?? "Unknown error"
                throw KickoffError.failedToRunScript(errorMessage)
            }
        } catch let error as KickoffError {
            throw error
        } catch {
            throw KickoffError.failedToRunScript(error.localizedDescription)
        }
    }

    private static func openInFinderAndLaunchClaude(projectPath: String) {
        let workspace = NSWorkspace.shared
        let projectURL = URL(fileURLWithPath: projectPath)

        // Open in Finder
        workspace.selectFile(nil, inFileViewerRootedAtPath: projectPath)

        // Try to launch Claude Desktop (best effort)
        let claudeAppPaths = [
            "/Applications/Claude.app",
            NSHomeDirectory() + "/Applications/Claude.app"
        ]

        for appPath in claudeAppPaths {
            if FileManager.default.fileExists(atPath: appPath) {
                let configuration = NSWorkspace.OpenConfiguration()
                configuration.arguments = [projectPath]

                workspace.openApplication(
                    at: URL(fileURLWithPath: appPath),
                    configuration: configuration,
                    completionHandler: { _, _ in }
                )
                break
            }
        }
    }
}
