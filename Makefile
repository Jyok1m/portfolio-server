ANSIBLE_DIR = ansible
ANSIBLE_BASE = cd $(ANSIBLE_DIR) && ansible-playbook

SETUP_PLAYBOOK = playbooks/setup.yml
SERVICES_PLAYBOOK = playbooks/services.yml
APPS_PLAYBOOK = playbooks/apps.yml
DATABASES_PLAYBOOK = playbooks/databases.yml

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

networks:
	$(ANSIBLE_BASE) $(SETUP_PLAYBOOK) --tags networks

monitoring:
	$(ANSIBLE_BASE) $(SETUP_PLAYBOOK) --tags monitoring

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

ipseis:
	$(ANSIBLE_BASE) $(APPS_PLAYBOOK) --tags ipseis

# ── Databases ────────────────────────────────────
databases:
	$(ANSIBLE_BASE) $(DATABASES_PLAYBOOK)

mongo:
	$(ANSIBLE_BASE) $(DATABASES_PLAYBOOK) --tags mongo

# ── Utils ────────────────────────────────────────
install-deps:
	cd $(ANSIBLE_DIR) && ansible-galaxy install -r requirements.yml

ping:
	cd $(ANSIBLE_DIR) && ansible ovh-server -m ping

check:
	$(ANSIBLE_BASE) $(SETUP_PLAYBOOK) $(SERVICES_PLAYBOOK) $(APPS_PLAYBOOK) --check --diff

vault-edit:
	cd $(ANSIBLE_DIR) && ansible-vault edit group_vars/all/vault.yml

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "All:"
	@echo "  all            Run all playbooks"
	@echo "  check          Dry-run all playbooks (--check --diff)"
	@echo ""
	@echo "Setup:"
	@echo "  setup          Run full setup playbook"
	@echo "  hardening      Run hardening role (fail2ban)"
	@echo "  docker         Run Docker role"
	@echo "  networks       Run Networks role"
	@echo "  monitoring     Run monitoring stack (prometheus + grafana)"
	@echo ""
	@echo "Services:"
	@echo "  services       Run all services (traefik, jenkins)"
	@echo "  traefik        Run Traefik only"
	@echo "  jenkins        Run Jenkins only"
	@echo ""
	@echo "Apps:"
	@echo "  apps           Run all apps"
	@echo "  portfolio      Run Portfolio only"
	@echo "  ipseis         Run Ipseis only"
	@echo ""
	@echo "Databases:"
	@echo "  databases      Run all databases"
	@echo "  mongo          Run Mongo only"
	@echo ""
	@echo "Utils:"
	@echo "  install-deps   Install Ansible collections"
	@echo "  ping           Test SSH connection"
	@echo "  vault-edit     Edit encrypted vault"
	@echo "  help           Show this help"

.DEFAULT_GOAL := help
.PHONY: all setup hardening docker networks monitoring services traefik jenkins apps portfolio ipseis databases mongo install-deps ping check vault-edit help
