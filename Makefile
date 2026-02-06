PLAYBOOK = ansible/playbook.yml
INVENTORY = ansible/inventory.yml
VAULT_PASS = ansible/.vault_pass # To add manually (git-ignored)
ANSIBLE_CMD = ansible-playbook $(PLAYBOOK) -i $(INVENTORY) --vault-password-file $(VAULT_PASS)

## Run all roles
all:
	$(ANSIBLE_CMD)

## Run hardening roles (fail2ban)
hardening:
	$(ANSIBLE_CMD) --tags hardening

## Run Docker roles (docker + networks)
docker:
	$(ANSIBLE_CMD) --tags docker

## Run service roles (traefik, jenkins)
services:
	$(ANSIBLE_CMD) --tags services

## Run Jenkins role only
jenkins:
	$(ANSIBLE_CMD) --tags jenkins

## Test SSH connection to the server
ping:
	ansible ovh-server -i $(INVENTORY) -m ping --vault-password-file $(VAULT_PASS)

## Show available commands
help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@echo "  all        Run all roles"
	@echo "  hardening  Run hardening roles (fail2ban)"
	@echo "  docker     Run Docker roles (docker + networks)"
	@echo "  services   Run service roles (traefik, jenkins)"
	@echo "  jenkins    Run Jenkins role only"
	@echo "  ping       Test SSH connection to the server"
	@echo "  help       Show this help message"

.DEFAULT_GOAL := help

.PHONY: all hardening docker services jenkins ping help
