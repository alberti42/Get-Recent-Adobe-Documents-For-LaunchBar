#!/usr/bin/env bash
#
# bump_version.sh — Set the version of the three actions, commit, and tag locally.
#
# Usage:
#   ./bin/bump_version.sh v1.1.0           # release
#   ./bin/bump_version.sh v1.1.0-beta.1    # pre-release
#
# Versions follow Semantic Versioning 2.0.0; pre-releases carry a -beta.N suffix.
#
# What it does:
#   1. Validates the version format (vX.Y.Z or vX.Y.Z-beta.N).
#   2. Checks the working tree is clean.
#   3. Ensures the tag does not already exist.
#   4. Sets CFBundleVersion (X.Y.Z without the -beta.N suffix) in
#      Actions/*.lbaction/Contents/Info.plist. LaunchBar shows it as the action's version.
#   5. Commits with "Version bump to vX.Y.Z" and creates a local git tag vX.Y.Z.
#
# Pushing the tag starts .github/workflows/draft-release.yml, which builds,
# signs, notarizes and drafts the GitHub release. Push manually when ready:
#   git push origin main --tags

set -euo pipefail
cd "$(dirname "$0")/.."

VERSION="${1:-}"

if [[ ! "$VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+(-beta\.[0-9]+)?$ ]]; then
    echo "Usage: $0 vX.Y.Z | vX.Y.Z-beta.N"
    exit 1
fi

SHORT="${VERSION#v}"   # e.g. "1.1.0" or "1.1.0-beta.1"
BASE="${SHORT%%-*}"    # e.g. "1.1.0"

if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "Error: working tree is dirty. Commit or stash changes first."
    exit 1
fi

if git rev-parse --verify --quiet "$VERSION" > /dev/null; then
    echo "Error: tag '$VERSION' already exists."
    exit 1
fi

PLISTS=(Actions/*.lbaction/Contents/Info.plist)
for PLIST in "${PLISTS[@]}"; do
    plutil -replace CFBundleVersion -string "$BASE" "$PLIST"
done

git add "${PLISTS[@]}"
if git diff --cached --quiet; then
    git commit --allow-empty -m "Version bump to ${VERSION}"
else
    git commit -m "Version bump to ${VERSION}"
fi
# --no-sign: with tag.gpgsign set, a plain "git tag" asks for a message and fails.
git tag --no-sign "$VERSION"

echo "Tagged ${VERSION}. Push when ready:"
echo "  git push origin main --tags"
