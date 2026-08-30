# ═══════════════════════════════════════════════════════════════════════════════
# SASA-IT Beszel Monitoring — Übersicht & Konfiguration
# ═══════════════════════════════════════════════════════════════════════════════
# Port: 18090 (externe Erreichbarkeit)
# Intern: 8090 (Container-Port)
# Admin-Panel: http://localhost:18090/_/
# ═══════════════════════════════════════════════════════════════════════════════

## Beszel im SASA-IT-Stack

**Beszel** ist das Monitoring-Dashboard für den gesamten SASA-IT-Stack. Es überwacht:
- Docker-Container (CPU, RAM, Netzwerk, Uptime)
- Server-Ressourcen (CPU, RAM, Disk, Temperatures)
- NetBird-VPN-Verbindungen
- Service-Health-Status

## Port-Konfiguration (WICHTIG!)

| Kontext | Port | Beschreibung |
|---------|------|--------------|
| Container (intern) | 8090 | Beszel zugreift auf den Container-Port |
| Host (extern via Firewall/SSH) | **18090** | WICHTIG: Docker-Compose muss diesen Port public machen |
| Caddy-Proxy | (optional) | Beszel kann über Caddy auf einem eigenen Subdomain proxied werden |

### Warum 18090?

Der Beszel-Container läuft standardmäßig auf Port 8090, aber das SASA-IT-Docker-Compose-Master bindet ihn an Port 18090 auf dem Host, um Konflikte mit anderen Diensten zu vermeiden (Grafana nutzt 3000, Beszel-Agent nutzt keine additional Ports).

**Datei:** `docker/master-compose.yml`
**Eintrag:**
```yaml
  beszel:
    image: henrygd/beszel:latest
    container_name: beszel
    restart: unless-stopped
    ports:
      - "127.0.0.1:18090:8090"   # ← WICHTIG: Host-Python auf 18090!
    volumes:
      - beszel_data:/app/data
      - beszel_socket:/beszel_socket
    environment:
      - APP_URL=http://localhost:8090
    networks:
      - sasa-it-net
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8090/_/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
```

### Zugriff

- **Lokal:** `http://localhost:18090/_/`
- **Remote über SSH Tunnel:** `ssh user@v76432.1blu.de -L 18090:localhost:18090` dann `http://localhost:18090/_/`
- **Firewall-Regel:** Port 18090 ist nur auf localhost gebunden (127.0.0.1:18090). Externzugriff nur über SSH Tunnel oder VPN (NetBird).

## Beszel-Agent

Der Beszel-Agent läuft als separater Container und sammelt Metriken. Er kommuniziert mit dem Beszel-Server über einen Unix-Socket.

**Konfiguration:**
```yaml
  beszel-agent:
    image: henrygd/beszel-agent:latest
    container_name: beszel-agent
    restart: unless-stopped
    network_mode: host
    volumes:
      - ./monitoring/beszel_agent_data:/var/lib/beszel-agent
      - beszel_socket:/beszel_socket
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /sys:/sys:ro
      - /proc:/proc:ro
    environment:
      - LISTEN=/beszel_socket/beszel.sock
      - HUB_URL=http://localhost:8090    # ← Interner Container-Port
      - KEY=${BEZEL_AGENT_KEY:?Beszel agent key required}
    cap_add:
      - SYS_PTRACE
    security_opt:
      - seccomp:unconfined
```

## Admin-Panel

URL: `http://localhost:18090/_/`

Das Admin-Panel zeigt:
- Übersicht aller Container- und Server-Metriken
- CPU, RAM, Netzwerk, Disk Usage
- Docker-Container-Status (gesamt, nach Service)
- Historische Daten (wochenlang gespeichert)
- Alert-Konfiguration (optional: E-Mail-Benachrichtigung bei Ausfällen)

## Bekannte Probleme / Fixes

### Problem: Beszel war auf Port 8090 statt 18090

**Ursache:** Das Master-Compose-File hatte `127.0.0.1:8090:8090` statt `127.0.0.1:18090:8090`. Das führte dazu, dass externe Zugriffe (oder SSH Tunnels) auf Port 18090 keinen Dienst mehr fanden.

**Fix:** Patched in `docker/master-compose.yml` auf `127.0.0.1:18090:8090`.

**Status:** ✓ Behoben am 2026-08-30.

## Backup & Wiederherstellung

### Daten-Backup

Beszel speichert alle Daten in einem Docker-Volume (`beszel_data`). Für Backups:
```bash
cd /home/sasa/sasa-it-service/docker
sudo docker run --rm -v beszel_data:/data -v $(pwd):/backup alpine tar czf /backup/beszel-backup-$(date +%Y%m%d).tar.gz -C /data .
```

### Wiederherstellung
```bash
cd /home/sasa/sasa-it-service/docker
sudo docker run --rm -v beszel_data:/data -v $(pwd):/backup alpine tar xzf /backup/beszel-backup-YYYYMMDD.tar.gz -C /data
sudo docker compose -f master-compose.yml restart beszel
```

## Integration mit SASA-IT-Stack

| Service | Integration |
|---------|-------------|
| Docker | Beszel-Agent überwacht alle Container via Docker Socket |
| NetBird | Beszel zeigt VPN-Verbindungen an (wenn Status-Exporter aktiv) |
| Authentik | Keine direkte Integration (Monitoring nur) |
| Nextcloud | Beszel zeigt Nextcloud-Container-Status, CPU, RAM |
| Grafana | Paralleles Monitoring — Beszel fokusiert auf Container, Grafana auf Business-Metriken |

## URL-Übersicht

| Zweck | URL |
|-------|-----|
| Admin-Panel | `http://localhost:18090/_/` |
| Health-Check | `http://localhost:18090/_/` (HTTP 200 = OK) |
| Prometheus-Metriken (falls aktiviert) | `/metrics` |

## Dokumentations-Status

- **Wiki-Seite:** diese Datei (wiki/beszel-monitoring.md)
- **Architekturdaten:** sasa-it-architecture.md
- **Docker-Compose:** docker/master-compose.yml
- **Caddy:** docker/caddy/Caddyfile (keine Caddy-Integration für Beszel, da localhost-only)

---

*Erstellt: 2026-08-30 von Nova (KI-Assistent)*
*Status: In Betrieb*
