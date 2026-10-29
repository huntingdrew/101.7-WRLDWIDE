#!/bin/bash
# 从这台电脑一键部署到云服务器：./deploy.sh <服务器IP> [我的时区] [访问密钥]
# 要求：服务器是 Ubuntu 24.04，root 可以用 SSH 钥匙登录。
# 默认用 ~/.ssh/radio1017_ed25519 这把钥匙，想用别的：RADIO_SSH_KEY=~/.ssh/id_ed25519 ./deploy.sh ...
set -e
IP="$1"; TZ_NAME="${2:-America/New_York}"; KEY="${3:-}"
[ -z "$IP" ] && { echo "用法：./deploy.sh <服务器IP> [时区] [访问密钥]"; exit 1; }
DIR="$(cd "$(dirname "$0")" && pwd)"
KEYFILE="${RADIO_SSH_KEY:-$HOME/.ssh/radio1017_ed25519}"
SSH="ssh -i $KEYFILE -o StrictHostKeyChecking=accept-new root@$IP"
scp -i "$KEYFILE" -o StrictHostKeyChecking=accept-new "$DIR/radio1017.py" "root@$IP:/tmp/radio1017.py"
# 背景风景照一起带过去（几 MB，tar 打包走 ssh）
tar -C "$DIR" -cf - photos | $SSH "rm -rf /tmp/radio1017-photos && mkdir -p /tmp/radio1017-photos && tar -C /tmp/radio1017-photos -xf -"
$SSH "bash -s -- '$TZ_NAME' '$KEY'" < "$DIR/server/install-server.sh"
