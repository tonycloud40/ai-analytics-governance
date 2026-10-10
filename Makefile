##@ -----------------------------------------------------------------------------
##@     ___    ____   ______
##@    /   |  /  _/  / ____/___ _   _____  _________  ____ _____  _________
##@   / /| |  / /   / / __/ __ \ | / / _ \/ ___/ __ \/ __ `/ __ \/ ___/ _  /
##@  / ___ |_/ /   / /_/ / /_/ / |/ /  __/ /  / / / / /_/ / / / / /__/  __/
##@ /_/  |_/___/   \____/\____/|___/\___/_/  /_/ /_/\__,_/_/ /_/\___/\___/
##@
##@ AI Analytics Governance -- docker orchestration (postgres + dbt)
##@ -----------------------------------------------------------------------------

SHELL := /bin/bash
.DEFAULT_GOAL := help

DOCKER_DIR       := docker
POSTGRES_COMPOSE := $(DOCKER_DIR)/postgres/docker-compose.yml
DBT_COMPOSE      := $(DOCKER_DIR)/dbt/docker-compose.yml

# Project name used by the dbt targets. Matches the profile name defined in
# docker/dbt/profiles.yml, so the generated dbt_project.yml's `profile:` line works
# with no manual edit. Override per call, e.g.:
#   make dbt-init PROJECT_NAME=my_project
PROJECT_NAME ?= ai_analytics_governance


# dbt-specific settings (port, paths, names) live in docker/dbt/.env -- the single
# source of truth also read by docker compose for ${VAR} substitution. This
# keeps `make dbt-docs-serve` and the container's published port in sync.
-include $(DOCKER_DIR)/dbt/.env

# Fallback only if docker/dbt/.env is missing or doesn't define it.
DBT_DOCS_PORT ?= 8080

DBT_EXEC := docker compose -f $(DBT_COMPOSE) exec -w /workspace/$(PROJECT_NAME) dbt

# Extra flags for any dbt command, e.g.:
#   make dbt-run DBT_ARGS="--select stg_sakila__customers"
DBT_ARGS ?=

# Where the dbt project lives on the host (checked by require-project).
DBT_PROJECT_DIR := $(DOCKER_DIR)/dbt/$(PROJECT_NAME)

# Port for the MkDocs preview. Different from DBT_DOCS_PORT, so the project
# site and the dbt docs can be open at the same time.
DOCS_PORT ?= 8000

# Runs MkDocs from the Poetry environment. NO_MKDOCS_2_WARNING hides the
# notice that Material for MkDocs prints about MkDocs 2.0 on every build.
MKDOCS := NO_MKDOCS_2_WARNING=1 poetry run mkdocs

.PHONY: help \
        postgres-up postgres-down postgres-logs postgres-ps \
        dbt-image dbt-up dbt-down dbt-logs dbt-shell dbt-ps \
        dbt-init require-project dbt-deps dbt-seed \
        dbt-debug dbt-build dbt-run dbt-test \
        dbt-docs-generate dbt-docs-serve dbt-docs \
        docs-install docs-serve docs-build \
        up down ps logs reset

# Help is generated from this file: a `##` comment on a target line is its
# description, and `##@` lines are section headers. Descriptions can't drift
# from the targets because they sit on the same line.
help:
	@awk 'BEGIN { FS = ":.*##"; \
					CYAN = "\033[36m"; \
					GREEN = "\033[32m"; \
					YELLOW = "\033[33m"; \
					NORMAL = "\033[0m"; \
	              printf "\n Usage:\n  make " CYAN "<target>" NORMAL "\n" } \
	     /^[a-zA-Z_-]+:.*##/ { printf "   " CYAN "%-20s" NORMAL " " GREEN "%s" NORMAL "\n", $$1, $$2 } \
	     /^##@/              { printf " " YELLOW "%s" NORMAL "\n", substr($$0, 5) }' $(MAKEFILE_LIST)
	@echo ""
	@echo " Current settings: PROJECT_NAME=$(PROJECT_NAME)  DBT_DOCS_PORT=$(DBT_DOCS_PORT)"
	@echo ""

##@ Postgres stack
postgres-up: ## Start postgres + pgAdmin
	docker compose -f $(POSTGRES_COMPOSE) up -d --wait

postgres-down: ## Stop postgres + pgAdmin
	docker compose -f $(POSTGRES_COMPOSE) down

postgres-logs: ## Tail postgres + pgAdmin logs
	docker compose -f $(POSTGRES_COMPOSE) logs -f

postgres-ps: ## Show postgres stack status
	docker compose -f $(POSTGRES_COMPOSE) ps

##@
##@ dbt stack
##@   Postgres must be up (on the shared ai-governance-net network) before dbt
##@   can resolve the "postgres" hostname, so dbt-up depends on postgres-up.
dbt-image: ## Build (or rebuild) the dbt Docker image
	docker compose -f $(DBT_COMPOSE) build

