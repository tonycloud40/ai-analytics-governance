-- Runs once, on first container start against an empty data volume, as
-- the cluster superuser (POSTGRES_USER). Its only job is to prepare the
-- role that will own everything the Sakila POC creates.
--
-- mastersql is a schema/application owner, NOT a second cluster admin:
-- it is scoped to LOGIN only (no SUPERUSER / CREATEDB / CREATEROLE).
-- All administrative work (creating roles, running these init scripts,
-- managing the cluster) stays with POSTGRES_USER.
--
-- The "sakila" database itself is created for us by the Postgres
-- entrypoint (POSTGRES_DB=sakila in .env), owned by POSTGRES_USER by
-- default -- so we just hand ownership to mastersql here.
CREATE ROLE mastersql WITH
	LOGIN
	NOSUPERUSER
	NOCREATEDB
	NOCREATEROLE
	INHERIT
	NOREPLICATION
	CONNECTION LIMIT -1
	PASSWORD 'changeme';

ALTER DATABASE sakila OWNER TO mastersql;
