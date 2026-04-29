#!/usr/bin/env bash
# Sync configs and (re)start all services. Idempotent.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

SUDAKOV_SITE="$HOME/su-underscore/sudakov-site"
AGENT_WEB="$HOME/su-underscore/pi-agent-web"

echo "==> Caddyfile -> /etc/caddy/Caddyfile"
sudo install -m 0644 "$REPO_DIR/../caddy/Caddyfile" /etc/caddy/Caddyfile
sudo caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile

echo "==> site/ -> /srv/sudakov-site/"
sudo mkdir -p /srv/sudakov-site
sudo rsync -a --delete "$SUDAKOV_SITE/site/" /srv/sudakov-site/

echo "==> reload caddy"
sudo systemctl reload caddy

echo "==> APPEND_SYSTEM.md -> ~/.pi/agent/APPEND_SYSTEM.md"
mkdir -p ~/.pi/agent
cp -f "$AGENT_WEB/APPEND_SYSTEM.md" ~/.pi/agent/APPEND_SYSTEM.md

echo "==> ensure uploads directory"
mkdir -p ~/pi-uploads

echo "==> pi-agent-web: npm install + systemd"
(cd "$AGENT_WEB" && npm install --omit=dev)
sudo install -m 0644 "$AGENT_WEB/pi-agent-web.service" /etc/systemd/system/pi-agent-web.service
sudo systemctl daemon-reload
sudo systemctl enable pi-agent-web --now
sudo systemctl restart pi-agent-web

for svc_dir in "$REPO_DIR"/../*/; do
	name=$(basename "$svc_dir")
	[ "$name" = "caddy" ] && continue
	[ "$name" = "scripts" ] && continue
	if [ -f "$svc_dir/compose.yml" ] || [ -f "$svc_dir/docker-compose.yml" ]; then
		echo "==> $name: docker compose pull && up -d"
		(cd "$svc_dir" && docker compose pull && docker compose up -d)
	fi
done

echo "==> done"
