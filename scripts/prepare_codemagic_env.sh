#!/usr/bin/env bash
# Codemagic の Environment variables にコピペする値を、手元のファイルから生成する。
# 実行: ./scripts/prepare_codemagic_env.sh
# 出力: codemagic-env-paste.txt（git 除外。秘密情報を含む）
# joyphysics は Firebase なし — App Store Connect API キーのみ。
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/codemagic-env-paste.txt"
P8="${ASC_P8_PATH:-$HOME/.appstoreconnect/private_keys/AuthKey_ATBD5UGJTG.p8}"

if [[ ! -f "$P8" ]]; then
  echo "不足しているファイル: App Store Connect API key: $P8" >&2
  exit 1
fi

{
  echo "# Codemagic 用 — このファイルはコミットしない（.gitignore 済み）"
  echo "# 生成: $(date -Iseconds)"
  echo ""
  echo "=== グループ: appstore_credentials ==="
  echo ""
  echo "## Variable: APP_STORE_CONNECT_PRIVATE_KEY (Secret)"
  echo "## Type: Secret / Secure"
  cat "$P8"
  echo ""
  echo "=== codemagic.yaml の vars（通常は変更不要）==="
  echo "APP_STORE_CONNECT_KEY_IDENTIFIER=ATBD5UGJTG"
  echo "APP_STORE_CONNECT_ISSUER_ID=c64fb6be-f1d2-4e04-80b5-2841def3da52"
  echo "APP_STORE_APPLE_ID=6748957698"
  echo ""
  echo "=== Code signing（Team settings → Upload）==="
  echo "p12: $ROOT/codemagic-signing/joyphysics-distribution.p12"
  echo "p12 password file: $ROOT/codemagic-signing/.p12_password"
  echo "profile: $ROOT/codemagic-signing/com.joyphysics.appstore.mobileprovision"
} > "$OUT"

echo "Wrote: $OUT"
echo ""
echo "次に Codemagic UI で:"
echo "  1. appstore_credentials → APP_STORE_CONNECT_PRIVATE_KEY に p8 ブロックを貼る"
echo "  2. Code signing → p12 と .mobileprovision を Upload（パスワードは .p12_password）"
echo "  3. ワークフロー ios-app-store-release を実行"
