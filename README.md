# AI Analytics Governance

A portable analytics platform built step by step: PostgreSQL as the warehouse, dbt for the transformations, and Docker to run both the same way on any machine.

The first milestone is a Kimball-style data warehouse on top of the Sakila sample database.

## Goals

- **Decoupled:** ingestion, transformation and consumption are separate layers, from the sources through to a decision-support application.
- **Change-aware:** a change in a source flows through the layers instead of breaking them.
- **Portable:** start on a laptop, move on-premises, then to the cloud, without a redesign. The design should also carry over to other warehouse engines.

## Status

Early setup. The Python package and the Makefile are in place. The Docker stacks (Postgres with pgAdmin, and dbt) are the next step, so the `make` targets below will not run until they are added.

## Stack

| Layer | Tool |
|---|---|
| Warehouse | PostgreSQL |
| Transformations | dbt |
| Runtime | Docker Compose |
| Python packaging | Poetry |
| Task runner | GNU Make |

## Getting started

Prerequisites: Docker with the Compose plugin, GNU Make, Python 3.14 or newer, and Poetry.

```bash
git clone https://github.com/tonycloud40/ai-analytics-governance.git
cd ai-analytics-governance
make help
```

`make help` lists every target. The main ones:

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
├── Makefile                      # Docker and dbt commands
├── pyproject.toml                # Python package definition (Poetry)
├── src/ai_analytics_governance/  # Python package
├── tests/                        # Tests
└── docker/                       # Postgres and dbt stacks (next step)
```

## Build log

The steps taken to create this project, in order.

1. Create the project with Poetry.

   ```bash
   poetry new ai-analytics-governance
   ```
