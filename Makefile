# Determine the repository root directory (one level up from this Makefile if it's in root, 
# or just current dir if we assume make is run from root)
# A robust way to get the directory where the Makefile resides:
REPO_ROOT := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

ENV_TYPE ?= local
COMPOSE_FILE_BASE := $(REPO_ROOT)/ci/docker-compose.yml
COMPOSE_FILE_OVERRIDE := $(REPO_ROOT)/ci/docker-compose.$(ENV_TYPE).yml
ENV_FILE := $(REPO_ROOT)/configs/$(ENV_TYPE).env

# Docker Compose command with files and env
DC := docker-compose -f $(COMPOSE_FILE_BASE) -f $(COMPOSE_FILE_OVERRIDE) --env-file $(ENV_FILE)

.PHONY: help up down logs pull restart clean-volumes ps setup-host-ssh

help:
	@echo "Home-Lab Infrastructure Management"
	@echo "Repository Root: $(REPO_ROOT)"
	@echo "Usage: make [target] ENV_TYPE=[local|prod|test]"
	@echo ""
	@echo "Targets:"
	@echo "  up            Start the infrastructure (detached)"
	@echo "  down          Stop the infrastructure"
	@echo "  restart       Restart the infrastructure"
	@echo "  logs          Follow logs (Ctrl+C to exit)"
	@echo "  pull          Pull latest images"
	@echo "  ps            List running containers"
	@echo "  clean-volumes Remove all data volumes (WARNING: DATA LOSS)"
	@echo "  setup-host-ssh Setup SSH access on the host machine"

up:
	@echo "Starting infrastructure in $(ENV_TYPE) mode..."
	$(DC) up -d --remove-orphans

down:
	@echo "Stopping infrastructure..."
	$(DC) down

restart: down up

logs:
	$(DC) logs -f

pull:
	$(DC) pull

ps:
	$(DC) ps

clean-volumes:
	@echo "WARNING: This will remove all data volumes for $(ENV_TYPE) environment."
	@read -p "Are you sure? [y/N] " confirm; \
	if [ "$$confirm" = "y" ]; then \
		$(DC) down -v; \
		echo "Volumes removed."; \
	else \
		echo "Aborted."; \
	fi

setup-host-ssh:
	@echo "Running SSH setup script..."
	@bash $(REPO_ROOT)/make/setup-ssh.sh
