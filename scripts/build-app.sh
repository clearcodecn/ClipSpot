#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
swift build -c release --arch arm64 --arch x86_64
BIN_DIR=$(swift build -c release --arch arm64 --arch x86_64 --show-bin-path)
APP="$PWD/build/ClipSpot.app"
mkdir -p "$APP/Contents/MacOS"
cp "$BIN_DIR/ClipSpot" "$APP/Contents/MacOS/ClipSpot"
cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleExecutable</key><string>ClipSpot</string>
<key>CFBundleIdentifier</key><string>local.clipspot.app</string>
<key>CFBundleName</key><string>ClipSpot</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>0.2.1</string>
<key>CFBundleVersion</key><string>3</string>
<key>LSMinimumSystemVersion</key><string>13.0</string>
<key>LSUIElement</key><true/>
<key>NSHighResolutionCapable</key><true/>
</dict></plist>
PLIST
# A consistent signing identity lets macOS recognize successive builds as the same app.
# Override CLIPSPOT_SIGNING_IDENTITY to select a specific certificate.
SIGNING_IDENTITY="${CLIPSPOT_SIGNING_IDENTITY:-}"
if [[ -z "$SIGNING_IDENTITY" ]]; then
    SIGNING_IDENTITY=$(security find-identity -v -p codesigning | sed -nE '/"Apple Development:/s/^[[:space:]]*[0-9]+\) ([0-9A-F]+).*/\1/p' | head -n 1)
fi
if [[ -z "$SIGNING_IDENTITY" ]]; then
    SIGNING_IDENTITY="-"
    echo "No Apple Development signing identity found; using ad-hoc signing. Accessibility permission may need to be granted again after rebuilds."
fi
codesign --force --deep --sign "$SIGNING_IDENTITY" "$APP"
echo "Built: $APP"
