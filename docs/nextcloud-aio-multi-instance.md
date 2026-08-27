# Nextcloud AIO — Multi-Instance über mehrere Server

> **Stand:** August 2026  
> **Modell:** Mehrere AIO-Instanzen auf **verschiedenen Servern**, eine zentrale SASA-IT SSL/Proxy/Authentifizierung  
> **Zweck:** SASA-IT betreibt mehrere eigene Instanzen (maddin, sasa-privat) + Kundenserver — alle mit SSL von SASA-IT, alle über VPN mit dem Hub verbunden, Caddy als zentraler Proxy

---

## Übersicht

SASA-IT betreibt **mehrere Nextcloud AIO-Instanzen** auf **unterschiedlichen Servern**. Jede Instanz hat:

- **Eigenen Host** (Server/Virtualisierung/On-Premise)
- **Eigene AIO-Installation** (Docker, eigener Apache, eigene Daten)
- **Eigene Domain** (z.B. `maddin.sasa-it.de`, `sasa-privat.sasa-it.de`, `kunde1.sasa-it.de`)
- **SSL-Zertifikat von SASA-IT** (zentral via Caddy LetsEncrypt)
- **VPN-Verbindung zum SASA-IT Hub** (NetBird)
- **Access über Caddy Reverse Proxy** auf dem Hub (JWT geprüft)

**Nicht:** Mehrere Instanzen auf einem einzigen Host (Single-Host-Multi-Instance).  
**Stattdessen:** Jede Instanz auf eigenem Host — verteilte Architektur.

---

## Architektur-Übersicht

```
SASA-IT Hub (Caddy + Authentik + NetBird Management)
    │
    ├── auth.sasa-it.de       → Authentik (SSO, JWT)
    ├── proxy.sasa-it.de      → Caddy (Reverse Proxy, SSL-Terminal)
    ├── office.sasa-it.de     → SASA-IT interne AIO (Verwaltung)
    │
    └── je Instanz (per VPN):
        ├── maddin.sasa-it.de     → Maddin-Server (AIO, VPN)
        ├── sasa-privat.sasa-it.de → Sasa-Private-Server (AIO, VPN, 4TB Musik)
        ├── kunde1.sasa-it.de    → Kundenserver #1 (AIO, VPN)
        └── kunde2.sasa-it.de    → Kundenserver #2 (AIO, VPN)
```

**Zentrale Komponenten (Hub):**
- Caddy: SSL-Terminal, Reverse Proxy (alle Domains), JWT-Check
- Authentik: SSO, OIDC, MFA, JWT-Ausstellung
- NetBird: VPN Management, Devices, Tunnel zwischen Hub und allen Servern

---

## Beispiel: Zwei Instanzen (Maddin + Sasa Privat)

### Instanz 1: Maddin

| Parameter | Wert |
|-----------|------|
| Domain | `maddin.sasa-it.de` |
| Host | Maddin-Server (physisch/VM) |
| AIO-Publikations-Port | 8080 (intern) |
| Apache-IP-Binding | 0.0.0.0 |
| Apache-Port | 11001 (einzigartig) |
| TALK_PORT | 3478 (oder eigener, falls eigenständig) |
| VPN-IP (NetBird) | 10.0.0.51 |
| Daten | Maddin-Kundendaten |
| SSL | Zertifikat von SASA-IT Hub |

**Caddy-Konfiguration (Hub):**

```caddy
maddin.sasa-it.de {
    reverse_proxy https://10.0.0.51:8080 {
        header_up Host {host}
        transport http {
            tls_insecure_skip_verify  # VPN-intern
        }
    }
    header {
        +Strict-Transport-Security "max-age=31536000; includeSubDomains"
        +X-Content-Type-Options "nosniff"
    }
}
```

### Instanz 2: Sasa Privat (4TB Musik)

| Parameter | Wert |
|-----------|------|
| Domain | `sasa-privat.sasa-it.de` |
| Host | Sasa-Private-Server (4TB Storage, RAID/HDD) |
| AIO-Publikations-Port | 8080 (intern) |
| Apache-IP-Bindings | 0.0.0.0 |
| Apache-Port | 11002 (einzigartig) |
| TALK_PORT | 3479 (einzigartig, falls eigenständig) |
| VPN-IP (NetBird) | 10.0.0.52 |
| Daten | 4TB Musik (private Sammlung) |
| SSL | Zertifikat von SASA-IT Hub |

**Caddy-Konfiguration (Hub):**

