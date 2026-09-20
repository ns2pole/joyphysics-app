#!/bin/bash
# 常駐監視を launchd で入れる（Cursor 終了後も落ちない）
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PYTHON="$(command -v python3)"
PLIST="$HOME/Library/LaunchAgents/com.joyphysics.watchforever.plist"
UID_NUM="$(id -u)"

pkill -f 'joyphysics_watch_forever.py' 2>/dev/null || true
pkill -f 'joyphysics_watch_keepalive' 2>/dev/null || true
launchctl bootout "gui/${UID_NUM}/com.joyphysics.watchforever" 2>/dev/null || true
sleep 0.3

cat >"$PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.joyphysics.watchforever</string>
  <key>ProgramArguments</key>
  <array>
    <string>${PYTHON}</string>
    <string>-u</string>
    <string>${ROOT}/scripts/joyphysics_watch_forever.py</string>
  </array>
  <key>WorkingDirectory</key>
  <string>${ROOT}</string>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>ThrottleInterval</key>
  <integer>2</integer>
  <key>StandardOutPath</key>
  <string>/tmp/joyphysics_watch_forever.log</string>
  <key>StandardErrorPath</key>
  <string>/tmp/joyphysics_watch_forever.log</string>
  <key>EnvironmentVariables</key>
  <dict>
    <key>PATH</key>
    <string>/usr/local/share/flutter/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    <key>JAVA_HOME</key>
    <string>/usr/local/var/homebrew/tmp/.cellar/openjdk@17/17.0.20.1</string>
  </dict>
</dict>
</plist>
PLIST

launchctl bootstrap "gui/${UID_NUM}" "$PLIST"
sleep 1
launchctl print "gui/${UID_NUM}/com.joyphysics.watchforever" | head -15
echo "OK: launchd KeepAlive 監視中"
