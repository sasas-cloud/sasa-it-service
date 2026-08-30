# SASA-IT Platform Deployment Dokumentation

## Übersicht

Dieses Repository enthält die vollständige Infrastructure-as-Code-Konfiguration für die SASA-IT Platform.  
Server: `v76432.1blu.de` (1blu.de, Ubuntu)  
Einheitlicher Host: Alle Dienste auf einem Server (Single-Host Deploymentsmodell)

## Architektur

```
Internet
  │
  ├─ Caddy (systemd, Port 80/443)
  │   ├─ sasa-it.de          → /var/www/landing-page (file_server)
  │   ├─ office.sasa-it.de   → Nextcloud AIO (127.0.0.1:8080)
  │   ├─ auth.sasa-it.de     → Authentik SSO    (127.0.0.1:9000)
  │   ├─ wiki.sasa-it.de     → Wiki.js         (127.0.0.1:3001)
  │   ├─ grafana.sasa-it.de  → Grafana         (127.0.0.1:3000)
  │   ├─ sso.sasa-it.de      → NetBird Mgmt    (127.0.0.1:3002)
  │   ├─ passbolt.sasa-it.de → Passbolt        (Tailscale: 100.104.100.4:443)
  │   ├─ security.sasa-it.de → Wazuh           (Tailscale: 100.125.176.124:443)
  │   └─ monitor.sasa-it.de  → Beszel          (127.0.0.1:18090)
  │
  └─ Docker Compose (master-compose.yml)
      ├─ Nextcloud AIO (apache, mysql, redis)
      ├─ Authentik (server, worker, postgres, redis)
      ├─ Wiki.js (node, postgres)
      ├─ Beszel + Beszel-Agent (Monitoring)
      ├─ Grafana
      ├─ NetBird Management
      └─ Passbolt (mysql)
```

## Dateien im Repository

| Pfad | Zweck |
|------|-------|
| `docker/master-compose.yml` | Haupt-Docker-Compose: alle Services |
| `docker/caddy/Caddyfile` | Produktiv-Caddy-Config (sync mit /etc/caddy/Caddyfile) |
| `docker/authentik/Caddyfile` | Authentik-spezifische Caddy Konfiguration (optional) |
| `landing-page/index.html` | Haupt-Landingpage (wird nach /var/www/landing-page deployed) |
| `docker/authentik/.env.example` | Beispiel-Umgebungsvariablen für Authentik |
| `docker/authentik/BRANDING.md` | Branding-Anleitung für Authentik |
| `docs/` | Dokumentation (Nextcloud Multi-Instance, etc.) |
| `wiki/` | Wiki-Dokumentation (Markdown) |

## Deploy-Prozess

### 1. Docker Stack starten/neu starten

```bash
cd /home/sasa/sasa-it-service/docker
sudo docker compose -f master-compose.yml down --remove-orphans --timeout=30
sudo docker compose -f master-compose.yml up -d
```

### 2. Landing Page deployen

```bash
cd /home/sasa/sasa-it-service/landing-page
sudo cp index.html /var/www/landing-page/index.html
diff index.html /var/www/landing-page/index.html
```

### 3. Caddy aktualisieren (falls Caddyfile geändert)

```bash
sudo cp /home/sasa/sasa-it-service/docker/caddy/Caddyfile /etc/caddy/Caddyfile
sudo systemctl reload caddy
# oder bei tiefgreifenden Änderungen:
sudo systemctl restart caddy
```

### 4. Validierung

