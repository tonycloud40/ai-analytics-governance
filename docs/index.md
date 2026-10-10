# AI Analytics Governance

A portable analytics platform built step by step: PostgreSQL as the warehouse, dbt for the transformations, and Docker to run both the same way on any machine.

The first milestone is a Kimball-style data warehouse on top of the Sakila sample database.

## Open the tools

These buttons open the tools running on your own machine. Start the Postgres stack first with `make postgres-up`.

[pgAdmin](http://localhost:15433){ .md-button .md-button--primary target=_blank }
[dbt docs](http://localhost:8080){ .md-button target=_blank }
[All local tools](local-tools.md){ .md-button }

The dbt docs button has nothing to open until the dbt stack is added.

## Goals

- **Decoupled:** ingestion, transformation and consumption are separate layers, from the sources through to a decision-support application.
- **Change-aware:** a change in a source flows through the layers instead of breaking them.
- **Portable:** start on a laptop, move on-premises, then to the cloud, without a redesign. The design should also carry over to other warehouse engines.

## Status

| Piece | State |
|---|---|
| Postgres and pgAdmin stack, with Sakila loaded | Working |
| Documentation site (this site) | Working |
| dbt stack | Next |
| Kimball models on Sakila | Planned |

## Getting started

```bash
git clone https://github.com/tonycloud40/ai-analytics-governance.git
cd ai-analytics-governance
cp docker/postgres/.env.example docker/postgres/.env    # then change the passwords
make postgres-up
make docs-serve
```

`make help` lists every command.
