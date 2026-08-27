# Architektur — SASA-IT Plattform (Korrigiertes Modell)

> **Stand:** August 2026  
> **Modell:** Hub-and-Spoke mit zentraler SSL/Proxy + VPN-Tunnel zu verteilten Kundenservern

---

## Übersicht

SASA-IT betreibt einen **zentralen Hub** (Caddy, Authentik SSO, NetBird VPN Management) und stellt **SSL-Zertifikate** sowie **Authentifizierung** für verteilte Kundenserver bereit. Kundendaten laufen **nicht** auf dem SASA-IT-Server — jede Kunden-Instanz läuft auf eigenem Host (bei Kunden oder bei SASA-IT bereitgestelltem Server).

---

## Subdomains & Dienste (Zentraler Hub)

| Subdomain | Dienst | Funktion |
|-----------|--------|----------|
| `sasa-it.de` / `www.sasa-it.de` | Landing Page | Portal-Entry, Marketing |
| `auth.sasa-it.de` | Authentik | Identity Provider — SSO, OIDC, MFA, JWT |
| `office.sasa-it.de` | Nextcloud AIO (SASA-IT intern) | Verwaltungsdaten, Wiki, Admin |
| `sso.sasa-it.de` | NetBird Management | VPN, Device Management, Tunnel |
| `proxy.sasa-it.de` | Caddy Reverse Proxy | SSL-Terminierung, JWT-Check, VPN-Routing zu Kunden |

---

## Modell: Zentraler Proxy + Verteilte Instanzen

```
User Browser
    │
    ▼
sasa-it.de (Landing Page)
    │
    ▼  "Zum Portal" klicken
    │
auth.sasa-it.de (Authentik SSO + MFA)
    │
    ▼  (JWT-Token erhalten)
    │
proxy.sasa-it.de (Caddy SSL-Terminal)
    │
    ├── JWT validieren
    ├── Nutzer → richtige Kunden-Instanz assignen
    │
    ▼  NetBird VPN Tunnel
    │
Kundenserver (eigenes AIO, eigener Apache)
    │
    ├── Dateien (Kundendaten — NICHT auf SASA-IT-Server!)
    ├── Wiki, Docs, Talk
    └── SSL kommt von SASA-IT (zentrales Zertifikat)
```

**Key Unterschied zu Multi-Instance-auf-einem-Host:**
- Jede Kunden-Instanz läuft auf **eigenem Host** (Kundenvideo, SASA-IT-stellvertreter-Server, Cloud-VM)
- SASA-IT stellt nur **SSL-Zertifikat**, **Proxy**, **Authentifizierung** (JWT via Authentik)
- Kundendaten verbleiben beim Kunden — Datenschutz, Backup-Verantwortung

---

## SSL-Strategie

### Zentrales Zertifikat (SASA-IT)

- Caddy auf dem Hub-Server verwaltet **ein LetsEncrypt-Zertifikat** für alle Subdomains
- Kundenserver erhalten **das gleiche Zertifikat** (oder eigenes, von SASA-IT ausgestellt)
- SSL-Terminierung **am Caddy** — Caddy entschlüsselt, prüft JWT, tunnelt via VPN

### Zertifikatsverteilung

```
SASA-IT Caddy (Hub)
    │
    ├── Zertifikat für auth.sasa-it.de (Authentik)
    ├── Zertifikat für proxy.sasa-it.de (Proxy)
    ├── Zertifikat für office.sasa-it.de (Intern)
    │
    └── Zertifikat für kundenX.sasa-it.de (Kunden-Instanz, via VPN)
        → Caddy prüft JWT, leitet weiter
```

**Vorteile:**
- Einheitliche Zertifikatsverwaltung
- Automatische Verlängerung (LetsEncrypt über Caddy)
- Kundenserver müssen sich nicht um SSL kümmern

---

## VPN-Tunnel: Kundenserver ↔ SASA-IT Proxy

### NetBird VPN als Tunnel

- Jeder Kundenserver verbindet sich per **NetBird VPN** zum SASA-IT-Hub
- Verbindung: **Nur VPN**, kein direktes Internet zu Kundenserver
- Authentifizierung: **JWT + Authentik-SSO** (über NetBird)

### Flow: Proxy → Kundenserver

```
User → proxy.sasa-it.de (HTTPS, Caddy)
      Caddy prüft:
        1. JWT-Token (von Authentik ausgestellt)
        2. Nutzer gehört zu Kunden-Gruppe X?
      ↓ gültig
      Caddy reverse-proxies über VPN-Tunnel zu kundenX-server:8080
      ↓
      Kundenserver (AIO Apache) antwortet
      ↓
      Caddy → User (HTTPS)
```

### Firewall

- **Kundenserver:** Nur VPN-Port (UDP 51820) offen — kein direktes Internet
- **Hub-Server:** 80, 443 (Caddy), 9000 (Authentik intern), 3000 (NetBird Dashboard)

---

## JWT & Authentifizierung

### Flow

