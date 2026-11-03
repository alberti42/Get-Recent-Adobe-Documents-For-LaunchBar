#!/usr/bin/env bash
#
# build_actions.sh — Build the three LaunchBar actions and pack them into build/Actions.zip.
#
# Usage:
#   bin/build_actions.sh                     # signed ad hoc, runs on this Mac only
#   bin/build_actions.sh "Developer ID Application: Andrea Alberti (9V3X7C8VCK)"
#
# What it does, for Acrobat, Illustrator and Photoshop:
#   1. Builds GetRecent<App>Documents in Release for arm64 and x86_64 with xcodebuild.
#   2. Copies Actions/Recent <App> Documents.lbaction to build/Actions/ and puts
#      the tool into its Contents/Scripts.
#   3. Signs the tool, then the bundle, with the identity given as first argument
#      ("-", ad hoc, by default). A Developer ID signature gets the hardened
#      runtime and a secure timestamp, which notarization requires.
# Then it packs build/Actions/*.lbaction into build/Actions.zip.
#
# macOS kills an arm64 executable that carries no signature, so every tool is signed.

set -euo pipefail
cd "$(dirname "$0")/.."

IDENTITY="${1:--}"
APPS=(Acrobat Illustrator Photoshop)
DERIVED=build/DerivedData
OUT=build/Actions
ZIP=build/Actions.zip

rm -rf "$OUT" "$ZIP"
mkdir -p "$OUT"

for APP in "${APPS[@]}"; do
    TOOL="GetRecent${APP}Documents"
    SRC="Actions/Recent ${APP} Documents.lbaction"
    BUNDLE="$OUT/Recent ${APP} Documents.lbaction"

    echo "── ${TOOL}"
    xcodebuild -quiet \
        -workspace GetRecentAdobeDocuments.xcworkspace \
        -scheme "$TOOL" \
        -configuration Release \
        -destination 'generic/platform=macOS' \
        -derivedDataPath "$DERIVED" \
        ARCHS="arm64 x86_64" ONLY_ACTIVE_ARCH=NO \
        CODE_SIGN_IDENTITY=- \
        build

    cp -R "$SRC" "$BUNDLE"
    mkdir -p "$BUNDLE/Contents/Scripts"
    cp "$DERIVED/Build/Products/Release/$TOOL" "$BUNDLE/Contents/Scripts/$TOOL"

    # The tool's signing identifier is the action's bundle identifier.
    ID=$(plutil -extract CFBundleIdentifier raw "$SRC/Contents/Info.plist")
    # Sign the tool, then the bundle: Gatekeeper checks the bundle when you
    # double-click it, and the bundle's signature seals the signed tool.
    for CODE in "$BUNDLE/Contents/Scripts/$TOOL" "$BUNDLE"; do
        if [[ "$IDENTITY" == "-" ]]; then
            codesign --force --sign - --identifier "$ID" "$CODE"
        else
            codesign --force --sign "$IDENTITY" --identifier "$ID" \
                --options runtime --timestamp "$CODE"
        fi
    done
    codesign --verify --strict --deep "$BUNDLE"
done

# ditto keeps the bundle layout; --norsrc leaves out extended attributes.
(cd "$OUT" && ditto -c -k --norsrc . "../Actions.zip")
echo "── $ZIP"