```caddy
sasa-privat.sasa-it.de {
    reverse_proxy https://10.0.0.52:8080 {
        header_up Host {host}
        transport http {
            tls_insecure_skip_verify  # VPN-intern
        }
    }
    header {
        +Strict-Transport-Security "max-age=31536000; includeSubDomains"
        +X-Content-Type-Options "nosniff"
    }
}
```

---

## Deployment: SASA-IT eigene Instanzen

### Voraussetzungen (pro Instanz)

- **Server:** Physisch, VM, oder Cloud-VM (Ubuntu 22.04/24.04, Debian 12)
- **Ressourcen:** 2 vCPU, 4GB RAM (Minimum AIO), 32GB+ Storage (4TB bei Sasa Privat natürlich mehr)
- **NetBird VPN:** Agent auf Server, verbunden mit SASA-IT Hub
- **DNS:** Domain `xyz.sasa-it.de` → A Record → Hub-IP (Proxy), NICHT direkt zum Server

### Installation pro Server (SASA-IT führt durch)

```bash
# Als root auf dem Server:

# 1. Docker installieren
apt update && apt install -y curl
curl -fsSL https://get.docker.com | sh

# 2. AIO Mastercontainer starten (Einzigartige Ports pro Instanz!)
docker run \
  --init \
  --sig-proxy=false \
  --name nextcloud-aio-mastercontainer \
  --restart always \
  --publish 8080:8080 \
  --env APACHE_PORT=11001 \
  --env APACHE_IP_BINDING=0.0.0.0 \
  --env TALK_PORT=3478 \
  --volume nextcloud_aio_mastercontainer:/mnt/docker-aio-config \
  --volume /var/run/docker.sock:/var/run/docker.sock:ro \
  ghcr.io/nextcloud-releases/all-in-one:latest

# 3. NetBird VPN Agent installieren
curl -fsSL https://netbird.io/downloads/netbird-agent | bash
sudo netbird-service install \
  --management-url https://sso.sasa-it.de \
  --client-id <CLIENT_ID> \
  --client-secret <CLIENT_SECRET>
sudo systemctl enable --now netbird-service

# 4. VPN-IP erfahren (über NetBird Dashboard oder CLI)
# Server ist jetzt unter VPN-IP erreichbar, z.B. 10.0.0.51
```

### SSL von SASA-IT

- **Server selbst installiert KEIN LetsEncrypt**
- SASA-IT Hub (Caddy) verwaltet Zertifikat für `maddin.sasa-it.de`
- Caddy terminiert SSL, reverse-proxies via VPN zu Server:8080 (HTTP intern per VPN)
- Server sieht nur HTTP-Verbindung (von Caddy via VPN)

### Port-Eindeutigkeit (wichtig!)

Jede Instanz braucht **eindeutige Ports** im AIO-Context:

| Instanz | APACHE_PORT | TALK_PORT | VPN-IP |
|---------|-------------|-----------|--------|
| SASA-IT Office (intern) | 11000 | 3477 | 10.0.0.10 |
| Maddin | 11001 | 3478 | 10.0.0.51 |
| Sasa Privat | 11002 | 3479 | 10.0.0.52 |
| Kunde 1 | 11003 | 3480 | 10.0.0.60 |
| Kunde 2 | 11004 | 3481 | 10.0.0.61 |

---

## Reverse Proxy auf dem Hub (Caddy)

### Caddyfile (Hub)

```caddy
# SASA-IT interne AIO
office.sasa-it.de {
    reverse_proxy https://10.0.0.10:8080 {
        header_up Host {host}
        transport http { tls_insecure_skip_verify }
    }
    header {
        +Strict-Transport-Security "max-age=31536000; includeSubDomains"
        +X-Content-Type-Options "nosniff"
    }
}

# Maddin
maddin.sasa-it.de {
    reverse_proxy https://10.0.0.51:8080 {
        header_up Host {host}
        transport http { tls_insecure_skip_verify }
    }
    header {
        +Strict-Transport-Security "max-age=31536000; includeSubDomains"
        +X-Content-Type-Options "nosniff"
    }
}

# Sasa Privat (4TB Musik)
sasa-privat.sasa-it.de {
    reverse_proxy https://10.0.0.52:8080 {
        header_up Host {host}
        transport http { tls_insecure_skip_verify }
    }
    header {
        +Strict-Transport-Security "max-age=31536000; includeSubDomains"
        +X-Content-Type-Options "nosniff"
    }
}

# Kunden (Beispiel)
kunde1.sasa-it.de {
    reverse_proxy https://10.0.0.60:8080 {
        header_up Host {host}
        transport http { tls_insecure_skip_verify }
    }
    header {
        +Strict-Transport-Security "max-age=31536000; includeSubDomains"
        +X-Content-Type-Options "nosniff"
    }
}
```

