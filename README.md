# Portfolio Server

> Automated provisioning, hardening, and deployment of my personal server using Ansible.

## Overview

This repository contains the Ansible configuration used to manage my personal OVH server. It covers:

- **Security hardening** — Fail2ban
- **Base setup** — Docker, Docker networks
- **Monitoring** — Prometheus, Grafana, Node Exporter, cAdvisor
- **Reverse proxy** — Traefik with automatic HTTPS (Let's Encrypt)
- **CI/CD** — Jenkins with Docker-in-Docker
- **Databases** — MongoDB (dev, staging, production)
- **Apps** — Portfolio, Ipseis backend (dev, staging, production)

All secrets are stored in an encrypted Ansible Vault. Configuration files are templated with Jinja2, so no sensitive value appears in plain text.

---

## Local prerequisites (macOS)

| Tool    | Version | Installation                                                                                      |
|---------|---------|---------------------------------------------------------------------------------------------------|
| Homebrew | ≥ 5.x  | `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"` |
| Git     | ≥ 2.x   | `brew install git`                                                                                |
| Ansible | ≥ 2.15  | `brew install ansible`                                                                            |
| Python  | ≥ 3.11  | `brew install python`                                                                             |
| SSH key | —       | Must be configured for the target host                                                            |

---

## Project structure

```
.
├── Makefile                                  # Shortcut commands (make traefik, make apps, etc.)
├── ansible/
│   ├── ansible.cfg                           # Auto-config (inventory, vault, roles_path)
│   ├── requirements.yml                      # External collections (community.docker, ansible.posix)
│   ├── site.yml                              # Master playbook — imports all sub-playbooks
│   ├── .vault_pass                           # Vault password file (git-ignored)
│   │
│   ├── inventory/
│   │   └── hosts.yml                         # Host inventory (ovh-server)
│   │
│   ├── group_vars/all/
│   │   ├── vars.yml                          # Shared variables (domains, image versions, networks)
│   │   └── vault.yml                         # Encrypted secrets (passwords, tokens, keys)
│   │
│   ├── playbooks/
│   │   ├── setup.yml                         # fail2ban → docker → networks → monitoring
│   │   ├── databases.yml                     # mongo
│   │   ├── services.yml                      # docker_login → traefik → jenkins
│   │   └── apps.yml                          # docker_login → portfolio → ipseis
│   │
│   └── roles/
│       ├── fail2ban/                         # Brute-force protection
│       ├── docker/                           # Docker + Docker Compose installation
│       ├── networks/                         # Docker networks (global, jenkins, ipseis, etc.)
│       ├── docker_login/                     # Docker Hub authentication (shared role)
│       ├── monitoring/                       # Prometheus + Grafana + Node Exporter + cAdvisor
│       ├── traefik/                          # Reverse proxy + ACME (Let's Encrypt)
│       ├── jenkins/                          # Jenkins CI/CD with Docker-in-Docker
│       ├── mongo/                            # MongoDB (dev, stg, prod)
│       ├── portfolio/                        # Portfolio website
│       └── ipseis/                           # Ipseis backend (dev, stg, prod)
│
│       Each role follows the standard layout:
│       └── <role>/
│           ├── defaults/main.yml             # Default variables (overridable)
│           ├── meta/main.yml                 # Description + dependencies
│           ├── tasks/main.yml                # Actions to execute
│           ├── handlers/main.yml             # Restart on config change (service roles)
│           ├── templates/                    # Jinja2 files (docker-compose.yml.j2, env.j2)
│           └── files/                        # Static files copied as-is (if any)
```

---

## Getting started

### 1. Clone the project

```bash
git clone https://github.com/Jyok1m/portfolio-server.git
cd portfolio-server
```

### 2. Install Ansible collections

```bash
make install-deps
```

### 3. Configure the Vault

Create the vault password file:

```bash
echo 'your-vault-password' > ansible/.vault_pass
chmod 600 ansible/.vault_pass
```

Edit the vault:

```bash
make vault-edit
```

Populate with the following variables:

```yaml
# Server connection
vault_server_host: <server_ip>
vault_server_port: <ssh_port>
vault_server_user: <user>
vault_ssh_key_path: <path_to_ssh_key>

# Docker Hub
vault_dockerhub_username: <dockerhub_username>
vault_dockerhub_password: <dockerhub_token>

# MongoDB passwords
vault_mongo_dev_root_password: <password>
vault_mongo_stg_root_password: <password>
vault_mongo_prod_root_password: <password>

# Ipseis secrets
vault_ipseis_jwt_secret: <jwt_secret>
vault_nodemailer_email: <email>
vault_nodemailer_password: <app_password>
vault_ipseis_backend_username: <username>
vault_ipseis_backend_password: <password>
```

### 4. Test the connection

```bash
make ping
```

Expected output:

```
ovh-server | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

---

## Usage

### Commands

| Command            | Description                              |
|--------------------|------------------------------------------|
| `make all`         | Run all playbooks                        |
| `make setup`       | Run full setup (hardening + docker + monitoring) |
| `make hardening`   | Run fail2ban only                        |
| `make docker`      | Run Docker installation only             |
| `make networks`    | Run Docker networks only                 |
| `make monitoring`  | Run monitoring stack only                |
| `make databases`   | Run all databases                        |
| `make mongo`       | Run MongoDB only                         |
| `make services`    | Run all services (traefik + jenkins)     |
| `make traefik`     | Run Traefik only                         |
| `make jenkins`     | Run Jenkins only                         |
| `make apps`        | Run all apps (portfolio + ipseis)        |
| `make portfolio`   | Run Portfolio only                       |
| `make ipseis`      | Run Ipseis only                          |
| `make install-deps`| Install Ansible collections              |
| `make ping`        | Test SSH connection                      |
| `make check`       | Dry-run all playbooks (`--check --diff`) |
| `make vault-edit`  | Edit encrypted vault                     |

### Roles

| Role         | Playbook       | Tag          | Description                                     |
|--------------|----------------|--------------|-------------------------------------------------|
| fail2ban     | setup.yml      | `hardening`  | Brute-force IP protection                       |
| docker       | setup.yml      | `docker`     | Container runtime + compose                     |
| networks     | setup.yml      | `networks`   | Docker networks for service isolation            |
| monitoring   | setup.yml      | `monitoring` | Prometheus, Grafana, Node Exporter, cAdvisor    |
| mongo        | databases.yml  | `mongo`      | MongoDB instances (dev, stg, prod)              |
| docker_login | services/apps  | —            | Docker Hub authentication (shared dependency)    |
| traefik      | services.yml   | `traefik`    | Reverse proxy with automatic HTTPS (ACME)       |
| jenkins      | services.yml   | `jenkins`    | CI/CD server with Docker-in-Docker              |
| portfolio    | apps.yml       | `portfolio`  | Portfolio website                               |
| ipseis       | apps.yml       | `ipseis`     | Ipseis backend (3 environments via profiles)    |

> **Note:** SSH hardening (port + auth config) is intentionally done manually on the server to prevent access lock.

---

## How it works

`ansible.cfg` automatically sets the inventory, vault password, and roles path. That's why `make` commands don't need `-i` or `--vault-password-file` flags.

When a template (docker-compose, .env) changes on the server, the associated **handler** triggers a `docker compose up -d --force-recreate`. If nothing changed, the final task just ensures the service is running (idempotent).

Variable priority (low → high):

1. `roles/*/defaults/main.yml` — role defaults
2. `group_vars/all/vars.yml` — shared variables
3. `group_vars/all/vault.yml` — encrypted secrets
4. CLI override (`-e "var=value"`)

<p style="text-align: center">
  <sub>Built by <a href="https://github.com/Jyok1m">Joachim Alexandre Jasmin</a></sub>
</p>
