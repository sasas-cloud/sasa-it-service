# Wiki — SASA-IT Wiki auf sasa-it.de/wiki

Willkommen im **SASA-IT Wiki** — unserem Wissensbasis für IT-Dienstleistungen, Technologie und Lösungen.

Das Wiki wird mit KI-Unterstützung erstellt und gepflegt. Jeder Eintrag wird von einem KI-Modell (Claude, NIM-StarCoder2, GPT) entworfen und von unseren Experten geprüft.

---

## Start hier

### Service-Bereiche

| Bereich | Beschreibung |
|---------|-------------|
| [Haustechnik](wiki/haustechnik.md) | Smart Home, Gebäudeautomation, Überwachung |
| [Facility Management](wiki/facility-management.md) | Gebäudemanagement, Wartung, Energie |
| [IT-Infrastruktur](wiki/it-infrastruktur.md) | Netzwerke, Server, Cloud, Sicherheit |
| [Sicherheit](wiki/sicherheit.md) | SSL, Firewalls, VPN, Zugangsschutz |
| [Cloud & AI](wiki/cloud-ai.md) | KI-Dienste, Cloud-Architektur, NVIDIA NIM |
| [Unternehmen](wiki/unternehmen.md) | Über SASA-IT, Team, Mission |

### Technik

| Thema | Beschreibung |
|-------|-------------|
| [Authentik](wiki/authentik.md) | SSO, OIDC, MFA — unser Identity Provider |
| [NetBird](wiki/netbird.md) | VPN, DNS, SSO-Brücke — sicherer Zugang |
| [Nextcloud AIO](wiki/nextcloud-aio.md) | Files, Wiki, Docs, Talk — Office-Plattform |
| [Caddy SSL](wiki/caddy-ssl.md) | Reverse Proxy, HTTPS, Zertifikate |
| [Firewall](wiki/firewall.md) | Regeln, Ports, Schutz |

### KI & Tools

| Thema | Beschreibung |
|-------|-------------|
| [NVIDIA NIM](wiki/nvidia-nim.md) | KI-Modelle für Code, Text, Reasoning |
| [Multi-Model Router](wiki/multi-model-router.md) | Intelligente Modell-Auswahl |
| [Hermes Agent](wiki/hermes-agent.md) | Cloud AI Assistant |
| [Jupyter Notebooks](wiki/jupyter-notebooks.md) | Datenanalyse, KI-Experimente |
| [Design-Tokens](wiki/design-tokens.md) | Einheitliche Design-Tokens — Single Source of Truth |
| [HTML/CSS Best Practices](wiki/html-css-best-practices.md) | Regeln für HTML/CSS-Entwicklung |

---

## Wie das Wiki funktioniert

### KI-Generierung
Jeder Wiki-Artikel beginnt als Entwurf von einer KI. Die KI erhält:
- Das Thema
- Die Struktur (Überschriften, Inhalte, Format)
- Den Stil (professionell, klar, SASA-IT-Brand)

### Menschliche Prüfung
Unsere Experten prüfen jeden Artikel:
- Fakten korrekt? ✓
- Stil consistent? ✓
- Links funktionieren? ✓
- Sicherheitshinweise vollständig? ✓

### Versionierung
Alle Artikel sind im Git versioniert. Änderungen werden nachverfolgt.

---

## Schreiben im Wiki

### Format
Wir nutzen **Markdown** für alle Wiki-Artikel. Beispiel:

```markdown
# Titel des Artikels

Einleitender Absatz — was ist das Thema, warum wichtig?

## Unterabschnitt

Inhalt mit Listen, Tabellen, Code-Beispielen.

- Punkt 1
- Punkt 2
- Punkt 3
```

### Stil-Richtlinien
- **Klar** — kein unnötiges Fachjargon ohne Erklärung
- **Strukturiert** — Überschriften, Listen, Tabellen wo sinnvoll
- **Handlungsorientiert** — nicht nur "was", sondern "wie"
- **Marken-konsistent** — SASA-IT Sprachgebrauch, kein Marketing-Fluff

### KI-Hilfe
Für neue Artikel kannst du das Jupyter Notebook `notebooks/01_nim_multi_model.ipynb` nutzen:

1. Öffne das Notebook in JupyterLab
2. Nutze den "Wiki-Inhalt generieren"-Cell
3. Prüfe und bearbeite den Output
4. Speichere als `.md`-Datei im `wiki/`-Verzeichnis
5. Commit und push

---

## Beitrag leisten

Das Wiki ist gemeinschaftliche Arbeit. Wenn du einen Fehler findest, eine Ergänzung vorschlägst oder einen neuen Artikel wünschst:

1. Erstelle einen Issue im GitHub Repo
2. Oder schreibe direkt an wiki@sasa-it.de
3. Oder gib im Nextcloud Talk Kanal `#wiki` Bescheid

---

## Zitations-Quellen

Wir verwenden offene Quellen und Dokumentationen:
- [Authentik Dokumentation](https://docs.goauthentik.io/)
- [NetBird Dokumentation](https://docs.netbird.io/)
- [Nextcloud Dokumentation](https://docs.nextcloud.com/)
- [Caddy Dokumentation](https://caddyserver.com/docs/)
- [NVIDIA NIM Dokumentation](https://docs.nvidia.com/nim/)

---

**Zuletzt aktualisiert:** August 2026  
**Verantwortlich:** SASA-IT Admin Team  
**Kontakt:** wiki@sasa-it.de
