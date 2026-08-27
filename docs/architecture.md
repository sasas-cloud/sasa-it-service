# Architektur — SASA-IT Plattform

## Übersicht

SASA-IT ist eine modulare IT-Dienstleistungsplattform. Alle Dienste sind über Subdomains erreichbar, zentral authentifiziert (Authentik), und sicher anneinander gekoppelt (Nextcloud, NetBird, Caddy).

## Subdomains & Dienste

| Subdomain | Dienst | Funktion |
|-----------|--------|-----------|
| `sasa-it.de` / `www.sasa-it.de` | Landing Page | Hauptwebsite, Portal-Entry, Marketing |
| `auth.sasa-it.de` | Authentik | Identity Provider — SSO, OIDC, SAML, MFA, LDAP |
| `office.sasa-it.de` | Nextcloud AIO | Files, Wiki, Docs, Talk, Admin, LLM Wiki |
| `sso.sasa-it.de` | NetBird + LDAP + VPN | VPN-Zugang, SSO-Brücke, Device Management |

## Flüsse

### 1. User Landet auf Landing Page
```
User → www.sasa-it.de (Landing Page)
       ↓ klick "Zum Portal"
       → auth.sasa-it.de (Login via Authentik)
       → office.sasa-it.de (nach Auth, via Authentik Session)
```

### 2. Admin / Mitarbeiter
```
Admin → office.sasa-it.de (Nextcloud Admin)
        ↓
        → auth.sasa-it.de (MFA, LDAP Sync)
        → sso.sasa-it.de (NetBird Dashboard, VPN Devices)
```

### 3. Kunden-VPN-Anbindung
```
Kunde (Home / Office)
       ↓ VPN via NetBird
       → DNS-Tunnel → Kunden-Domain (z. B. kunde1.sasa-it.de)
       → Nextcloud Talk Server (gemeinsamer Backend)
       → Zugriff auf Files, Talk, Wiki
```

### 4. AI Assistant (Hermes + NIM)
```
User / Admin → Hermes Agent (Cloud)
                ↓
                → NVIDIA NIM (StarCoder2, andere Modelle)
                → Code-Generierung, Doku, Support
                → Rückgabe an User via Web / Chat
```

## Infrastruktur-Hosts

Empfohlen: 3-4 Hosts / VMs, je nach Last:

| Host | Dienste | Empfohlene Ressourcen |
|------|---------|-----------------------|
| **Landing / Caddy** | Web Server, Caddy Reverse Proxy, SSL | 1 vCPU, 1GB RAM |
| **Authentik** | Authentik (OIDC/SAML/MFA), LDAP (optional) | 1 vCPU, 2GB RAM |
| **Nextcloud AIO** | Nextcloud (Files, Wiki, Talk, Admin, LLM) | 2-4 vCPU, 4-8GB RAM |
| **NetBird** | NetBird Management, Signal, Coturn, Dashboard | 1-2 vCPU, 2GB RAM |

*Alternativ: Alles auf einem Host, wenn kleineres Scale — dann Docker Compose mit Caddy als Einzigen Reverse Proxy.*

## Sicherheit

- **SSL/TLS:** Zertifikate via Caddy (LetsEncrypt oder Nextcloud-Zertifikat).
- **Authentifizierung:** Zentral bei Authentik — MFA, LDAP, OIDC, SAML.
- **VPN:** NetBird für sicheren Tunnel, Device Management, DNS.
- **Firewall:** Nur notwendige Ports offen (22 SSH, 80 HTTP, 443 HTTPS, Nextcloud Talk, ggf. weitere).
- **Nextcloud Talk:** Gemeinsamer Server für alle Domains, über VPN erreichbar.

## Design-Prinzip

Alles sieht wie eine Plattform aus — Landing Page, Authentik UI, Nextcloud, Wiki — konsistentes Design, gleiche Typografie, gleiche Farben, keine Diskontinuitäten beim Navigation.

→ Siehe `DESIGN.md` für Design-Tokens.
