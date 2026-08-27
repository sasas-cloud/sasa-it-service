---
version: alpha
name: SASA-IT
description: >
  Stark schwarz-weiß, futuristisch, präzise.
  IT-Dienstleistungen / Haustechnik / Facility Management.
  Hochwertig, sicher, verantwortungsvoll.
colors:
  primary: "#0A0A0A"
  secondary: "#1A1A1A"
  surface: "#FAFAFA"
  accent: "#0066FF"
  accent-dark: "#004A99"
  text: "#111111"
  text-muted: "#666666"
  border: "#E5E5E5"
  success: "#00A36C"
  danger: "#D32F2F"
  warning: "#FF8C00"
typography:
  display:
    fontFamily: "Inter, -apple-system, BlinkMacSystemFont, sans-serif"
    fontSize: "4rem"
    fontWeight: 800
    lineHeight: 1.05
    letterSpacing: "-0.03em"
  heading-xl:
    fontFamily: "Inter, -apple-system, BlinkMacSystemFont, sans-serif"
    fontSize: "2.5rem"
    fontWeight: 700
    lineHeight: 1.15
    letterSpacing: "-0.02em"
  heading-lg:
    fontFamily: "Inter, -apple-system, BlinkMacSystemFont, sans-serif"
    fontSize: "1.75rem"
    fontWeight: 600
    lineHeight: 1.2
  heading-md:
    fontFamily: "Inter, -apple-system, BlinkMacSystemFont, sans-serif"
    fontSize: "1.25rem"
    fontWeight: 600
    lineHeight: 1.3
  body-lg:
    fontFamily: "Inter, system-ui, sans-serif"
    fontSize: "1.0625rem"
    fontWeight: 400
    lineHeight: 1.6
  body-md:
    fontFamily: "Inter, system-ui, sans-serif"
    fontSize: "0.9375rem"
    fontWeight: 400
    lineHeight: 1.55
  mono:
    fontFamily: "JetBrains Mono, monospace"
    fontSize: "0.875rem"
    fontWeight: 400
spacing:
  xs: "4px"
  sm: "8px"
  md: "16px"
  lg: "24px"
  xl: "32px"
  2xl: "48px"
  3xl: "64px"
  4xl: "96px"
rounded:
  sm: "4px"
  md: "8px"
  lg: "12px"
  xl: "16px"
  full: "9999px"
shadows:
  sm: "0 1px 2px rgba(0,0,0,0.05)"
  md: "0 4px 12px rgba(0,0,0,0.08)"
  lg: "0 12px 32px rgba(0,0,0,0.12)"
  glow: "0 0 24px rgba(0,102,255,0.35)"
layout:
  max-width: "1200px"
  nav-height: "72px"
  navbar-width: "240px"
components:
  button-primary:
    backgroundColor: "{colors.accent}"
    textColor: "#FFFFFF"
    fontFamily: "Inter, system-ui, sans-serif"
    fontWeight: 600
    fontSize: "0.9375rem"
    borderRadius: "{rounded.md}"
    padding: "12px 24px"
    border: "none"
    cursor: "pointer"
    transition: "all 0.2s ease"
  button-primary-hover:
    backgroundColor: "{colors.accent-dark}"
    boxShadow: "{shadows.glow}"
  button-secondary:
    backgroundColor: "transparent"
    textColor: "{colors.text}"
    border: "1px solid {colors.border}"
    fontFamily: "Inter, system-ui, sans-serif"
    fontWeight: 500
    fontSize: "0.9375rem"
    borderRadius: "{rounded.md}"
    padding: "11px 22px"
    cursor: "pointer"
  button-secondary-hover:
    borderColor: "{colors.text-muted}"
    backgroundColor: "rgba(0,0,0,0.03)"
  card:
    backgroundColor: "{colors.surface}"
    border: "1px solid {colors.border}"
    borderRadius: "{rounded.lg}"
    padding: "{spacing.lg}"
    boxShadow: "{shadows.sm}"
  nav-link:
    textColor: "{colors.text-muted}"
    fontFamily: "Inter, system-ui, sans-serif"
    fontWeight: 500
    fontSize: "0.9375rem"
    textDecoration: "none"
    padding: "8px 0"
  nav-link-hover:
    textColor: "{colors.text}"
  hero-accent-line:
    backgroundColor: "{colors.accent}"
    height: "4px"
    width: "64px"
    borderRadius: "{rounded.full}"
---

# SASA-IT Design System

## Overview
SASA-IT ist dein IT-Dienstleistungsunternehmen — Haustechnik, Facility Management, Infrastruktur.
Das Design ist klar, modern, seriös. Schwarz/Weiß mit Blau als einzelner Akzentfarbe.
Kein Aufblähungsdesign — jeden Pixel hat einen Grund.

## Brand Feel
- **Stark** — wie ein Engineering-Unternehmen, nicht wie eine Marketing-Agentur
- **Zuverlässig** — klare Typografie, konsistente Abstände, keine Farb-Schere
- **Modern** — leise Rounded Corners, Inter-Schrift, Blau-Akzent nur dort wo Handlung gebietet wird

## Colors
- **Primary (#0A0A0A):** Haupthintergrund, dunkle Bereiche, Footer.
- **Surface (#FAFAFA):** Wechselseitiger Hauptgrund — beim Landing Page Hell-Modus.
- **Accent (#0066FF):** Einziger Farbschub — Buttons, Links, Highlights, Icons.
- **Text (#111111):** Haupttext auf hellem Grund.
- **Text-muted (#666666):** Sekundärer Text, Labels, Beschreibungen.
- **Border (#E5E5E5):** Trennlinien, Rahmen, klare Struktur.

## Typography
Inter als Hauptschrift — modern, lesbar, professionell.
JetBrains Mono für Code, Terminal-Beispiele, technische Hinweise.
Größen folgen dem Designsystem oben — niemals zufällig.

## Layout
- Maximale Breite 1200px zentriert — nie fließend bis Ränder.
- Navigation 72px hoch — klar, übersichtlich, Bookmark-fähig.
- Abstände nach dem Spacing-Schema — kein improvisiertes Padding.

## Components
- **Button-primary:** Blau, weiß Text, Hover-Glow. Einziger primärer CTA.
- **Button-secondary:** Outlined, schwarz Text. Alternativer Aktionsbutton.
- **Card:** Weiß/Silber, sanfter Schatten, rund 12px. Für Services, Features, Inhalte.
- **Nav-Link:** Muted Text, Hover: schwarz. Klare Navigation ohne Verzierungen.

## Do's and Don'ts
- **Do:** Accent blau nur für Handlungselemente und Highlights verwenden.
- **Do:** Weißes Layout (surface) für Lesen / Doku, schwarz für Landing / Hero-Bereiche.
- **Do:** Code und technische Inhalte in JetBrains Mono.
- **Don't:** Mehr als 2 Schriftfamilien pro Seite.
- **Don't:** Pastellfarben, Gradient-Hintergründe, dicken Schatten — das wirkt billig.
- **Don't:** Akzentfarbe für dekorative Elemente ohne Funktion.
