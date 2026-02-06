# Welcome to my Portfolio Structure !

> Automated provisioning, hardening, and configuration of my personal server using Ansible.

## Overview

This repository contains the Ansible configuration used to manage my personal OVH server. It covers:

- **Security hardening** — Fail2ban
- **Base setup** — Docker, Docker networks
- **Services** — Traefik reverse proxy with automatic HTTPS, Jenkins CI/CD

---

## Local prerequisites (MacOS)

| Tool     | Version  | Installation                                                                                      |
|----------|----------|---------------------------------------------------------------------------------------------------|
| Homebrew | ≥ 5.0.13 | `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"` |
| Git      | ≥ 2.50.1 | `brew install git`                                                                                |
| Ansible  | ≥ 2.20.2 | `brew install ansible`                                                                            |
| Python   | ≥ 3.14.2 | `brew install python`                                                                             |
| SSH key  | —        | Must be configured for the target host                                                            |

---

## Project Structure

```
.
├── Makefile                        # Shortcut commands
├── ansible/
│   ├── group_vars/
│   │   └── all/
│   │       └── vault.yml         # Encrypted secrets (ansible-vault)
│   ├── roles/
│   │   ├── docker/               # Docker installation
│   │   ├── fail2ban/             # Brute-force protection
│   │   ├── networks/             # Docker networks
│   │   ├── traefik/              # Traefik reverse proxy + ACME
│   │   └── jenkins/              # Jenkins CI/CD server
│   ├── .vault_pass               # Vault password file (git-ignored)
│   ├── inventory.yml             # Host inventory
│   └── playbook.yml              # Main playbook (all roles)
└── README.md
```

---

## Getting Started

### 1. Clone the project

```bash
git clone https://github.com/Jyok1m/portfolio-server.git

cd portfolio-server
```

### 2. Configure the Vault

```bash
cd ansible
```

**Create** the vault file to store your secrets:

```bash
EDITOR=nano ansible-vault create group_vars/all/vault.yml
```

You will be prompted for a **Vault password** — keep it safe.

Then store it in the password file so you don't have to type it each time:

```bash
echo 'your-vault-password' > .vault_pass
chmod 600 .vault_pass
```

**Edit** the vault later:

```bash
EDITOR=nano ansible-vault edit group_vars/all/vault.yml
```

Populate the vault with the following variables:

```yaml
vault_server_host: <server_ip>
vault_server_port: <port>
vault_server_user: <user>
vault_ssh_key_path: <ssh_file_path>
vault_dockerhub_username: <dockerhub_username>
vault_dockerhub_password: <dockerhub_token>
```

### 3. Test the Connection

```bash
make ping
```

**Expected output:**

```bash
ovh-server | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3.13"
    },
    "changed": false,
    "ping": "pong"
}
```

---

## Usage

| Command          | Description                              |
|------------------|------------------------------------------|
| `make all`       | Run all roles                            |
| `make hardening` | Run hardening roles (fail2ban)           |
| `make docker`    | Run Docker roles (docker + networks)     |
| `make services`  | Run service roles (traefik, jenkins)     |
| `make jenkins`   | Run Jenkins role only                    |
| `make ping`      | Test SSH connection to the server        |
| `make help`      | Show available commands                  |

| Role     | Tag         | Description                               |
|----------|-------------|-------------------------------------------|
| fail2ban | hardening   | Brute-force IP protection                 |
| docker   | docker      | Container runtime + orchestration         |
| networks | docker      | Docker networks for the services          |
| traefik  | services    | Reverse proxy with automatic HTTPS (ACME) |
| jenkins  | services    | CI/CD server (build + push to Docker Hub) |

> **Note:** SSH hardening (port + auth config) is intentionally done manually on the server to prevent access lock.

<p style="text-align: center">
  <sub>Built by <a href="https://github.com/Jyok1m">Joachim Alexandre Jasmin</a></sub>
</p>