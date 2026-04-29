#!/usr/bin/env bash
# Quick health snapshot. Non-fatal: prints status of everything regardless of failures.
set -uo pipefail

bold() { printf '\n\033[1m%s\033[0m\n' "$1"; }

bold "Caddy (systemd)"
systemctl is-active caddy && systemctl is-enabled caddy || true

bold "Pi Agent Web (systemd)"
systemctl is-active pi-agent-web && systemctl is-enabled pi-agent-web || true

bold "Docker containers"
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

bold "HTTP endpoints"
for url in \
	"http://localhost:8096/health" \
	"http://localhost:3099/api/me" \
	"https://sudakov.site" \
	"https://jellyfin.sudakov.site" \
	"https://agent.sudakov.site"; do
	code=$(curl -s -o /dev/null -w '%{http_code}' -L --max-time 5 "$url" || echo "ERR")
	printf '  %-40s -> %s\n' "$url" "$code"
done

bold "Disk"
df -h / 2>/dev/null | tail -n +1
