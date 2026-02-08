INVENTORY = ansible/inventory.yml
VAULT_PASS = ansible/.vault_pass

ANSIBLE_BASE = ansible-playbook -i $(INVENTORY) --vault-password-file $(VAULT_PASS)

SETUP_PLAYBOOK = ansible/setup.yml
SERVICES_PLAYBOOK = ansible/services.yml
APPS_PLAYBOOK = ansible/apps.yml

# ── All ──────────────────────────────────────────
all:
	$(ANSIBLE_BASE) $(SETUP_PLAYBOOK) $(SERVICES_PLAYBOOK) $(APPS_PLAYBOOK)

# ── Setup ────────────────────────────────────────
setup:
	$(ANSIBLE_BASE) $(SETUP_PLAYBOOK)

hardening:
	$(ANSIBLE_BASE) $(SETUP_PLAYBOOK) --tags hardening

docker:
	$(ANSIBLE_BASE) $(SETUP_PLAYBOOK) --tags docker

# ── Services ─────────────────────────────────────
services:
	$(ANSIBLE_BASE) $(SERVICES_PLAYBOOK)

traefik:
	$(ANSIBLE_BASE) $(SERVICES_PLAYBOOK) --tags traefik

jenkins:
	$(ANSIBLE_BASE) $(SERVICES_PLAYBOOK) --tags jenkins

# ── Apps ─────────────────────────────────────────
apps:
	$(ANSIBLE_BASE) $(APPS_PLAYBOOK)

portfolio:
	$(ANSIBLE_BASE) $(APPS_PLAYBOOK) --tags portfolio

# ── Utils ────────────────────────────────────────
ping:
	ansible ovh-server -i $(INVENTORY) -m ping --vault-password-file $(VAULT_PASS)

check:
	$(ANSIBLE_BASE) $(SETUP_PLAYBOOK) $(SERVICES_PLAYBOOK) $(APPS_PLAYBOOK) --check --diff

vault-edit:
	ansible-vault edit ansible/group_vars/all/vault.yml --vault-password-file $(VAULT_PASS)

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "All:"
	@echo "  all          Run all playbooks"
	@echo "  check        Dry-run all playbooks (--check --diff)"
	@echo ""
	@echo "Setup:"
	@echo "  setup        Run full setup playbook"
	@echo "  hardening    Run hardening role (fail2ban)"
	@echo "  docker       Run Docker role (docker + networks)"
	@echo ""
	@echo "Services:"
	@echo "  services     Run all services (traefik, jenkins)"
	@echo "  traefik      Run Traefik only"
	@echo "  jenkins      Run Jenkins only"
	@echo ""
	@echo "Apps:"
	@echo "  apps         Run all apps"
	@echo "  portfolio    Run Portfolio only"
	@echo ""
	@echo "Utils:"
	@echo "  ping         Test SSH connection"
	@echo "  vault-edit   Edit encrypted vault"
	@echo "  help         Show this help"

.DEFAULT_GOAL := help
.PHONY: all setup hardening docker services traefik jenkins apps portfolio ping check vault-edit help