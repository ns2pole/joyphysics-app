#!/usr/bin/env bash
# Build iOS IPA and submit for App Store review (requires full Xcode.app).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ ! -d /Applications/Xcode.app ]]; then
  echo "Xcode.app が見つかりません。App Store から Xcode をインストールしてください。"
  open "macappstore://apps.apple.com/app/xcode/id497799835" || true
  exit 1
fi

sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
xcodebuild -version

NOTES_FILE="fastlane/metadata/android/ja-JP/changelogs/101.txt"
NOTES="$(cat "$NOTES_FILE")"

flutter pub get
(cd ios && pod install)

# Sync versions from pubspec
flutter build ipa --release \
  --build-name=5.0.0 \
  --build-number=101 \
  --export-options-plist=ios/ExportOptions.plist

IPA=$(ls -1 build/ios/ipa/*.ipa | head -1)
echo "Built IPA: $IPA"

# Prefer App Store Connect API key if present
if [[ -n "${APP_STORE_CONNECT_API_KEY_PATH:-}" ]]; then
  xcrun altool --upload-app --type ios \
    --file "$IPA" \
    --apiKey "${APP_STORE_CONNECT_API_KEY_ID}" \
    --apiIssuer "${APP_STORE_CONNECT_ISSUER_ID}"
  echo "Uploaded via altool. Submit for review in App Store Connect if needed."
else
  # fastlane deliver path (Apple ID)
  export PATH="/usr/local/Homebrew/Library/Homebrew/vendor/portable-ruby/4.0.7/bin:${PATH}"
  if command -v bundle >/dev/null && [[ -f Gemfile ]]; then
    bundle exec fastlane ios release_ios notes:"$NOTES" || {
      echo "fastlane failed; IPA is at $IPA — upload manually via Transporter / App Store Connect."
      exit 1
    }
  else
    echo "Install fastlane or set APP_STORE_CONNECT_API_KEY_* to upload."
    echo "IPA ready: $IPA"
    exit 1
  fi
fi
