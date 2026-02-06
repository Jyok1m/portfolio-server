# Welcome to my Portfolio Structure !

> Automated provisioning, hardening, and configuration of my personal server using Ansible.

## Overview

This repository contains the Ansible configuration used to manage my personal OVH server. It covers:

- **Security hardening** — Fail2ban
- **Base setup** — Docker, essential packages, user configuration, monitoring tools

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
├── ansible/
│   ├── group_vars/
│   │   └── all/
│   │       ├── vars.yml          # General variables
│   │       └── vault.yml         # Encrypted secrets (ansible-vault)
│   ├── roles/
│   │   ├── hardening/            # Security hardening tasks
│   │   ├── setup/                # Base server setup tasks
│   │   └── traefik/              # Traefik reverse proxy
│   ├── inventory.yml             # Host inventory
│   ├── hardening.yml             # Hardening playbook
│   ├── setup.yml                 # Setup playbook
│   └── services.yml              # Services deployment playbook
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

You will be prompted for a **Vault password** — keep it safe, you'll need it for every playbook run.

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
```

### 3. Test the Connection

```bash
ansible ovh-server -i inventory.yml -m ping --ask-vault-pass
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

## Playbooks

### Hardening

Secures the server: Fail2ban

```bash
ansible-playbook hardening.yml -i inventory.yml --ask-vault-pass
```

| Task                   | Description               |
|------------------------|---------------------------|
| Fail2ban               | Brute-force IP protection |

> **Note:** The SSH hardening (port + auth config) is intentionally done manually (not by Ansible) directly on the server to prevent access lock.

### Setup

Installs base tooling and configures the working environment.

```bash
ansible-playbook setup.yml -i inventory.yml --ask-vault-pass
```

| Task                    | Description                         |
|-------------------------|-------------------------------------|
| Docker & Docker Compose | Container runtime + orchestration   |
| Docker networks         | Different networks for the services |

### Services

Deploys containerized services to the server.

```bash
ansible-playbook services.yml -i inventory.yml --ask-vault-pass
```

Deploy a single service with tags:

```bash
ansible-playbook services.yml -i inventory.yml --ask-vault-pass --tags traefik
```

| Role    | Description                                  |
|---------|----------------------------------------------|
| Traefik | Reverse proxy with automatic HTTPS (ACME)    |

<p style="text-align: center">
  <sub>Built by <a href="https://github.com/Jyok1m">Joachim Alexandre Jasmin</a></sub>
</p>