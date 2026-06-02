# homelab

Infrastructure monorepo for `sudakov.site`. Manages both the Raspberry Pi (reverse proxy, deploy) and the PC (NVIDIA GPU services, machine bootstrap).

## What's here

| Directory | What |
|---|---|
| `caddy/Caddyfile` | Reverse proxy config — Pi (`sudakov.site`, `*.sudakov.site`) |
| `jellyfin/compose.yml` | Jellyfin media server — PC (NVIDIA GPU, Movies + TV) |
| `pc/setup-pc.sh` | Bootstrap a fresh Debian PC (NVIDIA drivers, Docker, dotfiles) |
| `scripts/deploy.sh` | One-command deploy — Pi: Caddy, site, agent, all compose services |
| `scripts/check_health.sh` | Status snapshot — Pi: systemd, docker, HTTP endpoints, disk |

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
├── sudakov-site/     # github.com/DenisSud/site
├── pi-agent-web/     # github.com/su-computer-company/pi-agent-web
└── homelab/          # github.com/DenisSud/homelab (this repo)
```

From your dev machine:

```bash
git add -A && git commit -m "..." && git push
ssh denis@192.168.1.6
cd ~/su-underscore/homelab && git pull
./scripts/deploy.sh
```

## PC setup

On a fresh Debian PC:

```bash
git clone git@github.com:DenisSud/homelab.git
cd homelab
bash pc/setup-pc.sh
```

## Health check

```bash
ssh denis@192.168.1.6 "~/su-underscore/homelab/scripts/check_health.sh"
```
