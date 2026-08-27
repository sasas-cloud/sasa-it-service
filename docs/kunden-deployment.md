# Kunden-Deployment — SASA-IT Plattform

> **Stand:** August 2026  
> **Zweck:** Wie Kunden eigene Nextcloud AIO-Instanzen mit SASA-IT-SSL, VPN, und optional zentralem Talk nutzen  
> **Modell:** Verteilte Instanzen auf eigenem Host, zentrale SSL/Proxy/Authentifizierung

---

## Übersicht

SASA-IT betreibt einen **zentralen Hub** (Caddy SSL-Proxy, Authentik SSO, NetBird VPN). Kundendaten laufen **nicht** auf dem SASA-IT-Server — jeder Kunde hat seine eigene AIO-Instanz auf eigenem Host (On-Premise beim Kunden, oder bei SASA-IT gestellter Server). SASA-IT stellt:

- **SSL-Zertifikat** (LetsEncrypt über Caddy, zentral verwaltet)
- **Reverse Proxy** (`proxy.sasa-it.de`) mit JWT-Auth
- **VPN-Verbindung** (NetBird) zwischen Hub und Kundenserver
- **Optional: Zentralen Talk-Server** für Kunden, die Chat/VoIP nutzen wollen

---

## Deployment-Modi

### Modus A: Kundenserver beim Kunden (On-Premise)

```
Kundengebäude / Home-Office
    │
    ├── Kundenserver (AIO, Apache, Daten, Files)
    │   └── NetBird VPN-Client → SASA-IT Hub
    │
    └── Endgeräte (PC, Laptop, Mobil) → VPN → Kundenserver
```

- Kunde stellt Hardware bereit (physisch oder VM)
- SASA-IT installiert/managed AIO + NetBird VPN
- SASA-IT stellt SSL-Zertifikat (via Caddy)
- SASA-IT reverse-proxies `kunde.sasa-it.de` → VPN → Kundenserver:8080

**Vorteile:**
- Kundendaten verbleiben beim Kunden
- Backup-Verantwortung beim Kunden
- Datenschutz, Compliance (DSGVO, Branchen)

**Nachteile:**
- Hardware-Kosten beim Kunden
- NetBird-VPN bei schwacher Internetverbindung limitiert

---

### Modus B: SASA-IT stellt Server bereit (Remote-Host)

```
SASA-IT Rechenzentrum / Cloud
    │
    ├── Kundenserver #1 (AIO, Daten) ← eigenständig
    ├── Kundenserver #2 (AIO, Daten) ← eigenständig
    │
    └── SASA-IT Hub
        ├── Caddy (SSL, Proxy)
        ├── Authentik (SSO, JWT)
        └── NetBird (VPN Management)
```

- SASA-IT stellt physischen Server oder Cloud-VM bereit
- Kundenserver verbindet sich per **NetBird VPN** zum Hub
- Caddy reverse-proxies via VPN zu Kundenserver

**Vorteile:**
- SASA-IT kümmert sich um Hardware, Netzwerk
- Einfachere Wartung
- Zentrale Monitoring

**Nachteile:**
- Daten liegen bei SASA-IT (nicht beim Kunden)
- Kosten je nach Hardware/Cloud

---

## Schritt-für-Schritt: Kunden-Instanz einrichten

### Voraussetzungen

- Kundenserver (physisch/VM/Cloud), Betriebssystem: Ubuntu 22.04/24.04 oder Debian 12
- NetBird VPN-Client (von SASA-IT verteilt)
- SSL-Zertifikat (von SASA-IT Hub)
- Domain: `kunde-meinername.sasa-it.de` (DNS bei SASA-IT konfiguriert)

### 1. AIO auf Kundenserver installieren

**Als root auf Kundenserver:**

```bash
apt update && apt install -y curl

curl -fsSL https://get.docker.com | sh

# AIO Mastercontainer starten
docker run \
  --init \
  --sig-proxy=false \
  --name nextcloud-aio-mastercontainer \
  --restart always \
  --publish 8080:8080 \
  --env APACHE_PORT=11000 \
  --env APACHE_IP_BINDING=0.0.0.0 \
  --env TALK_PORT=3478 \
  --volume nextcloud_aio_mastercontainer:/mnt/docker-aio-config \
  --volume /var/run/docker.sock:/var/run/docker.sock:ro \
  ghcr.io/nextcloud-releases/all-in-one:latest
```

> **Hinweis:** TALK_PORT=3478 ist der Standard. Wenn mehrere Kunden-Instanzen dieselbe SASA-IT-Umgebung nutzen, wird jeder eine eigene — aber Talk-Server ist separat (s. u.).

### 2. NetBird VPN einrichten (Kundenserver → Hub)

**Auf Kundenserver:**

```bash
# NetBird Agent installieren
curl -fsSL https://netbird.io/downloads/netbird-agent | bash
sudo netbird-service install \
  --management-url https://sso.sasa-it.de \
  --client-id <CLIENT_ID> \
  --client-secret <CLIENT_SECRET>
sudo systemctl enable --now netbird-service
```

**Auf SASA-IT Hub (NetBird Management):**
- Device für Kundenserver im NetBird Dashboard einrichten
- Route zur AIO-Instanz konfigurieren (z.B. `10.0.0.x/24` für Kundenserver-Netzwerk)
- Caddy weiß: `kunde.sasa-it.de` → VPN-IP `10.0.0.x:8080`

### 3. SSL-Zertifikat von SASA-IT

- SASA-IT Caddy verwaltet Zertifikat für `kunde.sasa-it.de`
- Kundenserver braucht **kein eigenes LetsEncrypt** — SASA-IT stellt das Zertifikat bereit
- Option: Kundenserver nutzt Self-Signed, Caddy terminate SSL, downstream per VPN HTTP

