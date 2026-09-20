#!/usr/bin/env bash
# Start a Codemagic workflow via REST API (no UI click).
#
# Setup (once):
#   1. Codemagic → Account settings → API token → Show / Generate
#   2. Save the token to either:
#        export CODEMAGIC_API_TOKEN='...'
#      or
#        echo '...' > .codemagic_api_token   # gitignored
#
# Usage:
#   ./scripts/start_codemagic_build.sh
#   ./scripts/start_codemagic_build.sh ios-app-store-release main
#   ./scripts/start_codemagic_build.sh <workflowId> <branch>
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

APP_ID="${CODEMAGIC_APP_ID:-6aacc49b5e2c9a8f688e63ca}"
WORKFLOW_ID="${1:-ios-app-store-release}"
BRANCH="${2:-main}"

TOKEN="${CODEMAGIC_API_TOKEN:-${CM_API_TOKEN:-}}"
if [[ -z "$TOKEN" && -f "$ROOT/.codemagic_api_token" ]]; then
  TOKEN="$(tr -d '[:space:]' < "$ROOT/.codemagic_api_token")"
fi
if [[ -z "$TOKEN" ]]; then
  echo "ERROR: Codemagic API token がありません。"
  echo "  Account settings → API token を .codemagic_api_token に保存するか、"
  echo "  CODEMAGIC_API_TOKEN を export してください。"
  echo "  設定ページ: https://codemagic.io/user/settings"
  exit 1
fi

echo "Starting Codemagic build:"
echo "  appId=$APP_ID"
echo "  workflowId=$WORKFLOW_ID"
echo "  branch=$BRANCH"

RESP="$(curl -sS -w '\n%{http_code}' \
  -X POST 'https://api.codemagic.io/builds' \
  -H 'Content-Type: application/json' \
  -H "x-auth-token: $TOKEN" \
  -d "{\"appId\":\"$APP_ID\",\"workflowId\":\"$WORKFLOW_ID\",\"branch\":\"$BRANCH\"}")"

HTTP="$(printf '%s\n' "$RESP" | tail -n1)"
BODY="$(printf '%s\n' "$RESP" | sed '$d')"

echo "HTTP $HTTP"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"

if [[ "$HTTP" != "200" && "$HTTP" != "201" ]]; then
  exit 1
fi

BUILD_ID="$(printf '%s' "$BODY" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("buildId") or d.get("_id") or "")' 2>/dev/null || true)"
if [[ -n "$BUILD_ID" ]]; then
  echo "Build URL: https://codemagic.io/app/${APP_ID}/build/${BUILD_ID}"
fi
