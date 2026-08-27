# GitLab Runner / CI/CD — SASA-IT Integrationsdoku

**Stand:** August 2026  
**Zweck:** GitLab Runner für SASA-IT Docker-Infrastruktur einrichten

---

## 1. GitLab Runner Installation (Self-Managed)

### Voraussetzungen

- GitLab Instanz (GitLab.com oder Self-Managed)
- Docker installiert auf dem Host (bereits da für SASA-IT)
- `gitlab-runner` Binary

### Installation (Linux / Docker)

```bash
# Option A: GitLab Runner als Docker Container (empfohlen)

# Erstmal Register-Token aus GitLab holen:
# GitLab → Projekt/Einstellungen → CI/CD → Runners → Neuer Runner
# Kopiere das Token

docker run -d --name gitlab-runner \
  --restart unless-stopped \
  -v gitlab-runner-config:/etc/gitlab-runner \
  -v /var/run/docker.sock:/var/run/docker.sock \
  gitlab/gitlab-runner:latest

# Runner registrieren
docker exec -it gitlab-runner gitlab-runner register \
  --url https://gitlab.com/ \
  --registration-token <DEIN_REGISTRATION_TOKEN> \
  --executor docker \
  --docker-image alpine:latest \
  --description "SASA-IT Runner" \
  --tag-list "sasa-it,linux,docker" \
  --non-interactive
```

### Runner Konfiguration (`config.toml`)

```toml
concurrent = 5
check_interval = 0

[session_server]
  session_timeout = 1800

[[runners]]
  name = "SASA-IT Runner"
  url = "https://gitlab.com/"
  id = 1
  token = "<RUNNER_TOKEN>"
  executor = "docker"
  [runners.custom_build_dir]
  [runners.docker]
    tls_verify = false
    image = "alpine:latest"
    privileged = false
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
    volumes = ["/cache", "/var/run/docker.sock:/var/run/docker.sock"]
    shm_size = 0
    network_mode = "bridge"
  [runners.cache]
    Type = "local"
    Path = "/cache"
    Shared = true
```

---

## 2. GitLab CI/CD Pipeline (`.gitlab-ci.yml`)

### Basis-Pipeline für SASA-IT Projekte

```yaml
stages:
  - lint
  - test
  - build
  - deploy

variables:
  DOCKER_DRIVER: overlay2
  DOCKER_TLS_CERTDIR: ""

# Default für alle Jobs
default:
  image: alpine:latest
  before_script:
    - apk add --no-cache bash git curl docker-compose

# Lint: Shell-Skripte und YAML prüfen
lint:
  stage: lint
  tags:
    - sasa-it
  script:
    - echo "Linting shell scripts..."
    - find . -name "*.sh" -exec bash -n {} \;
    - echo "Linting Docker Compose files..."
    - docker-compose -f docker/docker-compose.yml config --quiet || true
    - docker-compose -f docker/monitoring/docker-compose.yml config --quiet || true
    - docker-compose -f docker/authentik/docker-compose.yml config --quiet || true
  allow_failure: false

# Test: Grundlegende Tests (z.B. Konfigurations-Syntax)
test:
  stage: test
  tags:
    - sasa-it
  script:
    - echo "Running basic sanity tests..."
    - test -f Caddyfile
    - test -f docs/architecture.md
    - test -f docs/security-ssl.md
    - echo "All required documentation files present"

# Build: Docker Images bauen (optional, für eigene Images)
build:
  stage: build
  tags:
    - sasa-it
  script:
    - echo "Building Docker images (if any custom)..."
    - cd docker
    - for compose_file in *.yml; do
        if [ -f "$compose_file" ]; then
          echo "Processing $compose_file"
          docker-compose -f "$compose_file" config --quiet || echo "Config check failed for $compose_file"
        fi
      done
  allow_failure: true

# Deploy: Docker Container starten (für Selbst-Managed GitLab)
deploy:
  stage: deploy
  tags:
    - sasa-it
  script:
    - echo "Deploying SASA-IT infrastructure..."
    - cd /home/sasa/sasa-it-service/docker
    - docker-compose pull || true
    - docker-compose up -d || true
  environment:
    name: production
    url: https://sasa-it.de
  when: manual
  only:
    - master
  allow_failure: false
```

