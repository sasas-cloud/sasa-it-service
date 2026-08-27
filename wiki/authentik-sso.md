# Authentik SSO — SASA-IT Identity Provider

> **Stand:** August 2026  
> **Zweck:** SSO, OIDC, SAML, MFA — zentrale Authentifizierung für alle SASA-IT Dienste  
> **Quelle:** [Authentik Dokumentation](https://docs.goauthentik.io/)

---

## Übersicht

Authentik ist das Identity Provider (IdP) für die SASA-IT Plattform. Alle Subdomains authentifizieren sich darüber:

| Subdomain | SSO-Methode | Status |
|-----------|-------------|--------|
| `auth.sasa-it.de` | Authentik selbst (IdP) | — |
| `office.sasa-it.de` | Nextcloud AIO → OIDC | Aktiv |
| `sso.sasa-it.de` | NetBird → OIDC | Aktiv |
| `wiki.sasa-it.de` | Wiki.js → OIDC | Aktiv |
| `grafana.sasa-it.de` | Grafana → OIDC/SAML | Optional |

---

## Architecture

```
User Browser
    │
    ▼
auth.sasa-it.de (Authentik IdP)
    │
    ├── OIDC ──────────────┐
    ├── SAML ◄─────────────┤
    ├── LDAP ──────────────┤
    └── MFA (TOTP/WebAuthn) ┘
    │
    ▼
Nextcloud / NetBird / Wiki.js / Grafana
    (via Authentik Session, Redirect)
```

---

## Features

| Feature | Beschreibung |
|---------|-------------|
| **SSO** | Einmal anmelden — alle Dienste ohne weiteres Login |
| **MFA** | TOTP (Authenticator-App), WebAuthn (FIDO2/Passkey) |
| **LDAP** | Benutzerverwaltung, Sync mit externen Verzeichnissen |
| **OIDC** | OpenID Connect — modern, für Nextcloud, NetBird, Wiki.js |
| **SAML** | Für Enterprise-Kunden, die SAML verlangen |
| **Audit Logs** | Alle Login-Versuche, Abfragen, Änderungen protokolliert |
| **Brute-Force-Schutz** | Rate Limiting, Lock-Out nach fehlgeschlagenen Versuchen |
| **Session-Management** | Timeout nach Inaktivität, Logout über IdP |

---

## Einrichtung (SASA-IT)

### 1. Authentik Installation

```bash
# Docker Compose (wie im sasa-it-service/docker/authentik/)
cd docker/authentik
docker compose up -d
```

Authentik läuft intern auf Port 9000, Caddy reverse-proxies nach `auth.sasa-it.de`.

### 2. Admin-Account erstellen

- Erster Login über `https://auth.sasa-it.de/if/flow/initial-setup/` (oder via Docker .env `AUTHENTIK_ADMIN_PASSWORD`)
- Admin-Account mit starkem Passwort + MFA aktivieren

### 3. Outgoing + Intermediate CA

Authentik benötigt Outgoing-HTTP-Zugang für some Flows. Standard-Konfiguration reicht.

### 4. SSO für Nextcloud AIO konfigurieren

**In Nextcloud (Admin → SSO & SAML):**

```
Provider: OpenID Connect
Identifier: https://auth.sasa-it.de/application/o/nextcloud/
Client ID: (von Authentik Application erzeugt)
Client Secret: (von Authentik Application erzeugt)
Redirect URI: https://office.sasa-it.de/apps/openid_connect/login
```

**In Authentik:**

- Application erstellen: `nextcloud`
- Redirect URI: `https://office.sasa-it.de/apps/openid_connect/login`
- Grant: `authorization_code`, `openid`, `profile`, `email`
- Output: Client ID + Secret

### 5. SSO für NetBird

```
Provider: OpenID Connect
Identifier: https://auth.sasa-it.de/application/o/netbird/
Client ID + Secret von Authentik
Redirect URI: (NetBird Dashboard URL)
```

### 6. SSO für Wiki.js

```
Provider: OpenID Connect
Identifier: https://auth.sasa-it.de/application/o/wikijs/
Redirect URI: https://wiki.sasa-it.de/.oidc/return
```

---

## MFA

**Empfehlung:** MFA für alle Admin-Accounts verpflichtend.

| Methode | Sicherheit | Bequemlichkeit |
|---------|------------|----------------|
| **TOTP** (Authenticator-App) | Hoch | Hoch — Standard |
| **WebAuthn** (FIDO2/Passkey) | Sehr Hoch | Hoch — für Admins empfohlen |
| **E-Mail** | Mittel | Niedrig — nur Fallback |

**Konfiguration:** Authentik Admin → Policies → MFA erzwingen für bestimmte Gruppen.

---

## LDAP (Optional)

Wenn Benutzer aus einem bestehenden Verzeichnis kommen:

- Externes LDAP/AD als Benutzersource einbinden
- Authentik agiert als Proxy oder Sync
- Vorteile: Einheitliche Benutzerverwaltung, Passwort-Richtlinien zentral

---

## Sicherheit

- **Session-Timeout:** Nach 24h Inaktivität neu authentifizieren
- **Brute-Force:** Rate Limiting, IP-basiertes Lock-Out
- **Audit:** Alle Events in Authentik → Logs → (optional: zentrale Log-Sammlung)
- **HTTPS:** Nur über Caddy (HTTPS, HSTS)

---

## Troubleshooting

| Problem | Lösung |
|---------|--------|
| Login funktioniert nicht | Authentik Logs prüfen (`docker logs authentik`); Redirect URI korrekt? |
| Session geht verloren | Cookie-Domain über Subdomains? Caddy Header-Config? |
| MFA nicht verfügbar | Policy für Benutzer/Gruppe aktiviert? |
| NetBird verbindet nicht | OIDC-Application in Authentik korrekt? Redirect URI? |

---

**Verantwortlich:** SASA-IT Admin  
**Blind:** August 2026  
**Review:** Bei Änderungen an SSO-Flows
