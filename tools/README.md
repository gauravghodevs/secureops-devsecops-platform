# Local DevSecOps tools

SonarQube and Dependency-Track, run with Docker Compose. This is the self-hosted pair the
pipelines (`ci/tekton/payment-api-secure-pipeline.yaml`, `scripts/dtrack_gate.py`) talk to.

## Start

SonarQube refuses to start unless the host allows enough memory maps:

```bash
# Linux
sudo sysctl -w vm.max_map_count=524288
# Windows with Docker Desktop (WSL2)
wsl -d docker-desktop sysctl -w vm.max_map_count=524288
```

Then, from this directory (allow 6-8 GB of RAM for Docker):

```bash
cp .env.example .env     # set SONAR_DB_PASSWORD
docker compose up -d
docker compose ps
```

First start takes a few minutes. Log in to both UIs (`admin` / `admin`) and change the password.

## One-time setup

1. SonarQube: *My Account > Security > Generate Tokens* (type *Project Analysis Token* or a user
   token). This is `SONAR_TOKEN`.
2. Dependency-Track: *Administration > Access Management > Teams > Automation*. Give the team the
   permissions `BOM_UPLOAD`, `PROJECT_CREATION_UPLOAD` and `VIEW_PORTFOLIO`, then copy its API key.
   This is `DT_API_KEY`.

## Stop

```bash
docker compose down        # keep data
docker compose down -v     # delete data too
```
