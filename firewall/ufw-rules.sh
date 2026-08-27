#!/bin/bash
# firewall/ufw-rules.sh — UFW Firewall für SASA-IT Plattform

set -e

echo "=== SASA-IT Firewall Setup ==="
echo ""

# Standard: Alles blockieren
echo "Standard-Regel: incoming DENY, outgoing ALLOW"
ufw default deny incoming
ufw default allow outgoing

# SSH — von überall (praktisch, Key-basierte Auth ohne weiteren Schutz)
echo "SSH (22) — von überall"
ufw allow 22/tcp comment "SSH (Key-Auth nur, kein Password)"

# HTTP (80) — für LetsEncrypt + Redirect zu HTTPS
echo "HTTP (80) — für LetsEncrypt und Redirect"
ufw allow 80/tcp comment "HTTP for LetsEncrypt and redirect"

# HTTPS (443) — alle Subdomains über Caddy
echo "HTTPS (443) — alle Subdomains"
ufw allow 443/tcp comment "HTTPS for all subdomains"

# Nextcloud Talk — TURN/Coturn Ports (für Echtzeit-Kommunikation)
# 3 Ports für TURN: 3478 (TCP+UDP), und ggf. 5349 für TLS
echo "Nextcloud Talk TURN Ports — 3 Hauptports"
ufw allow 3478/tcp comment "Nextcloud Talk TURN TCP"
ufw allow 3478/udp comment "Nextcloud Talk TURN UDP"
ufw allow 3479/tcp comment "Nextcloud Talk TURN SSL TCP"
ufw allow 3479/udp comment "Nextcloud Talk TURN SSL UDP"

# Optional: Media Relay Ports (Nextcloud Talk benötigt oft einen Port-Bereich für Medienstreams)
# Typischerweise 20000-20009 für Coturn Medienrelais
echo "Nextcloud Talk Media Relay — optional (Port-Bereich)"
# ufw allow 20000:20009/tcp comment "Nextcloud Talk Media Relay TCP"
# ufw allow 20000:20009/udp comment "Nextcloud Talk Media Relay UDP"

echo ""
echo "Aktiviere UFW..."
ufw --force enable

echo ""
echo "=== Firewall Status ==="
ufw status verbose

echo ""
echo "=== Erledigt ==="
echo "Offene Ports: 22 (SSH), 80 (HTTP), 443 (HTTPS), 3478/3479 (TURN TCP+UDP)"
echo "Alle anderen Ports sind blockiert."
