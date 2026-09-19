#!/usr/bin/env bash
# Submit Android 5.0.0+101 AAB to Google Play production (for review).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

AAB="build/app/outputs/bundle/release/app-release.aab"
KEY="fastlane/joy-physics-fastlane-49212c4fb3b6.json"
NOTES="fastlane/metadata/android/ja-JP/changelogs/101.txt"
PY="$ROOT/.tools/playupload/bin/python"
UPLOAD="$ROOT/.tools/upload_play.py"

if [[ ! -x "$PY" ]]; then
  echo "Play upload venv missing. Creating..."
  python3 -m venv .tools/playupload
  .tools/playupload/bin/pip install -U pip
  .tools/playupload/bin/pip install --only-binary=:all: google-api-python-client google-auth
fi

if [[ ! -f "$AAB" ]]; then
  echo "AAB missing; building..."
  JDK=$(ls -d "$HOME/.jdks"/jdk-17* | head -1)
  export JAVA_HOME="$JDK/Contents/Home"
  export ANDROID_HOME="${ANDROID_HOME:-/usr/local/share/android-commandlinetools}"
  export PATH="$JAVA_HOME/bin:$PATH"
  flutter build appbundle --release --build-name=5.0.0 --build-number=101
fi

exec "$PY" "$UPLOAD" \
  --json-key "$KEY" \
  --aab "$AAB" \
  --notes-file "$NOTES" \
  --track production \
  --status completed
