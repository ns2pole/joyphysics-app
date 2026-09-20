#!/usr/bin/env bash
# Resolve next iOS marketing version + build number for Codemagic / local release.
# Policy:
#   name   = pubspec marketing version as-is (e.g. 6.0.0), unless FORCE_VERSION_NAME set
#   build  = max(pubspec_build, asc_latest) + 1, unless FORCE_VERSION_CODE set
#
# Usage:
#   eval "$(./scripts/resolve_ios_release_version.sh)"
#   echo "$VERSION_NAME+$VERSION_CODE"
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

VER_LINE=$(grep '^version:' pubspec.yaml | head -1 | awk '{print $2}' | tr -d "'\"")
VERSION_NAME="${FORCE_VERSION_NAME:-${VER_LINE%+*}}"
PUBSPEC_CODE="${VER_LINE#*+}"
PUBSPEC_CODE=$(echo "$PUBSPEC_CODE" | tr -dc '0-9')
[ -n "$PUBSPEC_CODE" ] || PUBSPEC_CODE=0

LATEST=0
if [ -n "${APP_STORE_APPLE_ID:-}" ] && command -v app-store-connect >/dev/null 2>&1; then
  RAW=$(app-store-connect get-latest-app-store-build-number "$APP_STORE_APPLE_ID" 2>/dev/null || true)
  LATEST=$(echo "$RAW" | tr -dc '0-9' | head -c 12)
  [ -n "$LATEST" ] || LATEST=0
fi

if [ -n "${FORCE_VERSION_CODE:-}" ]; then
  VERSION_CODE="$FORCE_VERSION_CODE"
else
  # pubspec 側で既に上げてあるならそれを採用。ASC の方が大きければ +1。
  if [ "$PUBSPEC_CODE" -gt "$LATEST" ]; then
    VERSION_CODE="$PUBSPEC_CODE"
  else
    VERSION_CODE=$((LATEST + 1))
  fi
fi

# shellcheck disable=SC2034
export VERSION_NAME VERSION_CODE PUBSPEC_CODE LATEST
echo "export VERSION_NAME='$VERSION_NAME'"
echo "export VERSION_CODE='$VERSION_CODE'"
echo "export PUBSPEC_CODE='$PUBSPEC_CODE'"
echo "export LATEST_ASC='$LATEST'"
echo "Resolved release version: $VERSION_NAME+$VERSION_CODE (pubspec_build=$PUBSPEC_CODE asc=$LATEST)" >&2
