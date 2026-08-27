# Sicherheit & SSL — SASA-IT Plattform

**Stand:** August 2026  
**Zweck:** Firewall-Regeln, SSL-Strategie, Ports, Sicherheits-Flows

---

## 1. Firewall-Regeln

### Offene Ports (extern)

| Port | Protokoll | Richtung | Dienst | Beschreibung |
|------|-----------|----------|--------|--------------|
| **22** | TCP | Inbound | SSH | SSH-Zugang für Admins (beschränkt auf bestimmte IPs) |
| **80** | TCP | Inbound | HTTP | HTTP->HTTPS Redirect für alle Domains |
| **443** | TCP | Inbound | HTTPS | Alle Subdomains (Caddy Reverse Proxy) |
| **2053** | TCP | Inbound | Nextcloud Talk | Alternative Talk-Ports (optional) |
| **2054** | TCP | Inbound | Nextcloud Talk | Alternative Talk-Ports (optional) |
| **2055** | TCP | Inbound | Nextcloud Talk | Alternative Talk-Ports (optional) |
| **2056** | TCP | Inbound | Nextcloud Talk | Alternative Talk-Ports (optional) |

### Geschlossene Ports (Standard)

| Port | Status | Grund |
|------|--------|-------|
| 8080, 8443, 9000, 9443 | **Geschlossen** | Nur interne Dienste (Authentik, Nextcloud intern) |
| Alle anderen Ports | **Geschlossen** | Keine offenen Dienste ohne Begründung |

### Firewall-Skript (UFW)

```bash
#!/bin/bash
# firewall/rules.sh — UFW Regeln für SASA-IT

# Standard: Alles blockieren
ufw default deny incoming
ufw default allow outgoing

# SSH (22) — nur von vertrauenswürdigen IPs
ufw allow from 192.168.1.0/24 to any port 22 proto tcp
ufw allow from <DEIN_HOME_IP> to any port 22 proto tcp

# HTTP (80) — für alle (Redirect zu HTTPS)
ufw allow 80/tcp

# HTTPS (443) — für alle Subdomains
ufw allow 443/tcp

# Nextcloud Talk Ports (optional, wenn nicht über WebSocket)
ufw allow 2053/tcp
ufw allow 2054/tcp
ufw allow 2055/tcp
ufw allow 2056/tcp

# Status anzeigen
ufw status verbose
```

### Firewall-Regeln Detail

**SSH-Beschränkung:**
- Nur bestimmte IPs erlaubt (Home-IP, Admin-IPs)
- Keine allgemeine 22-Öffnung
- Key-basierte Auth nur (kein Password)

**HTTP/HTTPS:**
- 80 wird auf 443 weitergeleitet (Caddy)
- 443 für alle Subdomains offen
- Caddy verwaltet Zertifikate

**Nextcloud Talk:**
- Für Echtzeit-Kommunikation nötig
- Über Caddy als WebSocket weitergeleitet
- Alternative Ports (2053-2056) für Fallback

---

## 2. SSL/TLS Strategie

### Option A: Caddy mit LetsEncrypt (Standard)

```
┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│   User      │ HTTP │    Caddy    │ HTTPS│  Nextcloud  │
│  Browser    │ ────▶│  Reverse    │──────│  AIO + andere│
│             │ 80   │  Proxy      │ 443  │  Dienste    │
└─────────────┘      └─────────────┘      └─────────────┘
                          │
                    LetsEncrypt
                    Zertifikat
```

**Vorteile:**
- Automatische Zertifikatsverlängerung
- Einheitliche Zertifikatsverwaltung
- HTTP/2, HTTP/3 unterstützt
- HSTS erzwingen

**Caddyfile Beispiel:**
```caddy
{
    email admin@sasa-it.de
    http_redirect https
}

# Landing Page
sasa-it.de, www.sasa-it.de {
    reverse_proxy localhost:8080
}

# Authentik
auth.sasa-it.de {
    reverse_proxy localhost:9000
}

# Nextcloud AIO
office.sasa-it.de {
    reverse_proxy localhost:8080
    header {
        +Strict-Transport-Security "max-age=31536000; includeSubDomains"
        +X-Content-Type-Options "nosniff"
    }
}

# NetBird Dashboard
sso.sasa-it.de {
    reverse_proxy localhost:3000
}
```

### Option B: Nextcloud AIO stellt Zertifikat (Alternative)

Nextcloud AIO kann Zertifikate verwalten. Caddy nutzt dann das gleiche Zertifikat für alle Subdomains.

**Vorteile:**
- Ein zentrales Zertifikat
- Nextcloud verwaltet Verlängerung

**Nachteile:**
- Komplexer Setup
- Nicht alle Dienste profitieren automatisch

**Empfehlung:** Option A (Caddy + LetsEncrypt) — einfacher, einheitlicher.

---

## 3. HSTS & Security Headers

Caddy setzt für alle Domains:

```
Strict-Transport-Security: max-age=31536000; includeSubDomains
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: geolocation=(), microphone=(), camera=()
```

---

## 4. Netzwerk-Flows

### Flow 1: User landet auf Landing Page

```
User Browser
    │
    ▼
sasa-it.de (HTTPS, Caddy)
    │
    ▼
Landing Page (statisch, HTML/CSS)
```

### Flow 2: User möchte Portal / Auth

```
User Browser
    │
    ▼
sasa-it.de → "Zum Portal" Klick
    │
    ▼
auth.sasa-it.de (HTTPS, Caddy → Authentik)
    │
    ▼
Login (MFA, LDAP falls aktiv)
    │
    ▼
Redirect zu office.sasa-it.de (Nextcloud)
    mit Authentik Session Cookie
```

### Flow 3: Interne Kommunikation (Nextcloud)

