#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
./scripts/build-app.sh
STAGING_DIR=$(mktemp -d "${TMPDIR:-/tmp}/clipspot-dmg.XXXXXX")
trap 'rm -rf "$STAGING_DIR"' EXIT
ditto build/ClipSpot.app "$STAGING_DIR/ClipSpot.app"
ln -s /Applications "$STAGING_DIR/Applications"
DMG="$PWD/build/ClipSpot-0.2.1.dmg"
rm -f "$DMG"
hdiutil create -volname ClipSpot -srcfolder "$STAGING_DIR" -ov -format UDZO "$DMG"
hdiutil verify "$DMG"
echo "Built: $DMG"
