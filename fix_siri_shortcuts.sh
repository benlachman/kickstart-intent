#!/bin/bash
# Complete reset procedure for App Shortcuts Siri integration
# Based on macOS 15 developer forum solutions

set -e

echo "═══════════════════════════════════════════════════"
echo "  App Shortcuts Siri Fix - Complete Reset"
echo "═══════════════════════════════════════════════════"
echo ""
echo "This script implements solutions from Apple Developer Forums"
echo "for fixing Siri App Shortcuts discovery issues on macOS 15."
echo ""

# Step 1: Find and remove all app copies
echo "Step 1: Removing ALL copies of KickstartIntent.app..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

APP_LOCATIONS=(
    "/Applications/KickstartIntent.app"
    "$HOME/Applications/KickstartIntent.app"
)

for location in "${APP_LOCATIONS[@]}"; do
    if [ -d "$location" ]; then
        echo "  Removing: $location"
        rm -rf "$location"
    fi
done

# Find and list DerivedData copies
DERIVED_APPS=$(find "$HOME/Library/Developer/Xcode/DerivedData" -name "KickstartIntent.app" 2>/dev/null || true)
if [ -n "$DERIVED_APPS" ]; then
    echo "  Found in DerivedData (will be cleaned with Xcode):"
    echo "$DERIVED_APPS" | while read -r app; do
        echo "    - $app"
    done
fi

echo "✅ App copies removed"
echo ""

# Step 2: Kill system services that cache App Intents
echo "Step 2: Resetting system services..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

SERVICES=("Siri" "assistantd" "remindd" "shortcuts")
for service in "${SERVICES[@]}"; do
    if pgrep -x "$service" > /dev/null; then
        echo "  Killing $service..."
        killall -9 "$service" 2>/dev/null || true
    fi
done

echo "✅ Services reset"
echo ""

# Step 3: Instructions for Xcode
echo "Step 3: Rebuild in Xcode"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  1. Open Xcode project"
echo "  2. Product > Clean Build Folder (Shift+⌘K)"
echo "  3. Build and Run (⌘R)"
echo "  4. Copy built app to /Applications:"
echo ""
echo "     cp -r ~/Library/Developer/Xcode/DerivedData/KickstartIntent-*/Build/Products/Debug/KickstartIntent.app /Applications/"
echo ""
echo "Press Enter when you've completed the rebuild..."
read -r

# Step 4: Verify installation
echo ""
echo "Step 4: Verifying installation..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -d "/Applications/KickstartIntent.app" ]; then
    echo "✅ App installed at /Applications/KickstartIntent.app"

    # Check bundle ID
    BUNDLE_ID=$(defaults read /Applications/KickstartIntent.app/Contents/Info.plist CFBundleIdentifier 2>/dev/null || echo "unknown")
    echo "   Bundle ID: $BUNDLE_ID"

    # Count total copies
    TOTAL_COPIES=$(find /Applications ~/Applications ~/Library/Developer/Xcode/DerivedData -name "KickstartIntent.app" 2>/dev/null | wc -l)
    echo "   Total copies found: $TOTAL_COPIES"

    if [ "$TOTAL_COPIES" -gt 1 ]; then
        echo "   ⚠️  WARNING: Multiple copies detected! This may prevent Siri from working."
        echo "   Please delete all but one copy."
    fi
else
    echo "❌ App not found in /Applications"
    echo "   Please copy it there manually."
    exit 1
fi

echo ""
echo "Step 5: Enable Siri permissions"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  1. Open System Settings > Siri & Spotlight"
echo "  2. Scroll to 'Siri & Spotlight Suggestions'"
echo "  3. Find 'KickstartIntent' and enable:"
echo "     ✅ Learn from this App"
echo "     ✅ Show in Spotlight"
echo "     ✅ Show Siri Suggestions"
echo ""
echo "Press Enter when completed..."
read -r

echo ""
echo "Step 6: Launch app and trigger Siri authorization"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🎯 CRITICAL: First-time Siri authorization required!"
echo ""
echo "  1. Launch: /Applications/KickstartIntent.app"
echo "  2. Keep the app OPEN in the foreground"
echo "  3. Say to Siri: 'Hey Siri, create project with KickstartIntent'"
echo "  4. Siri may ask: 'Turn on KickstartIntent shortcuts with Siri?'"
echo "  5. Respond: 'Turn On' or 'Yes'"
echo ""
echo "Opening app now..."
open /Applications/KickstartIntent.app

echo ""
echo "Waiting 10 seconds for app to launch..."
sleep 10

echo ""
echo "═══════════════════════════════════════════════════"
echo "  NOW TRY THESE SIRI COMMANDS:"
echo "═══════════════════════════════════════════════════"
echo ""
echo "  🎤 'Hey Siri, create project with KickstartIntent'"
echo "  🎤 'Hey Siri, new project in KickstartIntent'"
echo "  🎤 'Hey Siri, start project with KickstartIntent'"
echo ""
echo "═══════════════════════════════════════════════════"
echo ""
echo "If it still doesn't work:"
echo "  • Restart your Mac (sometimes required)"
echo "  • Wait 2-3 minutes after reboot"
echo "  • Try asking Siri: 'What can I do with KickstartIntent?'"
echo "  • Check the Shortcuts app - if it appears there, Siri should work"
echo ""
