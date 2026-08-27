# Wiki-Design — SASA-IT Wiki

**Stand:** August 2026  
**Zweck:** Visuelles und strukturelles Design für das SASA-IT Wiki

---

## 1. Übersicht

Das SASA-IT Wiki dient als Wissensbasis für alle IT-Dienstleistungen, Technologie und Projekte. Es soll:

- **Klar** und **strukturiert** sein
- **Suchbar** und **navigierbar**
- **Konsistent** mit dem restlichen SASA-IT Design
- **Dynamisch** — KI-Unterstützung bei Erstellung und Pflege

---

## 2. Design-Tokens (aus DESIGN.md)

Das Wiki verwendet die gleichen Design-Tokens wie die Landing Page:

| Token | Wert | Verwendung |
|-------|------|------------|
| **Primary** | `#0A0A0A` | Hintergrund, Footer |
| **Surface** | `#FAFAFA` | Haupt-Hintergrund |
| **Accent** | `#0066FF` | Links, Highlights, Aktionen |
| **Text** | `#111111` | Haupttext |
| **Text-muted** | `#666666` | Sekundärer Text |
| **Border** | `#E5E5E5` | Trennlinien |

**Typografie:**
- **Schrift:** Inter (UI), JetBrains Mono (Code)
- **Headings:** 800, 700, 600 (je nach Ebene)
- **Body:** 400, 16px oder 15px

---

## 3. Layout-Prinzipien

### Aufbau einer Wiki-Seite

```
┌─────────────────────────────────────────────────────┐
│  Wiki Header                                       │
│  Logo + Navigation + Suche                        │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Titel (H1, groß, Akzent wenn relevant)           │
│  ─────────────────────────────────────            │
│  Einleitung (1-2 Absätze, kontextuell)            │
│                                                     │
│  ──── Table of Contents ────                       │
│  1. Abschnitt                                      │
│  2. Abschnitt                                      │
│  3. Abschnitt                                      │
│  ...                                               │
│                                                     │
│  ──── Hauptinhalt ────                            │
│  Abschnitt 1 (H2)                                  │
│  - Unterabschnitt (H3)                            │
│  - Listen, Tabellen, Code-Beispiele               │
│                                                     │
│  Abschnitt 2 (H2)                                  │
│  ...                                               │
│                                                     │
│  ──── Tabellen / Diagramme ────                   │
│  (Wenn relevant — für Übersichtlichkeit)          │
│                                                     │
│  ──── Siehe auch ────                             │
│  Verknüpfungen zu verwandten Artikeln             │
│                                                     │
│  ──── Quellen / Letzte Änderung ────              │
│  Revision, Datum, Autor                           │
│                                                     │
├─────────────────────────────────────────────────────┤
│  Footer                                            │
│  Navigation, Links, Impressum                      │
└─────────────────────────────────────────────────────┘
```

### Navigation

- **Oben:** Wiki-Logo, Suchfeld, Amazon-Navigation (Home, Services, Technik, KI)
- **Seitenleiste (optional):** Verzeichnis der Wiki-Kategorien
- **Footer:** Links zu SASA-IT Hauptseite, Impressum, GitHub

### Suche

- Zentriertes Suchfeld im Header
- Volltextsuche über alle Wiki-Artikel
- Autocomplete / Vorschläge bei Eingabe
- Ergebnisse mit Relevanz-Ranking

---

## 4. Komponenten

### Wiki-Artikel-Typen

| Typ | Verwendung | Beispiel |
|-----|------------|----------|
| **Service-Artikel** | Beschreibung eines SASA-IT Services | `wiki/haustechnik.md` |
| **Technik-Artikel** | Technologie & Konfiguration | `wiki/authentik.md` |
| **Prozess-Artikel** | Workflows & Abläufe | `wiki/sicherheit.md` |
| **Referenz-Artikel** | API-Referenz, Konfigurationsoptionen | `wiki/nvidia-nim.md` |

### Inhalts-Elemente

| Element | Format | Beispiel |
|---------|--------|----------|
| **Überschriften** | H1 (Titel), H2 (Abschnitt), H3 (Unterabschnitt) | `# Titel`, `## Abschnitt`, `### Detail` |
| **Text** | Absätze, Aufzählungen, nummerierte Listen | normaler Markdown-Text |
| **Tabellen** | Übersichtliche Daten | `| Spalte 1 | Spalte 2 |` |
| **Code-Blöcke** | Mit Syntax-Highlighting (Sprache angeben) | ````python ... ```` |
| **Hinweise/Boxen** | Wichtige Informationen hervorgehoben | `> **Hinweis:** ...` |
| **Diagramme** | Excalidraw JSON (wenn komplexe Visualisierung nötig) | `.excalidraw` Dateien |
| **Bilder** | Screenshots, Diagramme, Icons | `![Alt-Text](img_url)` |