```bash
# Container-Status
sudo docker compose -f /home/sasa/sasa-it-service/docker/master-compose.yml ps

# Lokale Endpunkt-Tests (vor Caddy)
curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/status.php   # Nextcloud
curl -s -o /dev/null -w "%{http_code}" http://localhost:9000/             # Authentik
curl -s -o /dev/null -w "%{http_code}" http://localhost:3001/             # Wiki.js
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/             # Grafana
curl -s -o /dev/null -w "%{http_code}" http://localhost:18090/_/          # Beszel

# Caddy HTTP-Rewrite-Tests (Port 80 → 308 Redirect erwartet)
curl -s -o /dev/null -w "%{http_code}" http://localhost/                                  # sasa-it.de
curl -s -o /dev/null -w "%{http_code}" -H "Host: office.sasa-it.de" http://localhost/    # Nextcloud
curl -s -o /dev/null -w "%{http_code}" -H "Host: auth.sasa-it.de" http://localhost/      # Authentik
curl -s -o /dev/null -w "%{http_code}" -H "Host: wiki.sasa-it.de" http://localhost/      # Wiki.js
curl -s -o /dev/null -w "%{http_code}" -H "Host: monitor.sasa-it.de" http://localhost/   # Beszel
```

### 5. Caddy Zertifikatsstatus prüfen

```bash
openssl s_client -connect localhost:443 -servername sasa-it.de </dev/null 2>&1 | grep -E "CN=|NotAfter"
```

## Known Issues & Fixes

### Nextcloud AIO Volume-Problem

**Problem:** Nextcloud AIO erwartet ein Docker-Volume namens `nextcloud_aio_mastercontainer`, 
aber Docker Compose prefixiert Volumes standardmäßig mit dem Projektnamen 
(`docker_nextcloud_aio_mastercontainer`), wodurch der Container das Volume nicht findet 
und im Restart-Schleife landet.

**Lösung:** Volume als `external: true` deklarieren:

```yaml
volumes:
  nextcloud_aio_mastercontainer:
    external: true
```

```bash
# Volume mit korrektem Namen erstellen
sudo docker volume create nextcloud_aio_mastercontainer

# Compose neu starten
sudo docker compose -f master-compose.yml up -d nextcloud-aio
```

Das Volumen muss exakt `nextcloud_aio_mastercontainer` heißen — der Container prüft 
intern den Mount-Namen.

### Caddyfile-Synchronisation

Das Repo enthält `docker/caddy/Caddyfile`. Das Produktivsystem verwendet 
`/etc/caddy/Caddyfile` (von systemd geladen). Nach Änderungen am Repo muss die Datei 
manuell ins System kopiert werden:

```bash
sudo cp docker/caddy/Caddyfile /etc/caddy/Caddyfile
sudo systemctl reload caddy
```

### Wiki.js Unhealthy trotz laufendem Service

Wiki.js zeigt manchmal "unhealthy" im Docker-Status, obwohl der Dienst antwortet 
(HTTP 200). Die Ursache ist ein bekannter Express.js-Fehler in älteren Wiki.js-Versionen 
(Cannot read properties of undefined: sendError), der das Healthcheck-Script beeinträchtigt, 
aber den Dienst nicht stoppt.

## Passwörter und Secrets

Alle Passwörter werden über `.env`-Files und Umgebungsvariablen verwaltet:

| Dienst | Umgebungsvariable | Datei |
|--------|-------------------|-------|
| Nextcloud | NC_ADMIN_PASSWORD, NC_DB_PASSWORD, NEXTCLOUD_MASTERCONTAINER_SECRET | `.env` (docker root) |
| Authentik | AUTHENTIK_SECRET_KEY, AUTHENTIK_ENCRYPTION_KEY, PG_PASS | `.env` (docker root) |
| Wiki.js | WIKIJS_DB_PASS, WIKIJS_ADMIN_PASS | `.env` (docker root) |
| Grafana | GRAFANA_ADMIN_PASSWORD | `.env` (docker root) |
| Passbolt | PASSPBOT_ROOT_PASSWORD, PASSPBOT_DB_PASSWORD, EMAIL_PASSWORD | `.env` (docker root) |
| NetBird | NB_MGT_SECRET, NB_SETUP_KEY | `.env` (docker root) |
| Beszel Agent | BEZEL_AGENT_KEY | `.env` (docker root) |

