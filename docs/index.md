# AI Analytics Governance

A portable analytics platform built step by step: PostgreSQL as the warehouse, dbt for the transformations, and Docker to run both the same way on any machine.

The first milestone is a Kimball-style data warehouse on top of the Sakila sample database.

## Open the tools

These buttons open the tools running on your own machine. Start the stacks first with `make up`.

[pgAdmin](http://localhost:15433){ .md-button .md-button--primary target=_blank }
[dbt docs](http://localhost:8080){ .md-button target=_blank }
[All local tools](local-tools.md){ .md-button }

The dbt docs button works while `make dbt-docs` is running.

## Goals

- **Decoupled:** ingestion, transformation and consumption are separate layers, from the sources through to a decision-support application.
- **Change-aware:** a change in a source flows through the layers instead of breaking them.
- **Portable:** start on a laptop, move on-premises, then to the cloud, without a redesign. The design should also carry over to other warehouse engines.

## Status

| Piece | State |
|---|---|
| Postgres and pgAdmin stack, with Sakila loaded | Working |
| dbt stack, connected to Postgres | Working |
| dbt project, scaffolded | Working |
| Documentation site (this site) | Working |
| Git workflow through `make` | Working |
| Staging layer on Sakila | Next |
| Kimball models (dimensions and facts) | Planned |

## Getting started

```bash
git clone https://github.com/tonycloud40/ai-analytics-governance.git
cd ai-analytics-governance

# Settings: copy the templates, then change the passwords in the Postgres one
cp docker/postgres/.env.example docker/postgres/.env
cp docker/dbt/.env.example docker/dbt/.env

make up            # Postgres and pgAdmin, then dbt
make dbt-debug     # ends with "All checks passed!"
make docs-install
make docs-serve    # this site
```

The first `make up` loads Sakila, which takes a few minutes. Later starts take seconds.

`make help` lists every command. The [architecture](architecture.md) page shows how the pieces fit, and the [workflow](workflow.md) page shows how changes are made.