---

## 5. Wiki-Seite Vorlage

```markdown
# Titel des Artikels

kurze Einleitung — 1-2 Sätze, was dieses Thema ist und warum es relevant.

## Inhaltsverzeichnis

<!-- automatisch generiert oder manuell -->

## Abschnitt 1

Inhalt zu Abschnitt 1. Absätze, Listen, Tabellen.

### Unterabschnitt 1.1

Detailierter Inhalt zu Unterabschnitt 1.1.

```python
# Code-Beispiel mit Syntax-Highlighting
def beispiel():
    return "Hallo Welt"
```

> **Hinweis:** Wichtige Information oder Einschränkung.

## Abschnitt 2

Weiterer Inhalt, gerne mit Tabellen:

| Parameter | Beschreibung | Standardwert |
|-----------|-------------|--------------|
| `Parameter1` | Erklärung des Parameters | `Wert` |
| `Parameter2` | Erklärung | `Wert` |

## Siehe auch

- [Verwandter Artikel 1](link)
- [Verwandter Artikel 2](link)

## Quellen

- [Quellen-Link](url)
- [Weitere Dokumentation](url)

---

**Zuletzt aktualisiert:** Datum  
**Verantwortlich:** Autor/Team  
**Revision:** 1.0
```

---

## 6. Farbschema & Stile

Das Wiki hat das gleiche Farbschema wie die restliche SASA-IT Plattform. Besonders klinisch, klar, kaum unnötige Verzierungen.

### Hervorgehobene Boxen

| Typ | Stil | Verwendung |
|-----|------|------------|
| **Hinweis** | Hellblauer Hintergrund (`#E8F4FD`), blau Border | Wichtige Hinweise, Tipps |
| **Warnung** | Hellroter Hintergrund (`#FDE8E8`), roter Border | Warnungen, Sicherheitshinweise |
| **Info** | Hellgrüner Hintergrund (`#E6F7ED`), grüner Border | Positive Hinweise, Bestätigungen |
| **Code-Box** | Dunkler Hintergrund (`#1A1A1A`), monospace Schrift | Code-Beispiele, Konfiguration |

### Interaktive Elemente (optional, für Web-Version)

- **Suchfeld:** Größe änderbar, Autocomplete
- **ToC (Table of Contents):** Anklickbar, bleibt sichtbar beim Scrollen
- **Versions-Historie:** Zeigt letzte Änderungen, Unterschiede zwischen Versionen
- **Kommentare/Anmerkungen:** (optional) Diskussion zu jedem Artikel

---

## 7. Interaktive Funktionen (Web-Version)

### Suchfunktion

- Volltextsuche über alle Artikel
- Filter nach Kategorie
- Such-Vorschläge (Autocomplete)
- Ergebnisse mit Snippet und Relevance

### Versionierung

- Jeder Artikel hat eine Versions-Historie
- Unterschiede zwischen Versionen anzeigen
- Rückgängig machen möglich
- Autor, Datum, Änderung des jeweiligen Versions

### Kategorien & Tags

- Jeder Artikel gehört zu einer Hauptkategorie
- Tags für gezielte Suche und Verknüpfung
- Kategorie-Übersicht als Seitenleiste oder separate Seite

---

## 8. Beispiele

### Beispiel: Wiki-Artikel "Haustechnik"

```markdown
# Haustechnik

SASA-IT bietet professionelle Haustechnik-Lösungen — von Smart Home bis Gebäudeautomation.
Wir planen, implementieren und betreuen intelligente Systeme für Ihr Gebäude.

## Dienstleistungen

- **Smart Home:** Automatisierte Steuerung von Licht, Heizung, Sicherheit
- **Gebäudeautomation:** Zentrale Steuerung von Lüftung, Klima, Energie
- **Überwachung:** Kameras, Alarmanlagen, Zugangskontrollsysteme
- **Integration:** Anbindung an bestehende Systeme, IoT-Sensoren

## Technologien

Wir nutzen offene und zuverlässige Technologien:

| Technologie | Anwendung | Beschreibung |
|-------------|-----------|--------------|
| Home Assistant | Smart Home | Offene Plattform für Hausautomation |
| MQTT | Sensor-Netzwerk | Leichtes Protokoll für IoT |
| Zigbee / Z-Wave | Funk-Kommunikation | Offene Standards für Hausautomation |
| KNX | Gebäudetechnik | Industriestandard für Gebäudeautomation |

## Vorteile

- **Offene Standards:** Keine Vendor-Lock-in, zukunftssicher
- **Sicherheit:** Datenschutz, lokale Verarbeitung, keine Cloud-Abhängigkeit
- **Skalierbar:** Von Einzelzimmer bis Gesamtgebäude
- **Monitoring:** Fernüberwachung und Wartung durch SASA-IT

## Siehe auch

- [Facility Management](wiki/facility-management.md)
- [IT-Infrastruktur](wiki/it-infrastruktur.md)
- [Sicherheit](wiki/sicherheit.md)
```