### 4. Reverse Proxy konfigurieren (Caddy auf Hub)

**`/etc/caddy/Caddyfile` auf Hub:**

```caddy
kunde-meinername.sasa-it.de {
    # JWT prüfen (via Authentik-Integration oder Custom Middleware)
    # Danach: VPN-Tunnel zu Kundenserver

    reverse_proxy https://10.0.0.50:8080 {
        header_up Host {host}
        header_up X-Real-IP {remote_host}
        transport http {
            tls_insecure_skip_verify  # VPN-intern, kein Public-CA nötig
        }
    }

    header {
        +Strict-Transport-Security "max-age=31536000; includeSubDomains"
        +X-Content-Type-Options "nosniff"
        +X-Frame-Options "DENY"
    }
}
```

### 5. JWT & Authentik SSO einrichten

- Kundenserver → Nextcloud → Admin → SSO & SAML
- OIDC Provider: `https://auth.sasa-it.de/application/o/kunde-meinername/`
- Client ID + Secret von Authentik (Hub) erhalten
- Redirect URI: `https://kunde-meinername.sasa-it.de/apps/openid_connect/login`

### 6. Nextcloud Setup durchlaufen

- `https://kunde-meinername.sasa-it.de` erreichen (via Caddy → VPN)
- Domain in Nextcloud konfigurieren (`NEXTCLOUD_TRUSTED_DOMAINS`)
- Admin-Account erstellen
- SSO + OIDC aktivieren

### 7. Firewall

**Kundenserver:**

```bash
ufw default deny incoming
ufw allow 22/tcp        # SSH (nur bestimmte IPs)
ufw allow 8080/tcp      # AIO intern
ufw allow 3478/tcp      # Talk (wenn genutzt)
ufw allow 3478/udp
ufw allow from 10.0.0.0/8 to any  # Nur VPN-Range
ufw enable
```

> **Wichtig:** Kein offener Port 80/443 auf Kundenserver — SSL wird am Hub beendet, Daten laufen per VPN intern.

---

## Zentraler Talk-Server (optional)

### Konzept

SASA-IT betreibt einen **zentralen Talk-Backend-Server** (in `office.sasa-it.de` integriert, oder dediziert). Kunden-Instanzen können diesen Talk-Server **einbinden** als externen XMPP-Server:

```
Kunden-Instanz Nextcloud
    │
    ├── Files, Wiki, Docs (lokal auf Kundenserver)
    │
    └── Talk → zentraler SASA-IT Talk-Server (VPN)
        ├── Chat
        ├── Video Calls
        └── Datei-Sharing in Chat
```

### Einbindung (in Nextcloud Admin, auf Kundenserver):

```
Settings → Talk → External XMPP Server
  Server: talk.sasa-it.de (oder internal DNS via VPN: 10.0.0.10)
  Port: 5222 (Client) + 5269 (Server-to-Server)
  Credentials: Von SASA-IT bereitgestellt
```

### Vorteile

- Kundenserver braucht **keine eigene Talk-Infrastruktur** (Coturn, STUN, TURN)
- Talk-Daten liegen zentral — aber Chat-Inhalte bleiben Sichtbarkeit für Kunden (nur Kunden-Gruppe)
- Wartung: SASA-IT hält Talk-Backend aktuell

### Firewall

- Kundenserver muss Talk-Verbindung zum zentralen Server ermöglichen (VPN)
- Port 5222, 5269 über VPN erreichbar
- Kein offener Port nach außen

---

## GPU-Host als Ressource

Wenn Kunde (oder SASA-IT) GPU-Leistung für AI benötigt:

```
Kundenserver → VPN → GPU-Host (NVIDIA Server)
                    │
                    ├── AI Inference (LLM, Bild, etc.)
                    └── Oder: direkt via proxy.sasa-it.de → GPU-Host
```

- GPU-Host läuft separat, ebenfalls per NetBird VPN erreichbar
- Zugriff über `gpu.sasa-it.de` (SSL vom Hub, Proxy via VPN)

---

## Zusammenfassung: Wie SASA-IT Kunden hostet

| Komponente | Wo | Wer verwaltet |
|------------|-----|---------------|
| SSL-Zertifikat | SASA-IT Hub (Caddy) | SASA-IT |
| Authentifizierung | SASA-IT Hub (Authentik) | SASA-IT |
| Reverse Proxy | SASA-IT Hub (Caddy) | SASA-IT |
| Kundenserver (AIO, Daten) | Kundenserver (On-Premise oder Remote) | SASA-IT + Kunde |
| VPN-Verbindung | NetBird (Hub + Kundenserver) | SASA-IT |
| Talk (optional) | Zentral beim SASA-IT Hub | SASA-IT |
| GPU-Host | Separat | SASA-IT / Kunde |

---

## Wartung

- **AIO Updates:** SASA-IT führt Updates auf Kundenservern durch (oder Kunde, je nach Vereinbarung)
- **Backups:** Kunde verantwortet eigene Backups (Nextcloud AIO Backup oder extern). SASA-IT kann Backup-Service anbieten (z.B. Backup auf SASA-IT-Speicher via VPN)
- **Zertifikate:** SASA-IT verlängert — Kundenserver muss nichts tun
- **Monitoring:** SASA-IT überwacht Caddy, Authentik, VPN-Verbindungen. Kundenserver-Status über NetBird Dashboard.
- **Talk:** Zentral — SASA-IT wartet Talk-Backend

---

**Verantwortlich:** SASA-IT Admin  
**Stand:** August 2026
