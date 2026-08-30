# SASA-IT Deployment Guide

## Voraussetzungen

- Ubuntu 22.04+ Server
- Docker + Docker Compose v2
- Caddy (systemd-Service)
- Domain: sasa-it.de (und Subdomains)
- SSL-Zertifikate (automatisch über Caddy/ACME)

## Stack starten

```bash
cd /home/sasa/sasa-it-service/docker
sudo docker compose -f master-compose.yml up -d
```

## Wichtige Ports

| Dienst | Host-Port | Zugriff |
|--------|-----------|---------|
| Beszel | 18090 | `http://localhost:18090/_/` |
| Authentik | 9000 | via Caddy (auth.sasa-it.de) |
| Nextcloud | 8080 | via Caddy (office.sasa-it.de) |
| Wiki.js | 3001 | via Caddy (wiki.sasa-it.de) |
| Grafana | 3000 | via Caddy (grafana.sasa-it.de) |
| NetBird | 3002 | via Caddy (sso.sasa-it.de) |
| Passbolt | 9001 | via Caddy (passbolt.sasa-it.de) |

**Beszel-Port-Hinweis:** 18090 statt 8090 — Docker-Compose muss `127.0.0.1:18090:8090` einrichten. Standardmäßig läuft der Container auf 8090, aber der Host-Port ist 18090.

## Caddy reloaden (nach Config-Änderungen)

```bash
sudo systemctl reload caddy
```

## .env-Datei

Die `.env` Datei enthält alle Secrets. Sie liegt in:
- `/home/sasa/sasa-it-service/docker/.env` (für docker compose)
- `/home/sasa/sasa-it-service/.env` (alternativ)

**Nicht committen!** Die `.env` ist in `.gitignore` eingetragen.

## Demo-Flow

1. Landing Page: `https://sasa-it.de`
2. Klick auf "Demo starten" → Nova Modal öffnet sich
3. Nova fragt nach Name → persönliche Ansprache
4. "Was ich Betreue" → Cards mit Services
5. "Tic Tac Toe" → Spiel (schließt sich nach ~5 Sek)

## Troubleshooting

### Beszel nicht erreichbar auf Port 18090
- Prüfe: `curl http://localhost:18090/_/` → soll HTTP 200 zurückgeben
- Prüfe Container: `sudo docker compose -f master-compose.yml ps beszel`
- Port-Mapping: muss `127.0.0.1:18090->8090/tcp` sein in `docker ps`

### Nextcloud nicht erreichbar
- Nextcloud AIO benötigt längere Startzeit (~5-10 Minuten beim ersten Start)
- Prüfe Logs: `sudo docker logs nextcloud-aio-mastercontainer --tail 50`
- Status: `curl http://localhost:8080/status.php`

---

*Erstellt: 2026-08-30 von Nova (KI-Assistent)*
*Status: Operational*
