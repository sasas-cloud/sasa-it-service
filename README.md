# SASA-IT Service Plattform

**IT-Dienstleistungen | Haustechnik | Facility Management | Cloud & Sicherheit**

Dieses Repository enthält die Infrastructure-as-Code, Konfigurationen und die Webpräsenz für die SASA-IT Dienstleistungsplattform.

## Über das Projekt

SASA-IT bietet professionelle IT-Dienstleistungen mit Fokus auf:
- **Haustechnik** — Smart Home, Gebäudeautomation, VerNetzung.
- **Facility Management** — Überwachung, Wartung, Infrastruktur-Management.
- **IT-Infrastruktur** — Netzwerke, Server, Cloud, Sicherheit.
- **Support** — 24/7 überwacht, schnell, verlässlich.

Die Plattform ist modular aufgebaut und läuft auf Open-Source-Komponenten,union zu voller Kontrolle und Datenschutz.

## Tech-Stack

| Komponente | Technologie | Zweck |
|------------|-------------|-------|
| **Landing Page** | HTML / CSS (Custom, Inter, JetBrains Mono) | Hauptpräsenz, Portal-Entry |
| **Identity Provider** | Authentik | SSO, OIDC, SAML, MFA, LDAP |
| **Office & Files** | Nextcloud AIO | Files, Wiki, Docs, Talk, Admin, LLM Wiki |
| **VPN & SSO-Brücke** | NetBird + LDAP | VPN-Zugang, Device Management, SSO |
| **Reverse Proxy** | Caddy | HTTPS, SSL, Routing, Subdomains |
| **AI Assistant** | Hermes Agent + NVIDIA NIM (StarCoder2 & Co.) | Cloud AI, Code, Doku, Support |
| **Firewall** | UFW / iptables | SSH, HTTP, HTTPS, Nextcloud Talk, etc. |

## Architektur

```
www.sasa-it.de        → Landing Page (HTML/CSS)
auth.sasa-it.de       → Authentik (SSO / OIDC / MFA)
office.sasa-it.de     → Nextcloud AIO (Files, Wiki, Talk, Admin)
sso.sasa-it.de        → NetBird + LDAP + VPN (Zugang, Tunnel)
```

- **SSL:** Caddy verwaltet Zertifikate (LetsEncrypt oder Nextcloud-Zertifikat).
- **VPN:** Kunden-Domains werden über VPN/DNS-Tunnel von ihrer Heimpflege angebunden.
- **Talk:** Ein Nextcloud Talk Server dient allen Domains (Multi-Domain, 1 Talk Backend).
- **Firewall:** Nur notwendige Ports offen (SSH, 80, 443, Nextcloud Talk, etc.).

## Repository-Struktur

```
sasa-it-service/
├── DESIGN.md                 # Design-System (Fonts, Farben, Components)
├── README.md                 # Dieses File
├── landing-page/
│   └── index.html            # Hauptwebsite
├── docs/
│   ├── architecture.md       # Architektur-Doku
│   ├── security-ssl.md       # SSL / Caddy / Firewall
│   └── setup-guide.md        # Einrichtes-Anleitung
├── caddy/
│   └── Caddyfile             # Reverse Proxy Config
├── docker/
│   ├── authentik/
│   ├── netbird/
│   └── nextcloud/
├── firewall/
│   └── rules.sh              # Firewall-Skript
├── wiki/                     # Wiki-Referenzen (Authentik, NetBird, etc.)
└── scripts/                  # Setup- und Wartungsskripte
```

## Schnellstart (Entwicklung)

1. **Repo klonen** (nach Push):
   ```bash
   git clone https://github.com/sasas-cloud/sasa-it-service.git
   cd sasa-it-service
   ```

2. **Landing Page ansehen**:
   ```bash
   xdg-open landing-page/index.html
   # oder
   open landing-page/index.html
   ```

3. **Doku lesen**:
   ```bash
   cat docs/architecture.md
   cat docs/security-ssl.md
   ```

4. **Setup-Skripte** (coming soon):
   ```bash
   ./scripts/setup-authentik.sh
   ./scripts/setup-netbird.sh
   ./scripts/setup-nextcloud-aio.sh
   ```

## Entwicklung & Design

 Das Design-System ist in `DESIGN.md` definiert:
 - **Schrift:** Inter (UI), JetBrains Mono (Code)
 - **Farben:** Schwarz/Weiß, Blau-Akzent (#0066FF)
 - **Components:** Button-primary, Card, Nav-Link, etc.

 Änderungen an Design/Tokens in `DESIGN.md` — die Landing Page nutzt dieselben Tokens.

## Sicherheit

- **SSL:** Alle Subdomains HTTPS (Caddy / LetsEncrypt).
- **Auth:** Zentral über Authentik (MFA, LDAP, OIDC).
- **VPN:** NetBird für sicheren Zugang, Device Management.
- **Firewall:** Nur exposed Ports: SSH (22), HTTP (80), HTTPS (443), Nextcloud Talk, ggf. weitere für VPN.

## Kommunikation

- **Nextcloud Talk:** Interne Kommunikation, Support, Teams.
- **Email:** Über Authentik / SMTP konfigurierbar.
- **AI Assistant:** Hermes Agent mit NVIDIA NIM für Code, Doku, Support.

## Lizenz

Private / Eigentum von SASA-IT. Nicht öffentlich.

## Support

Für Fragen, Support oder Partnerschaft:
- **Web:** [www.sasa-it.de](https://www.sasa-it.de)
- **Auth / Portal:** [auth.sasa-it.de](https://auth.sasa-it.de)
- **Office:** [office.sasa-it.de](https://office.sasa-it.de)
- **SSO / VPN:** [sso.sasa-it.de](https://sso.sasa-it.de)
