#!/bin/bash
# 装成开机自启的后台服务。
# 程序和录音放在 ~/Library/Application Support/radio1017（macOS 不让后台服务读桌面，而且这样更隐形）。
set -e
SRC="$(cd "$(dirname "$0")" && pwd)"
APP="$HOME/Library/Application Support/radio1017"
LABEL=com.radio1017
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

mkdir -p "$APP/data" "$HOME/Library/LaunchAgents"
cp "$SRC/radio1017.py" "$APP/radio1017.py"
rm -rf "$APP/photos"; cp -R "$SRC/photos" "$APP/photos"

cat > "$PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/bin/caffeinate</string>
    <string>-i</string>
    <string>/usr/bin/python3</string>
    <string>$APP/radio1017.py</string>
  </array>
  <key>WorkingDirectory</key><string>$APP</string>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
  <key>ProcessType</key><string>Background</string>
  <key>LowPriorityIO</key><true/>
  <key>StandardOutPath</key><string>$APP/data/radio.log</string>
  <key>StandardErrorPath</key><string>$APP/data/radio.log</string>
</dict>
</plist>
PLIST

launchctl unload "$PLIST" 2>/dev/null || true
pkill -f "radio1017.py" 2>/dev/null || true   # 停掉手动跑着的实例，免得端口冲突
sleep 1
launchctl load "$PLIST"
sleep 2

IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || true)
NAME=$(scutil --get LocalHostName 2>/dev/null || true)
echo "已安装并启动，以后开机自动运行。"
[ -n "$IP" ]   && echo "手机打开： http://$IP:8017"
[ -n "$NAME" ] && echo "或者：     http://$NAME.local:8017"
TS=/Applications/Tailscale.app/Contents/MacOS/Tailscale
if [ -x "$TS" ]; then
  TSIP=$("$TS" ip -4 2>/dev/null | head -1)
  [ -n "$TSIP" ] && echo "出门在外： http://$TSIP:8017   （手机开着 Tailscale）"
fi
echo "程序和录音：$APP"
echo "日志：      $APP/data/radio.log"