```
office.sasa-it.de (Nextcloud AIO)
    │
    ├── Files (SMB/WebDAV)
    ├── Wiki (Markdown, Files)
    ├── Docs (Collabora/OnlyOffice)
    ├── Talk (XMPP/WebSocket)
    └── Admin (Nextcloud Admin Panel)
```

### Flow 4: Kunden-VPN-Anbindung

```
Kunde (Heim-PC, Home Office)
    │
    ▼
NetBird VPN (via sso.sasa-it.de)
    │
    ├── DNS-Tunnel
    │
    ├── Zugriff auf Kundendomäne (z.B. kunde1.sasa-it.de)
    │
    ├── Nextcloud Talk Server (zentral)
    │
    └── Files, Wiki, Talk — über VPN
```

### Flow 5: AI Assistant / NIM

```
User / Admin
    │
    ▼
Hermes Agent (Cloud / Nextcloud AI?)
    │
    ▼
NVIDIA NIM API (Cloud)
    │
    ├── StarCoder2 (Code)
    ├── DeepSeek (Text, Reasoning)
    ├── Sonstige 84 Modelle
    │
    ▼
Antwort an User
```

---

## 5. Sicherheits-Maßnahmen

### Authentifizierung

- **Zentral:** Authentik als IdP
- **MFA:** Optional, aber empfohlen (TOTP, WebAuthn)
- **LDAP:** Optional für Benutzer-Sync
- **OIDC/SAML:** Für alle Dienste (Nextcloud, NetBird, etc.)

### Zugangskontrolle

- **NetBird VPN:** Geräte müssen autorisiert sein
- **LDAP:** Benutzer müssen existieren und aktiv sein
- **Firewall:** Nur bestimmte IPs für SSH

### Daten-Schutz

- **SSL/TLS:** Alle Verbindungen verschlüsselt
- **Zertifikate:** LetsEncrypt, automatisch verlängert
- **Backups:** Regelmäßige Backups (Nextcloud AIO, Docker Volumes)

### Monitoring

- **Uptime:** System-Status überwacht
- **Logs:** Zentrale Log-Erfassung (optional)
- **Alerts:** Bei Problemen benachrichtigen

---

## 6. VPN / DNS-Tunnel für Kunden

### Setup

```
Host (SASA-IT Server)
    │
    ├── NetBird Management (sso.sasa-it.de)
    │
    ├── NetBird Signal (VPN-Verbindung)
    │
    ├── NetBird Coturn (NAT Traversal)
    │
    └── DNS-Tunnel → Kunden-Domäne
```

### Kunden-Zugang

1. Kunde installiert NetBird Client
2. Meldet sich mit Authentik Credentials an
3. Ruft sich ein Gerät (Device) aus
4. Ist im VPN — kann Kunden-Domäne über DNS-Tunnel erreichen

### Vorteile

- Kein direkter Internet-Zugang zu Kundendomäne nötig
- Kontrolle über wer Zugriff hat
- DNS-Auflösung nur über VPN
- Talk Server ist für alle Domains gleich (1 Backend)

---

## 7. Firewall-Checkliste

### Bevor Sie live gehen

- [ ] SSH auf bestimmte IPs beschränkt
- [ ] Password-Auth für SSH deaktiviert (Key-only)
- [ ] HTTP→HTTPS Redirect aktiv
- [ ] HSTS für alle Domains
- [ ] Unnötige Ports geschlossen
- [ ] Zertifikate gültig (LetsEncrypt)
- [ ] Backups eingerichtet
- [ ] Monitoring aktiv

### Regelmäßige Checks

- [ ] Firewall-Status überprüfen (`ufw status`)
- [ ] Zertifikate gültig (`sslscan` oder `openssl s_client`)
- [ ] Logs auf verdächtige Aktivitäten prüfen
- [ ] Backups erfolgreich (Wiederherstellung testen)
- [ ] System-Updates eingespielt

---

## 8. IP-Strategie

### Einzelner Host (einfach)

Wenn alles auf einem Host läuft:
- **Eine öffentliche IP** für alle Subdomains
- Caddy bedient alle Subdomains auf einem Port (443)
- Kein Problem mit mehreren Domains auf einer IP (SNI)

### Mehrere Hosts (skalierbar)

Wenn Services auf verschiedenen Hosts laufen:
- **Caddy** auf dem Haupt-Host (Landing Page + Reverse Proxy)
- **Authentik** auf eigenem Host
- **Nextcloud AIO** auf eigenem Host
- **NetBird** auf eigenem Host

Jeder Host braucht seine eigene IP (oder NAT).

### DNS-Konfiguration

```
sasa-it.de          → A Record → Haupt-Hosts IP
www.sasa-it.de      → CNAME → sasa-it.de
auth.sasa-it.de     → A Record → Authentik-Hosts IP
office.sasa-it.de   → A Record → Nextcloud-Hosts IP
sso.sasa-it.de      → A Record → NetBird-Hosts IP
```

---

## 9. Zusammenfassung

| Aspekt | Empfehlung |
|--------|------------|
| **Reverse Proxy** | Caddy |
| **SSL** | LetsEncrypt über Caddy |
| **Firewall** | UFW, nur 22/80/443 offen |
| **SSH** | Key-only, IP-beschränkt |
| **Authentifizierung** | Authentik (OIDC, MFA) |
| **VPN** | NetBird (für Kunden) |
| **Talk** | 1 zentraler Server, alle Domains |
| **Monitoring** | Regelmäßige Checks, Alerts |
| **Backups** | Regelmäßig, Wiederherstellung testen |

---

**Stand:** August 2026  
**Verantwortlich:** SASA-IT Admin  
**Review:** Regelmäßig
