# Nextcloud AIO — SASA-IT Plattform

> **Stand:** August 2026  
> **Zweck:** Nextcloud AIO als Dienstleistung der SASA-IT Plattform — deployed bei Kunden, verwaltet von SASA-IT  
> **Modell:** Zentrale SSL/Proxy/Authentik + verteilter Kundenserver + VPN-Tunnel

---

## Übersicht

Nextcloud AIO (All-in-One) ist die Office-Plattform für SASA-IT und Kunden. Sie beinhaltet:

- **Files** — Dateispeicher, Sync, Sharing
- **Wiki** — Markdown-basiertes Wiki (integriert in Nextcloud Files)
- **Docs** — Collabora/OnlyOffice für Office-Dokumente
- **Talk** — Chat, Video, Audio (optional: zentraler SASA-IT Talk-Server)
- **Admin** — Verwaltung, Benutzer, Gruppen, Apps
- **LLM Wiki** — KI-erweiterte Wiki-Suche (optional, via NVIDIA NIM)

---

## Deployment-Modell

### SASA-IT Hostet den Hub (Zentral)

```
SASA-IT Hub (eigener Server)
    │
    ├── Caddy (SSL-Terminal, Reverse Proxy)
    │   ← Zertifikate für alle Domains (LetsEncrypt)
    │
    ├── Authentik (SSO + JWT)
    │   ← Single Sign-On für alle Dienste
    │
    ├── Nextcloud AIO (Office.sasa-it.de — SASA-IT intern)
    │   ← Verwaltungsdaten, Wiki, Admin
    │
    ├── NetBird VPN Management
    │   ← Tunnel zwischen Hub und Kundenservern
    │
    └── (Optional) Zentraler Talk-Server
        ← Chat, Video, Audio für alle Kunden
```

### Kundenserver (Verteilt)

```
Kundenserver (On-Premise oder SASA-IT Remote-Host)
    │
    ├── Nextcloud AIO (eigene Instanz)
    │   ← Kundendaten, Files, Wiki, Docs
    │
    ├── Apache (AIO-intern, Port 11000)
    │
    ├── NetBird VPN-Client → SASA-IT Hub
    │   ← VPN-Tunnel, kein offenes Internet
    │
    └── SSL-Zertifikat (von SASA-IT bereitgestellt)
        ← nicht selbst verwaltet!
```

---

## Services im Detail

### Files

- Dateiablage, WebDAV, Syncthing-ähnlicher Sync
- Sharing: intern (nextcloud-gebunden), extern (per Link)
- Verschlüsselung: serverseitig (LUKS/VeraCrypt optional)

### Wiki

- Markdown-Editor, integriert in Nextcloud Files
- Alternative: Wiki.js (separates Dienst, OIDC via Authentik)
- Bei SASA-IT: Nextcloud Wiki oder eigenes Wiki.js auf `wiki.sasa-it.de`

### Docs (Collabora/OnlyOffice)

- Online-Bearbeitung von Office-Dokumenten
- In AIO integriert (Collabora Online)
- Für Kunden verfügbar, wenn sie Nextcloud AIO nutzen

### Talk (Chat, Video, Audio)

**Option A: Kundenserver eigener Talk**

- Talk ist standardmäßig in Nextcloud AIO enthalten
- Kundenserver hat eigenen Talk-Backend (XMPP, STUN/TURN)
- Keine Abhängigkeit von SASA-IT

**Option B: Zentraler SASA-IT Talk-Server**

- SASA-IT betreibt einen Talks-Server (z.B. in `office.sasa-it.de`)
- Kunden-Instanzen binden diesen extern an (XMPP Server-to-Server)
- Wartung, STUN/TURN, Firewall: SASA-IT kümmert sich darum
- Chat-Inhalte: nur Kundengruppe sieht sie (Nextcloud ACL)

**Einbindung:**

```
Nextcloud Admin (Kundenserver)
    ├── Settings → Talk
    ├── External XMPP Server: talk.sasa-it.de
    ├── Credentials: Von SASA-IT
    └── Chat, Video: funktioniert über VPN
```

---

## Authentifizierung & SSO

### Flow

1. User besucht `kunde.sasa-it.de` (via Caddy Proxy)
2. Caddy leitet zu `auth.sasa-it.de` (Authentik)
3. User loggt sich ein (MFA, TOTP, WebAuthn)
4. Authentik stellt **JWT-Token** aus
5. Caddy prüft JWT, leitet zum Kundenserver (VPN-Tunnel)
6. Nextcloud authentifiziert via OIDC (Authentik als Provider)

