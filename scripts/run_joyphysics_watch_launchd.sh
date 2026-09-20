#!/bin/bash
# LaunchAgent 用: joyphysics 常駐監視（落ちたら launchd が再起動）
ROOT="/Users/nakamurashunsuke/Programming/選択項目から作成したフォルダ/joyphysics"
PY="$ROOT/scripts/joyphysics_watch_forever.py"
LOG="/tmp/joyphysics_watch_forever.log"
exec /usr/local/bin/python3 -u "$PY" >>"$LOG" 2>&1
