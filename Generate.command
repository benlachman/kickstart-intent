#!/bin/bash
cd "$(dirname "$0")"

echo "╔════════════════════════════════════════╗"
echo "║   KickstartIntent Project Generator    ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Check if XcodeGen is installed
if ! command -v xcodegen &> /dev/null; then
    echo "⚠️  XcodeGen is not installed."
    echo ""
    echo "Please install it using Homebrew:"
    echo "  brew install xcodegen"
    echo ""
    echo "Or download from: https://github.com/yonaskolb/XcodeGen"
    exit 1
fi

echo "📦 Generating Xcode project..."
xcodegen generate

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Project generated successfully!"
    echo ""
    echo "Opening KickstartIntent.xcodeproj..."
    open KickstartIntent.xcodeproj
else
    echo ""
    echo "❌ Failed to generate project."
    exit 1
fi
