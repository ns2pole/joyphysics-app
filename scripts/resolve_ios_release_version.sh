#!/usr/bin/env bash
# Resolve next iOS marketing version + build number for Codemagic / local release.
# Policy: always increment past App Store AND pubspec.
#   build  = max(pubspec_build, asc_latest) + 1
#   name   = bump patch of pubspec version (5.0.0 -> 5.0.1)
#
# Usage:
#   eval "$(./scripts/resolve_ios_release_version.sh)"
#   echo "$VERSION_NAME+$VERSION_CODE"
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

VER_LINE=$(grep '^version:' pubspec.yaml | head -1 | awk '{print $2}' | tr -d "'\"")
VERSION_NAME="${VER_LINE%+*}"
PUBSPEC_CODE="${VER_LINE#*+}"
PUBSPEC_CODE=$(echo "$PUBSPEC_CODE" | tr -dc '0-9')
[ -n "$PUBSPEC_CODE" ] || PUBSPEC_CODE=0

LATEST=0
if [ -n "${APP_STORE_APPLE_ID:-}" ] && command -v app-store-connect >/dev/null 2>&1; then
  RAW=$(app-store-connect get-latest-app-store-build-number "$APP_STORE_APPLE_ID" 2>/dev/null || true)
  LATEST=$(echo "$RAW" | tr -dc '0-9' | head -c 12)
  [ -n "$LATEST" ] || LATEST=0
fi

BASE="$PUBSPEC_CODE"
if [ "$LATEST" -gt "$BASE" ]; then
  BASE="$LATEST"
fi
VERSION_CODE=$((BASE + 1))

# bump patch: 5.0.0 -> 5.0.1
IFS='.' read -r MAJOR MINOR PATCH <<EOF
${VERSION_NAME}
EOF
MAJOR=${MAJOR:-0}
MINOR=${MINOR:-0}
PATCH=${PATCH:-0}
PATCH=$(echo "$PATCH" | tr -dc '0-9')
[ -n "$PATCH" ] || PATCH=0
VERSION_NAME="${MAJOR}.${MINOR}.$((PATCH + 1))"

# shellcheck disable=SC2034
export VERSION_NAME VERSION_CODE PUBSPEC_CODE LATEST
echo "export VERSION_NAME='$VERSION_NAME'"
echo "export VERSION_CODE='$VERSION_CODE'"
echo "export PUBSPEC_CODE='$PUBSPEC_CODE'"
echo "export LATEST_ASC='$LATEST'"
echo "Resolved release version: $VERSION_NAME+$VERSION_CODE (pubspec_build=$PUBSPEC_CODE asc=$LATEST)" >&2
