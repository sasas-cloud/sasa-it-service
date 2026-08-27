# HTML/CSS Best Practices — SASA-IT Plattform

## Single Source of Truth

- **Design-Tokens:** `DESIGN.md` (Dokumentation) + `landing-page/tokens.css` (Code)
- Änderungen am Design nur an diesen zwei Stellen — nicht in den HTML-Dateien

## CSS-Regeln

1. **Tokens über externe Dateien** — alle Seiten binden `tokens.css` ein
   ```html
   <link rel="stylesheet" href="tokens.css">
   ```
2. **Kein Inline-CSS** — kein `style="..."` im HTML, außer für komplexe Animationen mit Kommentar
3. **Keine duplizierten `:root`-Blöcke** — jeder Seiten-`<style>` startet nach den Tokens, nicht mit ihnen
4. **CSS-Klassen konvention:** Klare, semantische Namen. Kein `div1`, `box2` etc.
5. **`!important` nur mit Begründung** — Kommentar im CSS, warum es nötig ist

## Schriftarten

- **Nur zwei Familien:** Inter (Hauptschrift) + JetBrains Mono (Code)
- Google Fonts Link in jeder Seite:
  ```html
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
  ```

## Responsive Breakpoints

```
480px  — sehr kleine Screens (Smartphones kompakt)
600px  — Standard-Smartphones
768px  — Tablets (nav-links ausgeblendet)
900px  — kleine Laptops (grid → single column)
```

## Dateistruktur

```
landing-page/
├── index.html        ← Hauptlanding Page
├── tokens.css        ← Design-Tokens (Single Source of Truth)
├── contact-section.html
├── contact-embed.html
├── wetter-embed.html
└── wetter-widget.html
```

- **Kein `index.built.html` oder andere redundante Build-Ausgaben** in der Repository-Root
- Build-Artifacts gehören in `.gitignore` oder ein `dist/`-Verzeichnis

## Neuen HTML-Code schreiben

1. `tokens.css` einbinden
2. Tags schließen (keine offenen `<div>`)
3. Konsistente Klassen-Namen
4. Responsive: mobile-first, Breakpoints nach Tabelle oben
5. Testen im Browser (Responsive Design Mode)

## Code-Review Checklist

- [ ] `tokens.css` eingebunden (kein dupliziertes `:root`)
- [ ] Akzentfarbe = `#0066FF` (nicht `#635bff` oder andere)
- [ ] Schriftarten: Inter + JetBrains Mono nur
- [ ] Kein Inline-CSS ohne Kommentar
- [ ] Responsive Breakpoints vorhanden
- [ ] Alle Tags geschlossen
- [ ] Keine redundanten Dateien (Build-Ausgaben, Kopien)
