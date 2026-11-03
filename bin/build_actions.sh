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
#   2. Copies Actions/Recent <App> Documents.lbaction to build/Actions/, puts the
#      tool into its Contents/MacOS, and links Contents/Scripts/<tool> to it.
#   3. Signs the bundle, and with it the tool, with the identity given as first argument
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

    # The tool is the bundle's executable (CFBundleExecutable in Contents/MacOS).
    # LaunchBar runs Contents/Scripts/<LBScriptName>, a symlink to it.
    cp -R "$SRC" "$BUNDLE"
    mkdir -p "$BUNDLE/Contents/MacOS" "$BUNDLE/Contents/Scripts"
    cp "$DERIVED/Build/Products/Release/$TOOL" "$BUNDLE/Contents/MacOS/$TOOL"
    ln -s "../MacOS/$TOOL" "$BUNDLE/Contents/Scripts/$TOOL"

    # Signing the bundle signs its executable; the signature is embedded in
    # the tool. Apple's notary service issues tickets for Mach-O code only, so
    # a bundle without an executable could not be notarized, and Gatekeeper
    # checks the bundle when you double-click it.
    ID=$(plutil -extract CFBundleIdentifier raw "$SRC/Contents/Info.plist")
    if [[ "$IDENTITY" == "-" ]]; then
        codesign --force --sign - --identifier "$ID" "$BUNDLE"
    else
        codesign --force --sign "$IDENTITY" --identifier "$ID" \
            --options runtime --timestamp "$BUNDLE"
    fi
    codesign --verify --strict --deep "$BUNDLE"
done

# ditto keeps the bundle layout; --norsrc leaves out extended attributes.
(cd "$OUT" && ditto -c -k --norsrc . "../Actions.zip")
echo "── $ZIP"