### JWT + Authentifizierung

- Caddy prüft JWT (von Authentik ausgestellt) für jeden Request
- JWT enthält: `sub` (Nutzer-ID), `customer` (Kunden-Gruppe), `groups`
- Bei **eigenen SASA-IT-Instanzen** (Maddin, Sasa Privat): JWT optional oder spezifische Policy (z.B. nur für Admins sichtbar)
- Bei **Kundenservern**: JWT muss zur korrekten Kunden-Gruppe passen

**Caddy + JWT-Integration:**

Caddy hat kein native JWT-Middleware. Optionen:

1. **Authentik Reverse Proxy** vor Caddy (Authentik prüft JWT, leitet weiter an Caddy)
2. **Custom Caddy-Plugin** (JWT-Caddy oder ähnliche Middleware)
3. **External Auth** (Authentik als Auth-Provider, Caddy als Reverse Proxy dahinter)

**Empfehlung:** Authentik als SSO-Gateway vor Caddy — bei Login prüft Authentik OIDC, gibt JWT weiter, Caddy reverse-proxies danach.

---

## Talk-Server: Zentral vs. Per-Instanz

### Option A: Zentraler Talk-Server (bei SASA-IT)

- SASA-IT betreibt einen **zentralen Talk-Backend-Server** (in `office.sasa-it.de` integriert, oder dediziert)
- Alle Instanzen können diesen Talk-Server **einbinden** (externer XMPP-Server)
- Vorteile: Kein eigenständiger Talk-Backend pro Instanz, Wartung zentral, STUN/TURN zentral

**Einbindung in Nextcloud (pro Instanz):**

```
Settings → Talk → External XMPP Server
  Server: talk.sasa-it.de (oder interne VPN-IP)
  Port: 5222 (Client) + 5269 (Server-to-Server)
  Credentials: Von SASA-IT
```

### Option B: Eigene Talk-Instanz pro AIO

- Jede AIO-Instanz hat eigene Talk-Komponente (Standard bei AIO)
- Jede Instanz braucht eigenen STUN/TURN-Server oder öffentliche Infrastruktur
- Port (TALK_PORT) muss einzigartig sein

### Empfehlung für Maddin + Sasa Privat

- **Maddin:** Eigene Talk-Instanz (klein, ein Nutzer)
- **Sasa Privat (4TB Musik):** Zentralen Talk-Server nutzen (einfacher, kein eigenständiger Talk-Backend nötig)
- **Kunden:** Zentralen Talk-Server nutzen (SASA-IT kümmert sich um Wartung)

---

## Fazit: Multi-Instance über verschiedene Server

| Aspekt | Implementierung |
|--------|-----------------|
| **Anzahl Instanzen** | So viele wie Server verfügbar (SASA-IT intern, Kunden) |
| **Host** | Pro Instanz ein eigener Server (physisch/VM/Cloud) |
| **SSL** | Zentral von SASA-IT Hub (Caddy), nicht pro Server |
| **Proxy** | Caddy auf Hub → VPN → Server (JWT geprüft) |
| **Authentifizierung** | Authentik SSO + JWT, pro Instanz OIDC |
| **VPN** | NetBird, pro Server ein Agent, Hub-management |
| **Ports** | Eindeutige APACHE_PORT, TALK_PORT pro Instanz |
| **Daten** | Auf eigenem Server (nicht beim Hub) |
| **Talk** | Zentral (SASA-IT) oder eigenständig pro Instanz |

---

## GPS: Maddin + Sasa Privat — 2 Instanzen

| | Maddin | Sasa Privat |
|--|--------|-------------|
| Domain | `maddin.sasa-it.de` | `sasa-privat.sasa-it.de` |
| Server | Maddin-Server | Sasa-Private-Server |
| AIO APACHE_PORT | 11001 | 11002 |
| TALK_PORT | 3478 | 3479 (oder zentral) |
| VPN-IP | 10.0.0.51 | 10.0.0.52 |
| Daten | Maddin-Kunden | 4TB Musik (privat) |
| Talk | Eigenständig | Zentral (SASA-IT) |
| SSL | Von SASA-IT | Von SASA-IT |

---

**Verantwortlich:** SASA-IT Admin  
**Stand:** August 2026