dbt-up: postgres-up ## Start postgres, then start dbt (builds the image only if missing)
	docker compose -f $(DBT_COMPOSE) up -d

dbt-down: ## Stop the dbt container
	docker compose -f $(DBT_COMPOSE) down

dbt-logs: ## Tail dbt logs
	docker compose -f $(DBT_COMPOSE) logs -f

dbt-shell: dbt-up ## Open a bash shell in the dbt container
	docker compose -f $(DBT_COMPOSE) exec dbt bash

dbt-ps: ## Show dbt container status
	docker compose -f $(DBT_COMPOSE) ps

##@
##@ dbt project lifecycle            (all accept PROJECT_NAME=x)
##@   dbt-init uses --skip-profile-setup: docker/dbt/profiles.yml (bind-mounted to
##@   /root/.dbt/profiles.yml) already defines the connection.
dbt-init: dbt-up ## Scaffold a new project via 'dbt init'
	docker compose -f $(DBT_COMPOSE) exec dbt dbt init $(PROJECT_NAME) --skip-profile-setup
	@echo ""
	@echo "Project scaffolded at docker/dbt/$(PROJECT_NAME) (it lands on the host"
	@echo "because /workspace is bind-mounted to docker/dbt)."
	@echo "Its dbt_project.yml defaults to 'profile: $(PROJECT_NAME)' -- since that"
	@echo "matches the profile name in docker/dbt/profiles.yml, no edit is needed."
	@echo "Next: make dbt-debug PROJECT_NAME=$(PROJECT_NAME)"

# Not listed in help (no ## description): fails early with a clear message
# when the dbt project hasn't been scaffolded yet.
require-project:
	@test -f $(DBT_PROJECT_DIR)/dbt_project.yml || \
	 { echo "No dbt project at $(DBT_PROJECT_DIR). Run: make dbt-init"; exit 1; }

dbt-deps: require-project dbt-up ## Run 'dbt deps' (install packages from packages.yml)
	$(DBT_EXEC) dbt deps

dbt-seed: require-project dbt-up ## Run 'dbt seed' (load CSVs from seeds/)
	$(DBT_EXEC) dbt seed $(DBT_ARGS)

dbt-debug: require-project dbt-up ## Run 'dbt debug' (checks the connection to Postgres)
	$(DBT_EXEC) dbt debug $(DBT_ARGS)

dbt-build: require-project dbt-up ## Run 'dbt build' (run + test, in dependency order)
	$(DBT_EXEC) dbt build $(DBT_ARGS)

dbt-run: require-project dbt-up ## Run 'dbt run'
	$(DBT_EXEC) dbt run $(DBT_ARGS)

dbt-test: require-project dbt-up ## Run 'dbt test'
	$(DBT_EXEC) dbt test $(DBT_ARGS)

dbt-docs-generate: require-project dbt-up ## Run 'dbt docs generate'
	$(DBT_EXEC) dbt docs generate

# Blocks in the foreground since dbt docs serve is a long-running webserver --
# Ctrl+C stops it. --host 0.0.0.0 is required for the port mapping in
# docker/dbt/docker-compose.yml to reach it from the host.
dbt-docs-serve: require-project dbt-up ## Serve dbt docs on DBT_DOCS_PORT (blocks; Ctrl+C to stop)
	$(DBT_EXEC) dbt docs serve --port $(DBT_DOCS_PORT) --host 0.0.0.0

dbt-docs: dbt-docs-generate dbt-docs-serve ## Generate docs, then serve them

##@
##@ Project documentation site (MkDocs)     (accepts DOCS_PORT=x)
##@   This is the project's own site, built from docs/ and mkdocs.yml.
##@   The dbt-docs targets above are a different site: the dbt models.
docs-install: ## Install the documentation tools into the Poetry environment
	poetry install --with docs

# Blocks in the foreground: mkdocs serve is a long-running webserver that
# rebuilds the page on every save. --open starts the browser when the first
# build is done. Ctrl+C stops it.
docs-serve: ## Open the docs site in the browser and reload on every save (blocks; Ctrl+C to stop)
	$(MKDOCS) serve --dev-addr 127.0.0.1:$(DOCS_PORT) --open

docs-build: ## Build the static site into site/ (--strict fails on broken links)
	$(MKDOCS) build --strict

##@
##@ Combined
up: dbt-up ## Start postgres, then dbt

down: dbt-down postgres-down ## Stop dbt, then postgres

ps: postgres-ps dbt-ps ## Status of both stacks

logs: ## Tail both stacks' logs together
	@$(MAKE) --no-print-directory postgres-logs & \
	 $(MAKE) --no-print-directory dbt-logs & \
	 wait

reset: ## Tear down both stacks AND delete volumes (asks first; destroys data)
	@read -r -p "This deletes ALL data in both stacks. Type 'yes' to continue: " ans; \
	 [ "$$ans" = "yes" ] || { echo "Aborted."; exit 1; }
	docker compose -f $(DBT_COMPOSE) down -v
	docker compose -f $(POSTGRES_COMPOSE) down -v
