# SASA-IT — Gesamtplan & Roadmap

**Stand:** August 2026  
**Ziel:** Professionelle IT-Dienstleistungsplattform — von der Landing Page bis zur vollständigen Infrastruktur.

---

## ✅ Bereits erledigt

| Aufgabe | Status | Details |
|---------|--------|---------|
| **DESIGN.md** erstellt | ✅ Fertig | Design-System: Inter, JetBrains Mono, Schwarz/Weiß, Blau-Akzent |
| **README.md** erstellt | ✅ Fertig | Projektübersicht, Stack, Struktur |
| **Landing Page** `sasa-it.de` | ✅ Fertig | Vollständiges HTML mit Navigation, Hero, Services, Features, Wiki-Link, KI-Bereich, Footer |
| **Jupyter-Umgebung** | ✅ Fertig | Micromamba env `sasa-jupyter` mit jupyterlab, ipykernel, openai, pandas, numpy, matplotlib, requests, httpx, pydantic, dotenv |
| **Jupyter Kernel** | ✅ Registriert | `sasa-jupyter` — in JupyterLab auswählbar |
| **`.env`** erstellt | ✅ Fertig | NIM-API-Key, NIM-Base-URL (.gitignore! |
| **Multi-Model Notebook** | ✅ Fertig | `notebooks/01_nim_multi_model.ipynb` — NIM, Ollama, GPT, Claude, Qwen, Router |
| **Wiki-Struktur** | ✅ Fertig | `wiki/README.md` mit Kategorien, KI-Generierungs-Prozess, Stil-Richtlinien |
| **Architektur-Doku** | ✅ Fertig | `docs/architecture.md` — Subdomains, Flows, Sicherheit, Host-Empfehlungen |
| **Skills geladen** | ✅ Fertig | `popular-web-designs`, `design-md`, `sketch`, `github-auth`, `huggingface-hub`, `notebook` |
| **`gh` CLI** | ✅ Installiert | Ubuntu-Repository, authentifiziert mit PAT |

---

## 📋 Nächste Schritte

### Phase 1: Wiki-Inhalte (Priorität: hoch)

| Artikel | Beschreibung | KI-Unterstützung |
|---------|-------------|------------------|
| `wiki/haustechnik.md` | Smart Home, Gebäudeautomation | Claude / NIM-StarCoder2 |
| `wiki/facility-management.md` | Gebäudemanagement, Wartung, Energie | Claude |
| `wiki/it-infrastruktur.md` | Netzwerke, Server, Cloud, Backup | Claude |
| `wiki/sicherheit.md` | SSL, Firewalls, VPN, Zugangsschutz | Claude |
| `wiki/cloud-ai.md` | KI-Dienste, Cloud, NVIDIA NIM | Claude |
| `wiki/unternehmen.md` | Über SASA-IT, Team, Mission | Claude |
| `wiki/authentik.md` | SSO, OIDC, MFA (aus Wiki-Referenz) | Manuelle Zusammenfassung |
| `wiki/netbird.md` | VPN, DNS, SSO-Brücke (aus Wiki-Referenz) | Manuelle Zusammenfassung |
| `wiki/nextcloud-aio.md` | Files, Wiki, Docs, Talk | Manuelle Zusammenfassung |
| `wiki/caddy-ssl.md` | Reverse Proxy, HTTPS, Zertifikate | Manuelle Zusammenfassung |
| `wiki/firewall.md` | Regeln, Ports, Schutz | Manuelle Zusammenfassung |
| `wiki/nvidia-nim.md` | KI-Modelle, Integration | Aus Jupyter Notebook |
| `wiki/multi-model-router.md` | Router für verschiedene Modelle | Aus Jupyter Notebook |
| `wiki/hermes-agent.md` | Cloud AI Assistant | Beschreibung |
| `wiki/jupyter-notebooks.md` | Datenanalyse, KI-Experimente | Beschreibung |

**Prozess:**
1. KI generiert Entwurf (Prompt im Notebook)
2. Admin prüft und korrigiert
3. Speichern als `.md` im `wiki/`
4. Git commit + push

---

### Phase 2: Infrastruktur-Setup (Priorität: hoch)

**Authentik** (`auth.sasa-it.de`):
- Docker Compose Konfiguration (aus Wiki-Referenz)
- PostgreSQL, Redis, Server, Worker
- Authentik Initial-Setup: Admin User, Provider, OIDC Applications
- Reverse Proxy Caddy Konfiguration

**NetBird** (`sso.sasa-it.de`):
- Docker Compose Konfiguration (aus Wiki-Referenz)
- Management, Signal, Coturn, Dashboard
- Authentik als IdP konfigurieren (OIDC Provider + Application)
- VPN-Zugang einrichten

**Nextcloud AIO** (`office.sasa-it.de`):
- Nextcloud AIO Docker Compose oder AIO-Installer
- Reverse Proxy Caddy Konfiguration
- Multi-Domain Setup vorbereiten (später)
- Talk Server einrichten (zentrale Instanz)

**Caddy Reverse Proxy**:
- `Caddyfile` mit allen Subdomains
- SSL: LetsEncrypt oder Nextcloud-Zertifikat (noch zu klären)
- Routing zu Authentik, Nextcloud, NetBird, Landing Page

---

### Phase 3: Security & Netzwerk (Priorität: hoch)

**Firewall**:
- Nur notwendige Ports offen: 22 (SSH), 80 (HTTP), 443 (HTTPS), Nextcloud Talk Ports
- UFW oder iptables Regeln
- Skript `firewall/rules.sh`

**SSL/TLS**:
- Caddy verwaltet Zertifikate (LetsEncrypt)
- ODER: Nextcloud AIO stellt Zertifikat, Caddy nutzt es (noch zu klären)
- HTTP→HTTPS Redirect für alle Domains

**VPN / Zugang**:
- NetBird VPN für sicheren Fernzugang
- Kunden-Domains werden via VPN/DNS-Tunnel angebunden
- Heim-PC / Heimnetz → VPN → Kundendomäne

---

### Phase 4: KI-Integration & Plattform (Priorität: mittel)

**NIM-API-Integration**:
- Notebook zeigt die Nutzung (fertig)
- Wiki-Dokumentation `wiki/nvidia-nim.md`
- Sicherheitsaspekte: Keys nicht im Code, `.env`-Datei

**Multi-Model Router**:
- Notebook zeigt den Router (fertig)
- Wiki `wiki/multi-model-router.md`
- Integration in Web-App (später)

**Hermes Agent**:
- Cloud AI Assistant in die Plattform
- Wiki `wiki/hermes-agent.md`
- Nutzung aus Nextcloud oder Web-App (später)

---

### Phase 5: Web-App & Weiterentwicklung (Priorität: mittel)

**Web-App-Features** (optional, später):
- Kunden-Portal mit Service-Anfragen
- Support-Ticket-System
- KI-gestützte FAQ
- Dashboard für Kunden (positiv)

**Verbesserungen Landing Page**:
- SEO-Meta-Tags
- Open Graph Tags
- Favicon / Logo
- Performance-Optimierung (CSS-only, kein JS nötig)
- Analyse-Integration (matomio / privacy-friendly)

**Verbesserungen Wiki**:
- Interaktive Navigation (Suchleiste)
- Verlinkung zwischen Artikeln
- Versionierung von Artikeln
- Kommentare / Feedback

---

## 🔧 Verbesserungen (aus Administrations-Perspektive)

| Bereich | Verbesserung vorgeschlagen |
|---------|---------------------------|
| **Landing Page** | Mehr Service-Details, CTA's, SEO, Open Graph, Performance-Optik |
| **Wiki** | Strukturierte Navigation, Suchfunktion, verknüpfte Artikel, historische Versionen, Kommentare |
| **Notebook** | Mehr Beispiele, KI-Modell-Vergleiche, Fehler-Handhabung, Logging |
| **Docker** | Compose-Dateien für alle Dienste, vollständige Konfiguration, env-Dateien |
| **Caddy** | Vollständige Caddyfile, SSL-Konfiguration, Reverse Proxy Routing |
| **Firewall** | UFW/iptables Skripte, nur notwendige Ports, Logging |
| **Authentik** | Vollständige Initial-Konfiguration, Provider, Applications, OIDC Setup |
| **NetBird** | Vollständige Konfiguration, Authentik als IdP, VPN-Zugang |
| **Nextcloud** | Multi-Domain Setup, Talk Server, Admin-Konfiguration |
| **Sicherheit** | HTTPS erzwingen, HSTS, Zertifikats-Management, Key-Hoheits-Kontrolle |
| **Dokumentation** | Wartung, Versionierung, Links auf aktuelle API-Docs, Styling |

---

## 📁 Repository-Struktur (final)

```
sasa-it-service/
├── DESIGN.md                 # Design-System
├── README.md                 # Projektübersicht
├── .env                      # Umgebungsvariablen (NICHT im Git!)
├── .gitignore                # Git Ignore (inkl. .env)
├── landing-page/
│   └── index.html            # Hauptwebsite
├── notebooks/
│   └── 01_nim_multi_model.ipynb  # KI-API Notebook
├── wiki/
│   ├── README.md             # Wiki-Übersicht, Prozess
│   ├── haustechnik.md        # Smart Home, Gebäudeautomation
│   ├── facility-management.md
│   ├── it-infrastruktur.md
│   ├── sicherheit.md
│   ├── cloud-ai.md
│   ├── unternehmen.md
│   ├── authentik.md
│   ├── netbird.md
│   ├── nextcloud-aio.md
│   ├── caddy-ssl.md
│   ├── firewall.md
│   ├── nvidia-nim.md
│   ├── multi-model-router.md
│   ├── hermes-agent.md
│   └── jupyter-notebooks.md
├── docs/
│   ├── architecture.md       # Architektur-Doku
│   └── security-ssl.md       # SSL / Caddy / Firewall (in Arbeit)
├── caddy/
│   └── Caddyfile             # Reverse Proxy Config (in Arbeit)
├── docker/
│   ├── authentik/            # Authentik Docker Compose
│   ├── netbird/              # NetBird Docker Compose
│   └── nextcloud/            # Nextcloud AIO Docker Compose
├── firewall/
│   └── rules.sh              # Firewall-Skript
└── scripts/
    ├── setup-authentik.sh    # Setup-Skript Authentik
    ├── setup-netbird.sh      # Setup-Skript NetBird
    ├── setup-nextcloud-aio.sh
    └── jupyter-start.sh      # JupyterLab Start
```

---

## 🚀 So startest du jetzt

### JupyterLab öffnen
```bash
source ~/.bashrc  # oder neue Shell
micromamba activate sasa-jupyter
jupyter lab
# → öffnet im Browser
```

### Landing Page ansehen
```bash
xdg-open /home/sasa/sasa-it-service/landing-page/index.html
# oder
open /home/sasa/sasa-it-service/landing-page/index.html
```

### Wiki lesen
```bash
cat /home/sasa/sasa-it-service/wiki/README.md
```

### Notebook ausführen
1. JupyterLab öffnen
2. `notebooks/01_nim_multi_model.ipynb` wählen
3. Zellen ausführen (Shift+Enter)
4. KI-Modelle testen

---

## 📝 Git & GitHub

**Nächster Commit:**
```bash
cd /home/sasa/sasa-it-service
git add DESIGN.md README.md landing-page/index.html notebooks/01_nim_multi_model.ipynb wiki/README.md docs/architecture.md .env .gitignore
git commit -m "Initial commit: Landing Page, Jupyter Notebook, Wiki-Struktur, Design-System"
git push origin master
```

**`.gitignore`** erstellen — `.env` und Jupyter-Konfigurationen ausschließen.

---

## 🎯 Langfristige Vision

1. **Professionelle IT-Dienstleistungs-Website** — komplett, modern, vertrauensbildend
2. **Wiki-Wissensbasis** — umfassend, KI-gestützt, gepflegt
3. **Plattform** — Authentik (SSO), Nextcloud (Office/Files/Wiki), NetBird (VPN), Caddy (SSL), Hermes (AI)
4. **Multi-Modell KI** — verschiedene Modelle für verschiedene Aufgaben (Code, Text, Analyse, Wiki)

---

**Stand:** August 2026  
**Status:** Fundament gelegt. Phase 1 (Wiki-Inhalte) und Phase 2 (Infrastruktur) folgen.