### OIDC-Konfiguration (in Nextcloud)

```
Provider: OpenID Connect
Identifier: https://auth.sasa-it.de/application/o/kunde-name/
Client ID: (von Authentik)
Client Secret: (von Authentik)
Redirect URI: https://kunde.sasa-it.de/apps/openid_connect/login
```

---

## SSL-Strategie

### SASA-IT als Zertifikatsaussteller

- Caddy auf dem Hub verwaltet **LetsEncrypt-Zertifikate** für alle Domains
- Kundenserver **braucht kein eigenes LetsEncrypt**
- Caddy terminate SSL, downstream per VPN HTTP zu Kundenserver

### Vorteile

- Einheitliche Verwaltung
- Automatische Verlängerung (Caddy + LetsEncrypt)
- Kundenserver muss nichts tun
- Sicherheit: SSL nur an einem Punkt (Hub)

---

## VPN: NetBird

### Architektur

```
Hub (SASA-IT)
    │
    ├── NetBird Management (sso.sasa-it.de:3000)
    ├── NetBird Signal (VPN-Verbindung)
    ├── NetBird Coturn (NAT Traversal, für Talk)
    │
    └── Kundenserver
        ├── NetBird Agent
        └── VPN-Verbindung zum Hub (UDP 51820)
```

### Netzwerk

- Hub: `10.0.0.1/24` (SASA-IT intern)
- Kundenserver: `10.0.0.50/24` (VPN-IP)
- Caddy routet: `kunde.sasa-it.de` → `10.0.0.50:8080` (VPN)

### Firewall

**Kundenserver:**

```
- Nur VPN (UDP 51820) offen nach außen
- SSH: limitiert auf bestimmte IPs
- AIO intern: 8080 (nur VPN-range)
- Talk (wenn eigenständig): 3478 TCP/UDP
```

---

## GPU-Host (optional)

Für AI-Workloads (LLM-Inference, Bildgenerierung, etc.):

```
Kundenserver oder User
    │
    ├── über VPN / Proxy
    │
    ▼
GPU-Host (NVIDIA Server)
    ├── AI Inference
    ├── LLM-Abfrage
    └── Rendering
```

- Erreichbar über `gpu.sasa-it.de` oder direkt per VPN
- SSL vom Hub, Proxy via VPN
- JWT-Auth ähnlich wie andere Dienste

---

## Verwaltung & Wartung

### SASA-IT Verantwortung

- SSL-Zertifikate (Verlängerung, Zertifikatsmanagement)
- Authentik (SSO, Benutzer, MFA, Audit-Logs)
- NetBird VPN (Management, Devices, Routing)
- Reverse Proxy (Caddy Konfiguration)
- Zentraler Talk-Server (falls genutzt)
- Monitoring (Hub-Status, VPN-Verbindungen)

### Kundenserver Verantwortung

- Hardware (bei On-Premise)
- Backup (Kundendaten — Nextcloud AIO Backup oder externes)
- Updates (AIO, Docker, OS — SASA-IT kann helfen)
- NetBird-Agent (aktualisieren, aber SASA-IT kann deployen)

---

## Zusammenfassung: Komponenten

| Komponente | Position | Verantwortung |
|------------|----------|---------------|
| SSL-Zertifikat | SASA-IT Hub (Caddy) | SASA-IT |
| Authentifizierung (SSO, JWT) | SASA-IT Hub (Authentik) | SASA-IT |
| Reverse Proxy (SSL-Terminal) | SASA-IT Hub (Caddy) | SASA-IT |
| Kundenserver (AIO, Daten) | Kundenserver (eigenständig) | SASA-IT + Kunde |
| VPN-Verbindung | NetBird (Hub + Kundenserver) | SASA-IT |
| Talk (zentral, optional) | SASA-IT Hub (oder Talk-Server) | SASA-IT |
| GPU-Host (optional) | GPU-Server (VPN) | SASA-IT / Kunde |
| Kundendaten | Kundenserver (nicht bei SASA-IT) | Kunde (Backup) |

---

## Dokumentations-Pfade

- **Architektur:** `docs/architecture.md`
- **Kunden-Deployment:** `docs/kunden-deployment.md`
- **SSL & Sicherheit:** `docs/security-ssl.md`
- **Wiki-Design:** `wiki/DESIGN.md`
- **Authentik SSO:** `wiki/authentik-sso.md`
- **Design-Tokens:** `wiki/design-tokens.md`
- **HTML/CSS Best Practices:** `wiki/html-css-best-practices.md`

---

**Verantwortlich:** SASA-IT Admin  
**Stand:** August 2026
