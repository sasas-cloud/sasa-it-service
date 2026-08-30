# SASA-IT Architektur — Übersicht der Dienste & Ports

## Server-Übersicht

**Host:** v76432.1blu.de (Ubuntu Server)
**Standort:** Deutschland (1blu)
**Primäres Domain:** sasa-it.de

## Service-Port-Matrix

| Service | Intern (Container) | Host-Port |Extern (via Caddy/HTTPS) | Status |
|---------|-------------------|-----------|------------------------|--------|
| **Landing Page** | — | — | `https://sasa-it.de` | ✓ via Caddy file_server |
| **Authentik SSO** | 9000 | 127.0.0.1:9000 | `https://auth.sasa-it.de` | ✓ |
| **Nextcloud AIO** | 8080 | 127.0.0.1:8080 | `https://office.sasa-it.de` | ✓ (Container neu gestartet) |
| **NetBird Dashboard** | 3000 | 127.0.0.1:3002 | `https://sso.sasa-it.de` | ✓ |
| **Wiki.js** | 3000 | 127.0.0.1:3001 | `https://wiki.sasa-it.de` | ✓ |
| **Grafana** | 3000 | 127.0.0.1:3000 | `https://grafana.sasa-it.de` | ✓ |
| **Beszel Monitoring** | **8090** | **127.0.0.1:18090** | (localhost/SSH-tunnel) | ✓ |
| **Passbolt** | 80 | 127.0.0.1:9001 | `https://passbolt.sasa-it.de` | ✓ (via Tailscale 100.104.100.4) |
| **Wazuh** | 443 | — | `https://security.sasa-it.de` | ✓ (via Tailscale 100.125.176.124) |

## Port-Key

### Beszel — Monitoring

Das war das Hauptproblem bei der Demo: Beszel war auf Port 8090 konfiguriert, aber der Host-Expectation war 18090. Der Fix: Docker-Compose-Port-Mapping von `127.0.0.1:8090:8090` auf `127.0.0.1:18090:8090`.

**Eintrag in docker/master-compose.yml:**
```yaml
ports:
  - "127.0.0.1:18090:8090"
```

**Admin-Panel:** `http://localhost:18090/_/`

### NetBird Management

Port 3002 auf dem Host (Container-Port 3000). Wird als `sso.sasa-it.de` über Caddy proxied. Das ist das NetBird Management Dashboard (kein SSO! Es ist der NetBird-Admin-Console).

## Caddy-Konfiguration

Caddy (systemd-Service, nicht containerisiert) ist das SSL-Terminal und Reverse-Proxy für alle externen Dienste.

**Caddyfile:** `/home/sasa/sasa-it-service/docker/caddy/Caddyfile`

**Wichtige Proxy-Regeln:**
- `sasa-it.de` → `/var/www/landing-page` (statische Dateien)
- `auth.sasa-it.de` → `authentik:9000` (authentik-server Container)
- `office.sasa-it.de` → `nextcloud-aio:8080` (Nextcloud)
- `sso.sasa-it.de` → `netbird:3000` (NetBird Dashboard)
- `wiki.sasa-it.de` → `wiki:3000` (Wiki.js)
- `grafana.sasa-it.de` → `grafana:3000` (Grafana)

**Beszel:** Nicht über Caddy proxied — nur lokal über SSH Tunnel verfügbar (Port 18090 ist auf 127.0.0.1 gebunden).

## Docker-Netzwerke

- **Network:** `sasa-it-net` (bridge)
- Alle Container kommunizieren über dieses interne Netzwerk
- Container-Namen (DNS innerhalb des Netzwerks): `authentik`, `nextcloud-aio`, `netbird`, `wiki`, `grafana`, `beszel`, `beszel-agent`, `passbolt`, etc.

## Datenbanken

| Datenbank | Container | Port | Verwendung |
|-----------|-----------|------|-------------|
| PostgreSQL | authentik-postgres | 5432 | Authentik |
| MariaDB | nextcloud-db | 3306 | Nextcloud |
| PostgreSQL | wikijs-db | 5432 | Wiki.js |
| MariaDB | passbolt-db | 3306 | Passbolt |
| Redis | authentik-redis | 6379 | Authentik Cache |
| Redis | redis-nextcloud | 6379 | Nextcloud Cache |

## Backup-Strategie

Alle persistenten Daten liegen in Docker-Volumes:
- `nextcloud_data`, `nextcloud_db`, `nextcloud_aio_mastercontainer`
- `authentik_media`, `authentik_certs`, `authentik_templates`, `authentik_postgres`, `authentik_redis`
- `wikijs_data`, `wikijs_db`
- `beszel_data`, `beszel_socket`
- `netbird_data`
- `passbolt_data`, `passbolt_db`

Für Backups: Volumes sind persistent — ein `docker compose down` zerstört sie nicht.

---

*Erstellt: 2026-08-30 von Nova (KI-Assistent)*
*Letzte Aktualisierung: 2026-08-30 (Beszel-Port-Fix dokumentiert)*