---

### Beispiel: Wiki-Artikel "Authentik"

```markdown
# Authentik — Identity Provider

Authentik ist unser Identity Provider für Single Sign-On (SSO), MFA und Benutzerverwaltung.
Alle SASA-IT Dienste authentifizieren sich über Authentik.

## Übersicht

| Feature | Beschreibung |
|---------|--------------|
| SSO | Einmal anmelden, alle Dienste nutzen |
| MFA | Multi-Faktor-Authentifizierung (TOTP, WebAuthn) |
| LDAP | Benutzerverwaltung und Sync |
| OIDC | OpenID Connect für moderne Apps |
| SAML | SAML 2.0 für Enterprise-Integrationen |

## Dienste mit Authentik

| Subdomain | Dienst | SSO aktiv |
|-----------|--------|-----------|
| `auth.sasa-it.de` | Authentik | — (SPO und IdP) |
| `office.sasa-it.de` | Nextcloud AIO | Ja (OIDC) |
| `sso.sasa-it.de` | NetBird | Ja (OIDC als IdP) |

## Einrichtung

(siehe Wiki-Konfigurationsartikel für Details)

## Sicherheit

- MFA für Admin-Accounts verpflichtend
- Session-Management: Timeout nach Inaktivität
- Brute-Force-Schutz: Rate Limiting, Lock-Out
- Audit-Logs: Alle Login-Versuche protokolliert

## Siehe auch

- [NetBird — VPN & SSO](wiki/netbird.md)
- [Nextcloud AIO](wiki/nextcloud-aio.md)
- [Sicherheit](wiki/sicherheit.md)
```

---

## 9. Wiki-Startseite

Die Wiki-Startseite (`wiki/README.md` oder `wiki/index.md`) ist der Einstiegspunkt. Sie enthält:

- Willkommen-Text (kurz, einsteigerfreundlich)
- Kategorie-Übersicht (mit Links zu den wichtigsten Artikeln)
- Suche (oder Hinweis auf Suchfeld)
- Zuletzt aktualisierte Artikel (optional)
- Kontakt / Feedback-Möglichkeit

---

## 10. Wartung & Governance

### Erstellung neuer Artikel

1. **Thema definieren:** Was gehört in den Artikel?
2. **KI-Unterstützung (optional):** Entwurf mit NIM / Claude
3. **Prüfung:** Faktencheck, Stil, Vollständigkeit
4. **Hinzufügen:** Markdown-Datei im `wiki/` Verzeichnis
5. **Verlinkung:** Artikel in Startseite / Kategorie-Übersicht verlinken

### Aktualisierung bestehender Artikel

- Regelmäßige Prüfung: Stimmt der Inhalt noch?
- Neue Informationen einfügen
- Stilkonsistenz wahren
- Versionsdatum aktualisieren

### Löschung / Archivierung

- Überflüssige Artikel archivieren (nicht löschen, falls noch referenziert)
- Verweise auf archivierte Artikel aktualisieren

---

## 11. Technischer Hintergrund

### Basiert auf

- **Markdown-Dateien** im Git Repository
- **Nextcloud Files** (für Datei-Speicherung, nicht für Wiki)
- **Web-Bereitstellung:** Caddy als Reverse Proxy, Wiki als statische HTML-Seiten oder via Nextcloud Files Preview

### Optionen für Web-Zugriff

1. **Statische Wiki-Seiten** (via Caddy): Wiki als HTML mit Suchfunktion
2. **Nextcloud Files:** Wiki-Dateien hochladen, Vorschau über Nextcloud
3. **Wiki-Software:** (optional) eigene Wiki-Software hinter Caddy

**Aktuelle Entscheidung:** Markdown-Dateien im Git + statische HTML-Bereitstellung über Caddy + Kopiervorlagen im Nextcloud für Datei-Zugriff.

---

## 12. Zukunft

- **KI-Unterstützung bei Suche:** Semantische Suche über Embeddings
- **Interactive Content:** Möglichkeit, mit dem Wiki zu interagieren (FAQ-Bot, Assistent)
- **Multi-Sprachigkeit:** Falls nötig, englische Versionen paralleler Artikel
- **Dokumentation für Entwickler:** API-Referenz, Architekturdiagramme

---

**Stand:** August 2026  
**Design-Tokens:** `DESIGN.md`  
**Verantwortlich:** SASA-IT Wiki Admin
