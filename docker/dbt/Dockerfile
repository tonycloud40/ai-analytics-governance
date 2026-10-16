# -----------------------------------------------------------------------------
# AI Analytics Governance: dbt runtime for PostgreSQL
# -----------------------------------------------------------------------------

FROM python:3.12-slim

LABEL maintainer="Itamar Tafarello"
LABEL application="AI Analytics Governance"
LABEL component="dbt-postgres"

# -----------------------------------------------------------------------------
# Environment
# -----------------------------------------------------------------------------

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    DEBIAN_FRONTEND=noninteractive

# -----------------------------------------------------------------------------
# System packages
# -----------------------------------------------------------------------------
# git is needed by "dbt deps" to fetch packages. psycopg2-binary, which
# dbt-postgres installs, brings its own libpq, so no database client is needed.
RUN apt-get update \
    && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# Python packages
# -----------------------------------------------------------------------------
# Pinned versions, so every build gets the same dbt.
RUN pip install \
    dbt-core==1.10.10 \
    dbt-postgres==1.10.2

# The repository's docker/dbt folder is mounted here (see docker-compose.yml).
WORKDIR /workspace

CMD ["sleep", "infinity"]
