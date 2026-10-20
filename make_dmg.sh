#!/bin/bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

echo "Building LockWidget release..."
./bundle.sh

DMG_NAME="LockWidget.dmg"
STAGING_DIR="dmg_staging"

echo "Preparing DMG staging area..."
rm -rf "$STAGING_DIR" "$DMG_NAME"
mkdir -p "$STAGING_DIR"

cp -R "LockWidget.app" "$STAGING_DIR/"
ln -s /Applications "$STAGING_DIR/Applications"

echo "Generating compressed DMG..."
hdiutil create \
    -volname "LockWidget" \
    -srcfolder "$STAGING_DIR" \
    -ov \
    -format UDZO \
    -imagekey zlib-level=9 \
    "$DMG_NAME"

rm -rf "$STAGING_DIR"

echo "Successfully generated ${DMG_NAME}!"
