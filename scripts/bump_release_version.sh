#!/usr/bin/env bash
# Local helper: bump pubspec patch + build (5.0.0+102 -> 5.0.1+103), sync iOS files.
# Usage: ./scripts/bump_release_version.sh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

VER_LINE=$(grep '^version:' pubspec.yaml | head -1 | awk '{print $2}' | tr -d "'\"")
NAME="${VER_LINE%+*}"
CODE="${VER_LINE#*+}"
CODE=$(echo "$CODE" | tr -dc '0-9')
[ -n "$CODE" ] || CODE=0

IFS='.' read -r MAJOR MINOR PATCH <<EOF
${NAME}
EOF
MAJOR=${MAJOR:-0}
MINOR=${MINOR:-0}
PATCH=$(echo "${PATCH:-0}" | tr -dc '0-9')
[ -n "$PATCH" ] || PATCH=0

NEW_NAME="${MAJOR}.${MINOR}.$((PATCH + 1))"
NEW_CODE=$((CODE + 1))

# Optional: if ASC latest is available via env override
if [ -n "${FORCE_BUILD_NUMBER:-}" ]; then
  NEW_CODE="$FORCE_BUILD_NUMBER"
fi

python3 - <<PY
from pathlib import Path
import json, re

new_name = "$NEW_NAME"
new_code = "$NEW_CODE"

pub = Path("pubspec.yaml")
text = pub.read_text(encoding="utf-8")
text2, n = re.subn(r"(?m)^version:\s*.*$", f"version: {new_name}+{new_code}", text, count=1)
if n != 1:
    raise SystemExit("failed to rewrite pubspec version")
pub.write_text(text2, encoding="utf-8")

Path("version.json").write_text(
    json.dumps(
        {
            "app_name": "joyphysics",
            "version": new_name,
            "build_number": str(new_code),
            "package_name": "joyphysics",
        },
        ensure_ascii=False,
    )
    + "\n",
    encoding="utf-8",
)

plist = Path("ios/Runner/Info.plist")
pt = plist.read_text(encoding="utf-8")
pt = re.sub(
    r"(<key>CFBundleShortVersionString</key>\s*<string>)[^<]+(</string>)",
    rf"\g<1>{new_name}\2",
    pt,
    count=1,
)
pt = re.sub(
    r"(<key>CFBundleVersion</key>\s*<string>)[^<]+(</string>)",
    rf"\g<1>{new_code}\2",
    pt,
    count=1,
)
plist.write_text(pt, encoding="utf-8")

pbx = Path("ios/Runner.xcodeproj/project.pbxproj")
bt = pbx.read_text(encoding="utf-8")
bt = re.sub(r"MARKETING_VERSION = [^;]+;", f"MARKETING_VERSION = {new_name};", bt)
bt = re.sub(r"CURRENT_PROJECT_VERSION = [^;]+;", f"CURRENT_PROJECT_VERSION = {new_code};", bt)
pbx.write_text(bt, encoding="utf-8")

print(f"Bumped to {new_name}+{new_code}")
PY
