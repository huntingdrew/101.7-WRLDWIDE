#!/bin/bash
# 停止并移除开机自启。加 --purge 连录音一起删。
APP="$HOME/Library/Application Support/radio1017"
PLIST="$HOME/Library/LaunchAgents/com.radio1017.plist"
launchctl unload "$PLIST" 2>/dev/null || true
rm -f "$PLIST"
pkill -f "radio1017.py" 2>/dev/null || true
if [ "$1" = "--purge" ]; then
  rm -rf "$APP"
  echo "已停止，自启和录音都删了。"
else
  echo "已停止并移除自启。录音还在：$APP"
  echo "连录音一起删：./uninstall.sh --purge"
fi
