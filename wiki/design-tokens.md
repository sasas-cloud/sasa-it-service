# Design-Tokens — SASA-IT Design System

> **Single Source of Truth:** `DESIGN.md` + `landing-page/tokens.css`

## Übersicht

SASA-IT verwendet ein konsistentes Farb-/Typografie-/Spacing-System über alle Webseiten. Die Tokens definieren das _eine_ korrekte Aussehen — keine Abweichungen.

## Farb-Palette

| Token | Wert | Verwendung |
|-------|------|-------------|
| `--color-primary` | `#0A0A0A` | Hintergründe, Footer, dunkle Bereiche |
| `--color-surface` | `#FAFAFA` | Haupthintergrund (hell) |
| `--color-surface-alt` | `#F4F4F5` | Karten, leicht abgehobene Elemente |
| `--color-accent` | `#0066FF` | Buttons, Links, Highlights — **einzige Akzentfarbe** |
| `--color-accent-dark` | `#0052CC` | Hover-Zustand von Akzent-Elementen |
| `--color-text` | `#111111` | Haupttext auf hellem Hintergrund |
| `--color-text-muted` | `#666666` | Sekundärer Text, Labels, Beschreibungen |
| `--color-border` | `#E5E5E5` | Trennlinien, Rahmen |
| `--color-success` | `#00A36C` | Erfolgsmeldungen, grüne Indikatoren |
| `--color-danger` | `#D32F2F` | Fehler, Löschaktionen |
| `--color-warning` | `#FF8C00` | Warnungen |

## Typografie

- **Hauptschrift:** Inter (Google Fonts: `Inter:wght@400;500;600;700;800`)
- **Monospace:** JetBrains Mono (Google Fonts: `JetBrains+Mono:wght@400;500`)
- **Max. 2 Schriftfamilien** pro Seite — keine zusätzlichen Google Fonts

## Abstände (Spacing Scale)

```
xs: 4px   sm: 8px   md: 16px   lg: 24px   xl: 32px   2xl: 48px   3xl: 64px
```

## Radius

```
sm: 4px   md: 8px   lg: 12px   xl: 16px   full: 9999px
```

## Nutzung

```html
<!-- Im <head> jeder Seite: -->
<link rel="stylesheet" href="tokens.css">
```

`tokens.css` wird von allen HTML-Seiten eingebunden. Änderungen am Design erfolgen **nur** in `DESIGN.md` und `tokens.css` — nicht in den einzelnen HTML-Dateien.

## Neue Tokens hinzufügen

1. `DESIGN.md` aktualisieren (Dokumentation)
2. `landing-page/tokens.css` aktualisieren (CSS)
3. HTML-Dateien ggf. anpassen (wenn neue Klassen nötig)

## Regeln

- Keine Abweichungen von Tokens in einzelnen Dateien — immer `tokens.css` nutzen
- Kein Inline-CSS (`style="..."` in HTML) außer für komplexe, seiten-spezifische Animationen
- Kein `!important` ohne Kommentar, warum es nötig ist
