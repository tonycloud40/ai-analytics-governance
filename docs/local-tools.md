# Local tools

The project runs its tools in Docker. This page lists where each one answers on your machine and how to start it.

!!! note "These links are local"
    The addresses below point at `localhost`, so they only work on the computer where the stacks are running. On a published copy of this site they lead nowhere.

| Tool | Address | Start it with | Sign-in |
|---|---|---|---|
| pgAdmin | [http://localhost:15433](http://localhost:15433){ target=_blank } | `make postgres-up` | None: server mode is off in `.env` |
| PostgreSQL | `localhost:15432`, database `sakila` | `make postgres-up` | `POSTGRES_USER` and `POSTGRES_PASSWORD` from `docker/postgres/.env` |
| dbt | runs inside the container `app_dbt` | `make dbt-up`, then `make dbt-shell` for a terminal | Uses the Postgres credentials |
| dbt docs | [http://localhost:8080](http://localhost:8080){ target=_blank } | `make dbt-docs` | None |
| This site | [http://localhost:8000](http://localhost:8000) | `make docs-serve` | None |

## Notes

- **Ports are settings.** pgAdmin and PostgreSQL take theirs from `docker/postgres/.env`, the dbt docs port is `DBT_DOCS_PORT` in `docker/dbt/.env`, and this site uses `DOCS_PORT` in the Makefile. If you change one, update the links in `mkdocs.yml` and on this page.
- **dbt docs run in the foreground.** `make dbt-docs` builds the docs and serves them until you press Ctrl+C.
- **pgAdmin already knows the server.** It is listed as "Docker Compose" under Servers.
- **The first start is slow.** Loading Sakila takes a few minutes the first time. Later starts take seconds.
