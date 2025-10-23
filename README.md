# KickstartIntent

A macOS SwiftUI app that exposes a "Kick off Agentic Project" App Intent for creating AI-ready project folders with Claude Code integration.

## Features

- **App Intent Support**: Invoke from Siri, Shortcuts, or Spotlight
- **Automatic Project Setup**: Creates structured project folders at `~/AgenticKickoffs/<timestamp>-<slug>/`
- **Claude Code Ready**: Pre-configured with `claude.config.json` and RAG search tools
- **RAG Integration**: Automatically builds a searchable index of your project
- **Finder Integration**: Opens created projects in Finder automatically
- **Claude Desktop Launch**: Best-effort launch of Claude Desktop with the project

## Requirements

- macOS 14.0 or later
- Xcode 15.0 or later
- XcodeGen (for project generation)

## Quick Start

### 1. Install XcodeGen

```bash
brew install xcodegen
```

### 2. Generate Xcode Project

Double-click `Generate.command` or run:

```bash
./Generate.command
```

This will generate `KickstartIntent.xcodeproj` and open it in Xcode.

### 3. Build and Run

1. Open the project in Xcode
2. Select your development team in the Signing & Capabilities tab
3. Build and run (⌘R)

### 4. Install the App

To use the App Intent from Shortcuts/Siri:

1. Build the app (⌘B)
2. Copy `KickstartIntent.app` to `/Applications/`
3. Run the app at least once to register the intent
4. The intent will now be available in Shortcuts

## Usage

### From the App

1. Launch KickstartIntent
2. Enter your project description in the text box
3. Click "Run Kickoff"
4. The project folder opens in Finder automatically

### From Shortcuts

1. Open the Shortcuts app
2. Create a new shortcut
3. Add the "Kick off Agentic Project" action
4. Enter your project intent
5. Run the shortcut

### From Siri

Say: "Kick off agentic project" and provide your project description when prompted.

### From Spotlight

1. Press ⌘Space to open Spotlight
2. Type "Kick off agentic project"
3. Select the intent and provide your description

## Project Structure

```
KickstartIntent/
├── Generate.command          # One-click project generator
├── project.yml              # XcodeGen configuration
├── Sources/
│   ├── KickstartIntentApp.swift           # Main app entry
│   ├── ContentView.swift                  # SwiftUI interface
│   ├── KickoffAgenticProjectIntent.swift  # App Intent definition
│   ├── ProjectRunner.swift                # Core logic
│   ├── Info.plist                        # App metadata
│   └── KickstartIntent.entitlements      # App permissions
└── scripts/
    └── kickoff.sh           # Project setup script
```

## What Gets Created

When you run the kickoff, a new folder is created at:

```
~/AgenticKickoffs/<timestamp>-<project-slug>/
├── SPEC.md                  # Your project specification
├── README.md                # Project documentation
├── claude.config.json       # Claude Code configuration
├── rag/
│   ├── search.sh           # RAG search script
│   ├── build_index.sh      # Index builder
│   └── index.txt           # Search index
└── kickoff.sh              # Setup script (for reference)
```

## Claude Code Integration

Each created project includes:

1. **claude.config.json**: Exposes a `rag.search` tool that Claude Code can use
2. **RAG Scripts**: Search and index your project documentation
3. **Pre-built Index**: Ready to search immediately
4. **README**: Quick start guide for the new project

## Advanced Usage

### Customize the Kickoff Script

Edit `scripts/kickoff.sh` to customize what gets created in new projects. You can:

- Add more tools to `claude.config.json`
- Change the RAG indexing strategy
- Include additional template files
- Add language-specific setup (npm, pip, etc.)

### Share the Kickoff Script

Copy `scripts/kickoff.sh` to `~/AgenticKickoffs/kickoff.sh` to make it available to all projects:

```bash
mkdir -p ~/AgenticKickoffs
cp scripts/kickoff.sh ~/AgenticKickoffs/
```

The app will use this shared version if the bundled one is not found.

## Troubleshooting

### "XcodeGen not found"

Install XcodeGen:
```bash
brew install xcodegen
```

### "Failed to run kickoff.sh"

Ensure the script is executable:
```bash
chmod +x scripts/kickoff.sh
```

### App Intent not appearing in Shortcuts

1. Ensure the app is in `/Applications/`
2. Run the app at least once
3. Restart the Shortcuts app
4. Check System Settings > Privacy & Security > Automation

### Claude Desktop doesn't launch

The app tries to find Claude Desktop at:
- `/Applications/Claude.app`
- `~/Applications/Claude.app`

Ensure Claude is installed in one of these locations.

## Development

### Regenerate Xcode Project

After modifying `project.yml`:

```bash
./Generate.command
```

### Add New Files

1. Add the file to the `Sources/` directory
2. Run `./Generate.command` to update the Xcode project

### Modify the Intent

Edit `Sources/KickoffAgenticProjectIntent.swift` to:
- Change the intent title or description
- Add new parameters
- Modify the voice phrases

## Architecture

### ProjectRunner

The `ProjectRunner` utility handles all project creation logic:

1. **createProjectFolder**: Generates timestamped folders with slugs
2. **writeSpec**: Writes the SPEC.md file
3. **copyKickoffScript**: Copies kickoff.sh to the project
4. **runKickoffScript**: Executes the setup script
5. **openInFinderAndLaunchClaude**: Opens Finder and launches Claude Desktop

### App Intent

The `KickoffAgenticProjectIntent` conforms to `AppIntent` protocol and:
- Accepts a text parameter (project description)
- Calls `ProjectRunner.runKickoff()`
- Returns success/failure dialog
- Registers phrases for Siri/Shortcuts

### UI

The SwiftUI interface provides a simple text editor and run button for testing the flow without using Shortcuts.

## License

See LICENSE file for details.

## Contributing

Contributions welcome! Please ensure:
- Code follows Swift style guidelines
- XcodeGen configuration remains clean
- Shell scripts are POSIX-compliant
- Documentation is updated

## Roadmap

- [ ] Support for different project templates
- [ ] Advanced RAG with vector embeddings
- [ ] Git repository initialization
- [ ] Integration with project management tools
- [ ] Custom kickoff script selection
- [ ] Multi-language support

## Credits

Built for seamless integration with Claude Code and agentic development workflows.
