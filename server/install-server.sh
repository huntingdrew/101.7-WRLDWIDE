#!/bin/bash
# 在云服务器上跑一次（Ubuntu 24.04，root）。由 deploy.sh 远程调用，也可以手动：
#   bash install-server.sh <我的时区> [访问密钥]
# 做的事：装 python3 / caddy / ufw，建 radio 用户，装 systemd 服务，Caddy 自动申请 https 证书，开防火墙。
set -e
TZ_NAME="${1:-America/New_York}"
KEY="${2:-}"
if [ -z "$KEY" ] && [ -f /etc/systemd/system/radio1017.service ]; then
  # 重新部署时沿用原来的密钥，手机上的链接不用换
  KEY=$(grep -oE '^Environment=RADIO_KEY=.*' /etc/systemd/system/radio1017.service | cut -d= -f3)
fi
if [ -z "$KEY" ]; then
  KEY=$(head -c 32 /dev/urandom | base64 | tr -dc 'a-z0-9' | head -c 12)
fi
export DEBIAN_FRONTEND=noninteractive
# 新机器刚开机时 cloud-init 和自动更新会占着 apt，先等它们做完
command -v cloud-init >/dev/null && cloud-init status --wait >/dev/null 2>&1 || true
APT='apt-get -o DPkg::Lock::Timeout=600 -q'
$APT update
$APT install -y python3 caddy ufw curl

id -u radio >/dev/null 2>&1 || useradd -r -m -d /opt/radio1017 -s /usr/sbin/nologin radio
install -o radio -g radio -m 755 /tmp/radio1017.py /opt/radio1017/radio1017.py
if [ -d /tmp/radio1017-photos/photos ]; then
  rm -rf /opt/radio1017/photos
  cp -r /tmp/radio1017-photos/photos /opt/radio1017/photos
fi
mkdir -p /opt/radio1017/data
chown -R radio:radio /opt/radio1017

cat > /etc/systemd/system/radio1017.service <<UNIT
[Unit]
Description=动感101 time-shift recorder
After=network-online.target
Wants=network-online.target

[Service]
User=radio
WorkingDirectory=/opt/radio1017
Environment=RADIO_LOCAL_TZ=$TZ_NAME
Environment=RADIO_BIND=127.0.0.1
Environment=RADIO_KEY=$KEY
ExecStart=/usr/bin/python3 /opt/radio1017/radio1017.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable --now radio1017
systemctl restart radio1017

IP=$(curl -s -4 --max-time 10 https://api.ipify.org || hostname -I | awk '{print $1}')
HOST="$(echo "$IP" | tr . -).sslip.io"
cat > /etc/caddy/Caddyfile <<CADDY
$HOST {
    reverse_proxy 127.0.0.1:8017
}
CADDY
systemctl enable caddy >/dev/null 2>&1 || true
systemctl restart caddy

ufw allow OpenSSH >/dev/null
ufw allow 80/tcp >/dev/null
ufw allow 443/tcp >/dev/null
ufw --force enable >/dev/null

echo "RADIO_URL=https://$HOST/$KEY/"