---

## 3. Gitlab CI für einzelne Dienste

### Authentik CI

```yaml
authentik-lint:
  stage: lint
  tags:
    - sasa-it
  script:
    - cd docker/authentik
    - docker-compose config --quiet
    - echo "Authentik Config valid"
  allow_failure: false

authentik-up:
  stage: deploy
  tags:
    - sasa-it
  script:
    - cd docker/authentik
    - docker-compose pull
    - docker-compose up -d
  environment:
    name: auth
    url: https://auth.sasa-it.de
  when: manual
  only:
    - master
```

### Monitoring CI

```yaml
monitoring-lint:
  stage: lint
  tags:
    - sasa-it
  script:
    - cd docker/monitoring
    - docker-compose config --quiet
    - test -f prometheus.yml
    - echo "Monitoring Config valid"
  allow_failure: false

monitoring-up:
  stage: deploy
  tags:
    - sasa-it
  script:
    - cd docker/monitoring
    - docker-compose pull
    - docker-compose up -d
  environment:
    name: monitoring
    url: https://grafana.sasa-it.de
  when: manual
  only:
    - master
```

---

## 4. GitLab Runner Tags

| Tag | Beschreibung | Verwendung |
|-----|-------------|-------------|
| `sasa-it` | Allgemeiner SASA-IT Runner | Alle SASA-IT Jobs |
| `linux` | Linux-basierte Jobs | Shell-Skripte, Linux-Konfiguration |
| `docker` | Docker-spezifische Jobs | Docker Builds, Docker Compose |
| `monitoring` | Monitoring-spezifisch | Prometheus, Grafana, Exporter |

---

## 5. Runner verwalten

### Runner anzeigen

```bash
# Runner status prüfen
docker exec gitlab-runner gitlab-runner verify

# Runner registrierte Tokens anzeigen
docker exec gitlab-runner gitlab-runner list
```

### Runner entfernen

```bash
docker stop gitlab-runner
docker rm gitlab-runner
```

---

## 6. Best Practices

1. **Runner-Tags verwenden** — um Jobs spezifischen Runtern zuzuweisen
2. **Docker Socket mounten** — für Docker-in-Docker (nur wenn nötig, Sicherheitsrisiko beachten)
3. **Cache nutzen** — um Build-Zeiten zu verbessern
4. **Manuelle Deployment-Schritte** — für Production-Deployment immer `when: manual`
5. **Environment-Variablen** — Secrets nie im YAML, sondern als GitLab CI/CD Variablen (Settings → CI/CD → Variables)

---

## 7. GitLab CI/CD Variablen (Secrets)

In GitLab → Projekt → Einstellungen → CI/CD → Variables:

| Variable | Wert | Sichtbar in Job Log |
|----------|------|---------------------|
| `GITLAB_TOKEN` | PAT oder Runner Token | Nein |
| `SSH_PRIVATE_KEY` | SSH Key für Deploy | Nein |
| `DOCKER_PASSWORD` | Registry Password | Nein |
| `DOCKER_USERNAME` | Registry Username | Nein |

---

## 8. Troubleshooting

| Problem | Lösung |
|---------|--------|
| Runner geht nicht ins Online | Token prüfen, URL prüfen, Network-Probleme |
| Job wartet auf Runner | Runner-Tags prüfen, Runner-Kapazität, Runner-Status |
| Docker Befehle in Job fehlerhaft | Docker Socket Mount prüfen, Berechtigungen |
| Cache nicht funktionsfähig | Cache-Pfad in config.toml prüfen, Verzeichnis existiert |

---

## 9. Integration in SASA-IT

```
GitLab
    │
    ├── .gitlab-ci.yml (Projekt)
    │
    ├── GitLab Runner (Docker, Self-Managed)
    │
    └── Jobs:
        ├── lint (Shell/YAML Prüfung)
        ├── test (Dateien prüfen)
        ├── build (Docker Compose Config)
        └── deploy (docker-compose up -d)
```

---

**Stand:** August 2026  
**Verantwortlich:** SASA-IT DevOps  
**GitLab:** https://gitlab.com/sasas-cloud (oder Self-Managed)