**WICHTIG:** Die `.env`-File liegt nicht im Git-Repository. Sie muss separat angelegt werden.

## E-Mail Konfiguration

| Zweck | Wert |
|-------|------|
| E-Mail-Adresse | info@sasa-it.de |
| SMTP-Server | smtp.1blu.de:465 (SSL/TLS) |
| IMAP-Server | imap.1blu.de:993 (SSL/TLS) |
| POP3-Server | pop3.1blu.de:995 (SSL/TLS) |
| Postfach-Name | g376231_0-sasa-it |
| Benutzername (SMTP/IMAP) | g376231_0-sasa-it (NICHT info@sasa-it.de) |
| Verschlüsselung | Erforderlich (SSL/TLS) |

**ACHTUNG:** Das Passwort für info@sasa-it.de (`!iiB9EzO1C9lijT`) wurde in einer 
früheren Session.

**SOFORTMASSNAHME:** Bitte das Passwort sofort im 1blu.de Kundencenter ändern!

## Backup-Strategie

### Nextcloud AIO Backup
- Built-in Backup-Lösung (über Nextcloud AIO Mastercontainer Volume)
- Volume: `nextcloud_aio_mastercontainer` (extern, exakt benannt)
- Manuelle Backups: über Nextcloud AIO UI oder `docker exec` Kommandos

### Wiki.js Backup
- Datenbank-Backup: `wikijs-db` Volume (PostgreSQL)
- Config-Backup: `wikijs_data` Volume
- Dump-Beispiel:
  ```bash
  sudo docker exec wikijs-db pg_dump -U wikijs wikijs > /home/sasa/backups/wiki/wikijs-db_$(date +%Y%m%d_%H%M%S).sql
  ```

### Authentik Backup
- PostgreSQL Volume: `authentik_postgres`
- Media: `authentik_media`
- Zertifikate: `authentik_certs`

### Beszel Backup
- Daten: `beszel_data` Volume
- Socket: `beszel_socket` Volume

## Netzwerk-Konfiguration

Docker Compose definiert ein Bridge-Netzwerk `sasa-it-net`. Container kommunizieren 
über dieses Netzwerk mit Docker-internen Hostnamen (wenn im Caddyfile als Docker-Host 
 Referenziert). Für Zugriffe von außen (Tailscale-Gasts) werden die externen IP-Adressen 
 verwendet (Tailscale-IPs).

### Port-Mapping (localhost only)

| Port | Dienst |
|------|--------|
| 127.0.0.1:8080 | Nextcloud AIO (Apache HTTP) |
| 127.0.0.1:9000 | Authentik Server |
| 127.0.0.1:3001 | Wiki.js |
| 127.0.0.1:3000 | Grafana |
| 127.0.0.1:3002 | NetBird Management |
| 127.0.0.1:9001 | Passbolt |
| 127.0.0.1:18090 | Beszel Dashboard |

## Wartung & Updates

### Caddy Zertifikate
Caddy verwaltet Let's Encrypt Zertifikate automatisch. Ablauf wird durch den 
Hintergrundprozess geprüft. Ablaufdaten sind ca. 90 Tage.

### Docker Compose Updates
```bash
cd /home/sasa/sasa-it-service/docker
sudo docker compose -f master-compose.yml pull
sudo docker compose -f master-compose.yml up -d
```

## Kontakt & Support

- **Verantwortlich:** Sascha "Sasa" (SASA-IT, sasas-cloud)
- **E-Mail:** info@sasa-it.de
- **GitHub:** https://github.com/sasas-cloud/sasa-it-service
- **KI-Assistent:** Nova (deployt, wartet und demonstriert die Plattform)
- **Server:** 1blu.de, v76432.1blu.de, Ubuntu Linux

---

*Dokument erstellt: 2026-08-30*  
*Version: 1.0 — nach vollständiger Reparatur und Neu-Deploy*