1. User loggt sich an `auth.sasa-it.de` (Authentik SSO + MFA)
2. Authentik stellt **JWT-Token** aus
3. User kommt zu `proxy.sasa-it.de` mit JWT im Header
4. Caddy prüft JWT (via Authentik-Verifizierung oder eigenem Middleware)
5. Gültig? → Proxy weitertunneln zu Kundenserver (VPN)
6. Ungültig? → 401/403

### JWT-Claims

```json
{
  "sub": "user-id",
  "groups": ["kunde-123", "admin"],
  "customer": "kunde-123",
  "exp": 1760000000
}
```

- Caddy / JWT-Middleware checkt `customer`-Claim → routet zum richtigen Kundenserver

---

## Nextcloud AIO bei Kunden

### Einrichtung (bei Kunden, von SASA-IT verwaltet)

- Kunde (oder SASA-IT) stellt Server bereit (VM, physisch, Cloud)
- AIO installieren mit **eigener APACHE_PORT**, **eigenem TALK_PORT**
- SSL-Zertifikat von SASA-IT (via Caddy-Zentralverwaltung)
- NetBird VPN-Client auf Kundenserver → Verbindung zum Hub
- Caddy auf Hub: Reverse Proxy zu Kundenserver via VPN

### Konfiguration pro Kunde

| Parameter | Beispiel (Kunde A) | Beispiel (Kunde B) |
|-----------|---------------------|---------------------|
| AIO-Host | kunde-a.server.local | kunde-b.server.local |
| TALK_PORT | 3478 | 3479 |
| VPN-Endpoint | NetBird-Network | NetBird-Network |
| SSL-Zertifikat | Von SASA-IT | Von SASA-IT |
| Proxy-Route | proxy.sasa-it.de/kunde-a → VPN → kunde-a-server:8080 | proxy.sasa-it.de/kunde-b → VPN → kunde-b-server:8080 |

---

## GPU-Host als zusätzliche Ressource

### Verwendung

- GPU-Host (NVIDIA) für AI-Workloads (LLMs, Inference, Rendering)
- Läuft als **separate Ressource**, nicht als Nextcloud AIO-Instanz
- Erreichbar über VPN-Tunnel vom SASA-IT-Hub

### Verbindung

```
User / Admin → proxy.sasa-it.de (JWT)
              ↓
              GPU-Host via VPN-Tunnel
              ↓
              AI-Inference, LLM-Abfrage, Rendering
```

### Konfiguration

- GPU-Host: eigener Server/VM mit NVIDIA-GPU
- NetBird VPN-Client auf GPU-Host
- SASA-IT-Hub: routingt zu GPU-Host via VPN
- Zugriff über `gpu.sasa-it.de` (deren SSL kommt ebenfalls von SASA-IT)

---

## Kundenserver: Betriebsmodell

### Option A: Kunden-server bei SASA-IT

- SASA-IT stellt physischen Server oder Cloud-VM bereit
- Kundenserver im Rechenzentrum oder bei SASA-IT
- NetBird VPN zur SASA-IT-Instanz
- SASA-IT verwaltet SSL, Proxy, Updates

### Option B: Kunden-server beim Kunden (On-Premise)

- Kunde betreibt eigenen Server (Home/ Büro)
- NetBird VPN-Client → SASA-IT-VPN
- SASA-IT stellt SSL-Zertifikat, Proxy-Konfiguration
- Backup-Verantwortung beim Kunden

### Option C: Cloud-VM (AWS, Hetzner, etc.)

- Kundenserver in Cloud
- NetBird VPN oder Site-to-Site VPN
- SASA-IT stellt SSL, Proxy

---

## Zusammenfassung: Architektur-Prinzipien

| Prinzip | Bedeutung |
|---------|-----------|
| **Zentrale SSL** | Caddy verwaltet Zertifikate für alle Domains |
| **Zentrale Authentifizierung** | Authentik SSO + JWT für alle Zugänge |
| **Proxy vor Kundenservern** | Caddy reverse-proxies via VPN zu Kundenservern |
| **Verteilte Instanzen** | Jede Kunden-Instanz auf eigenem Host — nicht auf SASA-IT-Server |
| **VPN-Tunnel** | NetBird verbindet Hub ↔ Kundenserver |
| **GPU-Host separat** | AI-Ressource, ebenfalls über VPN/Proxy erreichbar |
| **Kundendaten beim Kunden** | Backup, Datenschutz — nicht auf SASA-IT-Server |

---

## Subdomains im Überblick

| Subdomain | Host | Funktion |
|-----------|------|----------|
| `sasa-it.de` | Hub | Landing Page |
| `auth.sasa-it.de` | Hub (Docker) | Authentik SSO |
| `office.sasa-it.de` | Hub (Docker) | SASA-IT interne AIO |
| `proxy.sasa-it.de` | Hub (Caddy) | Reverse Proxy + JWT |
| `sso.sasa-it.de` | Hub (Docker) | NetBird Dashboard |
| `kunde1.sasa-it.de` | Kundenserver (VPN) | Kunden-Instanz #1 |
| `kunde2.sasa-it.de` | Kundenserver (VPN) | Kunden-Instanz #2 |
| `gpu.sasa-it.de` | GPU-Host (VPN) | AI-Gateway |

---

**Verantwortlich:** SASA-IT Admin  
**Stand:** August 2026
