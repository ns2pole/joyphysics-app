#!/usr/bin/env bash
# Build Android AAB and submit to Google Play production (for review).
# Reads version from pubspec.yaml (e.g. 6.0.0+106).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

VER_LINE=$(grep '^version:' pubspec.yaml | head -1 | awk '{print $2}' | tr -d "'\"")
NAME="${VER_LINE%+*}"
CODE="${VER_LINE#*+}"
CODE=$(echo "$CODE" | tr -dc '0-9')

AAB="build/app/outputs/bundle/release/app-release.aab"
KEY="fastlane/joy-physics-fastlane-49212c4fb3b6.json"
NOTES="fastlane/metadata/android/ja-JP/changelogs/${CODE}.txt"
PY="$ROOT/.tools/playupload/bin/python"
UPLOAD="$ROOT/.tools/upload_play.py"

if [[ ! -f "$NOTES" ]]; then
  echo "ERROR: missing changelog $NOTES"
  exit 1
fi

if [[ ! -x "$PY" ]]; then
  echo "Play upload venv missing. Creating..."
  python3 -m venv .tools/playupload
  .tools/playupload/bin/pip install -U pip
  .tools/playupload/bin/pip install --only-binary=:all: google-api-python-client google-auth
fi

echo "Building Android $NAME+$CODE ..."
JDK=$(ls -d "$HOME/.jdks"/jdk-17* 2>/dev/null | head -1 || true)
if [[ -n "${JDK:-}" ]]; then
  export JAVA_HOME="$JDK/Contents/Home"
fi
export ANDROID_HOME="${ANDROID_HOME:-/usr/local/share/android-commandlinetools}"
export PATH="${JAVA_HOME:+$JAVA_HOME/bin:}$PATH"

flutter build appbundle --release --build-name="$NAME" --build-number="$CODE"

exec "$PY" "$UPLOAD" \
  --json-key "$KEY" \
  --aab "$AAB" \
  --notes-file "$NOTES" \
  --release-name "$NAME ($CODE)" \
  --track production \
  --status completed
