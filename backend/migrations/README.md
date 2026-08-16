# Migrations

`schema.sql` is only executed by Postgres on first container init against an
**empty** volume — editing it has no effect on a database that already
exists. This folder is what actually keeps existing databases (local dev,
prod) in sync with it.

## Convention

Whenever you change `schema.sql`, also add a new file here:

```
migrations/000N_short_description.sql
```

- Number sequentially, one higher than the last file in this folder.
- Write the SQL idempotently (`ADD COLUMN IF NOT EXISTS`, `CREATE INDEX IF
  NOT EXISTS`, a `DO $$ ... IF NOT EXISTS ...` block for constraints) so it's
  always safe to run, even against a DB that already has the change.
- Don't edit old migration files once committed — add a new one instead.

## How it runs

`migrate.py` runs automatically on backend container startup (wired into
`command:` in `docker-compose.yml`, `docker-compose.override.yml`, and
`docker-compose.prod.yml`). It tracks applied filenames in a
`schema_migrations` table and only runs new ones.

To run it manually (e.g. against a container that's already up):

```
docker compose exec backend python migrate.py
```
