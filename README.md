# homelab

Infrastructure monorepo for the `sudakov.site` homelab. Runs on a Debian-based Raspberry Pi.

## What's here

| Directory | What |
|---|---|
| `caddy/Caddyfile` | Reverse proxy config (`sudakov.site`, `*.sudakov.site`) |
| `jellyfin/compose.yml` | Jellyfin media server (Docker Compose) |
| `scripts/deploy.sh` | One-command deploy: Caddy, site, agent, all compose services |
| `scripts/check_health.sh` | Status snapshot: systemd, docker, HTTP endpoints, disk |

## Adding a service

1. Create a new directory: `mkdir myservice && cd myservice`
2. Write a `compose.yml` with the Docker Compose stack
3. Add the reverse-proxy block to `caddy/Caddyfile`
4. Run `scripts/deploy.sh`

Each service is self-contained. Start, stop, or modify one without touching the others:

```bash
cd jellyfin && docker compose up -d
cd jellyfin && docker compose down
cd jellyfin && docker compose logs -f
```

## Deploy

All source repos live as siblings under `~/su-underscore/`:

```
~/su-underscore/
├── sudakov-site/     # github.com/su-underscore/sudakov-site
├── pi-agent-web/     # github.com/su-underscore/pi-agent-web
└── homelab/          # github.com/su-underscore/homelab (this repo)
```

From your dev machine:

```bash
git add -A && git commit -m "..." && git push
ssh denis@192.168.1.6
cd ~/su-underscore/homelab && git pull
./scripts/deploy.sh
```

## Health check

```bash
ssh denis@192.168.1.6 "~/su-underscore/homelab/scripts/check_health.sh"
```
