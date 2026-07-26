#!/bin/bash
set -e
cd "$(dirname "$0")"

echo "Building BrowserProxy..."
swift build -c release

APP="BrowserProxy.app"
rm -rf "$APP"

mkdir -p "$APP/Contents/MacOS"
mkdir -p "$APP/Contents/Resources"

cp ".build/release/BrowserProxy" "$APP/Contents/MacOS/"
cp "Info.plist" "$APP/Contents/"

if [ -f "Resources/AppIcon.icns" ]; then
  cp "Resources/AppIcon.icns" "$APP/Contents/Resources/"
else
  cp "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericApplicationIcon.icns" \
     "$APP/Contents/Resources/AppIcon.icns" 2>/dev/null || true
fi

codesign --force --deep --sign - "$APP" 2>/dev/null || true

echo ""
echo "✅ Built $APP"
echo ""
echo "To install:"
echo "  cp -R \"$APP\" /Applications/"
echo "  Then open BrowserProxy and click '设为默认浏览器'"
