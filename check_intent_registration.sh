#!/bin/bash
# Script to verify App Intent registration

echo "🔍 Checking KickstartIntent App Intent Registration"
echo ""

APP_PATH="/Applications/KickstartIntent.app"
DERIVED_DATA="$HOME/Library/Developer/Xcode/DerivedData"

# Check if app exists in Applications
if [ -d "$APP_PATH" ]; then
    echo "✅ App found in /Applications/"
    echo "   Path: $APP_PATH"
else
    echo "⚠️  App NOT found in /Applications/"
    echo "   You may need to copy the built app there"
fi

echo ""

# Check for built app in DerivedData
echo "📦 Looking for built app in DerivedData..."
BUILT_APP=$(find "$DERIVED_DATA" -name "KickstartIntent.app" -path "*/Build/Products/*" 2>/dev/null | head -1)

if [ -n "$BUILT_APP" ]; then
    echo "✅ Found built app:"
    echo "   $BUILT_APP"

    # Check for App Intents metadata
    echo ""
    echo "🔍 Checking for App Intents metadata..."

    METADATA_FILES=$(find "$BUILT_APP/Contents" -name "*appintent*" -o -name "*metadata*" 2>/dev/null)

    if [ -n "$METADATA_FILES" ]; then
        echo "✅ App Intents metadata found:"
        echo "$METADATA_FILES" | while read -r file; do
            echo "   - $file"
        done
    else
        echo "⚠️  No metadata files found (this might be normal for Debug builds)"
    fi
else
    echo "⚠️  No built app found in DerivedData"
    echo "   Try building the project in Xcode first"
fi

echo ""
echo "📝 Next Steps:"
echo "1. Build and run the app in Xcode (⌘R)"
echo "2. Copy to /Applications/ if not already there"
echo "3. Launch the app at least once"
echo "4. Wait 10-30 seconds"
echo "5. Open Shortcuts app and search for 'kick off'"
echo "6. If it appears in Shortcuts, try with Siri"
echo ""
