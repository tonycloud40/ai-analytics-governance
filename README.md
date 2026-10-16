# AI Analytics Governance

![Status](https://img.shields.io/badge/status-in%20development-orange)
![Python](https://img.shields.io/badge/python-3.14%2B-3776AB?logo=python&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?logo=postgresql&logoColor=white)
![dbt](https://img.shields.io/badge/dbt-FF694B?logo=dbt&logoColor=white)
![Docker Compose](https://img.shields.io/badge/Docker%20Compose-2496ED?logo=docker&logoColor=white)
![Poetry](https://img.shields.io/badge/Poetry-60A5FA?logo=poetry&logoColor=white)
![Docs](https://img.shields.io/badge/docs-MkDocs%20Material-526CFE?logo=materialformkdocs&logoColor=white)
![Last commit](https://img.shields.io/github/last-commit/tonycloud40/ai-analytics-governance)

A portable analytics platform built step by step: PostgreSQL as the warehouse, dbt for the transformations, and Docker to run both the same way on any machine.

The first milestone is a Kimball-style data warehouse on top of the Sakila sample database.

## Goals

- **Decoupled:** ingestion, transformation and consumption are separate layers, from the sources through to a decision-support application.
- **Change-aware:** a change in a source flows through the layers instead of breaking them.
- **Portable:** start on a laptop, move on-premises, then to the cloud, without a redesign. The design should also carry over to other warehouse engines.

## Status

| Piece | State |
|---|---|
| Postgres and pgAdmin stack, with the Sakila sample database loaded | Working |
| Documentation site (MkDocs) | Working |
| dbt stack | Next |
| Kimball models on Sakila | Planned |

The `make dbt-*` targets and `make up` need the dbt stack, so they will not run until it is added.

## Stack

| Layer | Tool |
|---|---|
| Warehouse | PostgreSQL |
| Database admin | pgAdmin |
| Sample data | Sakila |
| Transformations | dbt |
| Runtime | Docker Compose |
| Documentation site | MkDocs with the Material theme |
| Python packaging | Poetry |
| Task runner | GNU Make |

## Getting started

Prerequisites: Docker with the Compose plugin, GNU Make, Python 3.14 or newer, and Poetry.

```bash
git clone https://github.com/tonycloud40/ai-analytics-governance.git
cd ai-analytics-governance

# 1. Settings for the Postgres stack: copy the template, then change the passwords
cp docker/postgres/.env.example docker/postgres/.env

# 2. Start Postgres and pgAdmin
make postgres-up

# 3. Open the project documentation in the browser
make docs-install
make docs-serve
```

The first `make postgres-up` loads the Sakila sample database, which takes a few minutes. Later starts take seconds. To confirm the data is in:

```bash
docker exec app_postgres psql -U postgres -d sakila -c "select count(*) from sakila_tb.film;"
```

It returns 1000 when the load is complete.

## Local tools

Once the stacks are running, each tool answers on your own machine:

| Tool | Address | Start it with |
|---|---|---|
| Documentation site | http://localhost:8000 | `make docs-serve` |
| pgAdmin | http://localhost:15433 | `make postgres-up` |
| PostgreSQL | `localhost:15432`, database `sakila` | `make postgres-up` |
| dbt docs | http://localhost:8080 | `make dbt-docs` (after the dbt stack is added) |

The documentation site is the front door: its top menu links to pgAdmin and to the dbt docs.

## Commands

`make help` lists every target. The main ones:

| Command | What it does |
|---|---|
| `make postgres-up` | Start Postgres and pgAdmin, and wait until Postgres is ready |
| `make postgres-down` | Stop Postgres and pgAdmin |
| `make postgres-ps` | Show the status of the Postgres stack |
| `make postgres-logs` | Follow the Postgres and pgAdmin logs |
| `make docs-serve` | Open the documentation site and reload it on every save |
| `make docs-build` | Build the static site into `site/` and fail on broken links |
| `make reset` | Stop everything and delete the data volumes (asks first) |

These need the dbt stack:

| Command | What it does |
|---|---|
| `make up` | Start Postgres, then dbt |
| `make dbt-init` | Scaffold the dbt project |
| `make dbt-build` | Run and test all models, in dependency order |
| `make dbt-run DBT_ARGS="--select <model>"` | Run selected models only |
| `make dbt-docs` | Generate the dbt docs and serve them |
| `make down` | Stop dbt, then Postgres |

## Project layout

```text
.
├── Makefile                      # Docker, dbt and documentation commands
├── mkdocs.yml                    # Documentation site settings and menu
├── pyproject.toml                # Python package and dependency groups (Poetry)
├── poetry.lock                   # Exact versions of every dependency
├── docs/                         # Pages of the documentation site
│   ├── index.md                  # Home page
│   └── local-tools.md            # Addresses of the local tools
├── docker/
│   ├── postgres/                 # Postgres and pgAdmin stack
│   │   ├── docker-compose.yml
│   │   ├── .env.example          # Template for .env, which git ignores
│   │   ├── docker_postgres_init.sql
│   │   └── docker_pgadmin_servers.json
│   ├── metadata/Sakila/          # Sakila schema and data, loaded on first start
│   └── dbt/                      # dbt runtime: compose file, Dockerfile, profiles.yml
├── dbt/
│   └── ai_analytics_governance/  # dbt project: models, seeds, tests, macros
├── src/ai_analytics_governance/  # Python package
└── tests/                        # Tests
```

## How changes are made

Work happens on a branch and reaches `main` through a pull request. Planned work is tracked as GitHub issues.

## Build log

The steps taken to create this project, in order.

1. Create the project with Poetry.

   ```bash
   poetry new ai-analytics-governance
   ```

2. Add the ignore list and the Makefile, then publish the repository on GitHub.

3. Add the Postgres and pgAdmin stack, with the Sakila sample database loaded on the first start.

   ```bash
   cp docker/postgres/.env.example docker/postgres/.env
   make postgres-up
   ```

4. Add the documentation site with MkDocs and the Material theme.

   ```bash
   poetry add --group docs mkdocs-material
   poetry run mkdocs new .
   ```

5. Add `make` targets for the documentation site.

   ```bash
   make docs-serve
   ```

6. Make the documentation site the project home, with a menu that opens pgAdmin and the dbt docs.
