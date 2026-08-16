"""
Applies pending SQL migrations from migrations/ to the database.

schema.sql is only ever read by Postgres on first container init (empty
volume) - it does nothing for a DB that already exists. This script is what
keeps an existing dev/prod database in sync with schema.sql changes: every
time you add something to schema.sql, also drop a numbered file in
migrations/ with the same change, and this script will apply it exactly
once, in order, tracked in the schema_migrations table.

Usage: python migrate.py
"""

import os
import sys
from pathlib import Path

import psycopg2

from app.constants.db_constants import DB_HOST, DB_NAME, DB_PASSWORD, DB_PORT, DB_USER

MIGRATIONS_DIR = Path(__file__).parent / "migrations"


def main():
    migration_files = sorted(MIGRATIONS_DIR.glob("*.sql"))
    if not migration_files:
        print("No migration files found.")
        return

    conn = psycopg2.connect(
        host=DB_HOST, database=DB_NAME, user=DB_USER, password=DB_PASSWORD, port=DB_PORT
    )
    conn.autocommit = False
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                CREATE TABLE IF NOT EXISTS schema_migrations (
                    filename VARCHAR PRIMARY KEY,
                    applied_at TIMESTAMP NOT NULL DEFAULT NOW()
                )
                """
            )
            conn.commit()

            cur.execute("SELECT filename FROM schema_migrations")
            already_applied = {row[0] for row in cur.fetchall()}

        for path in migration_files:
            if path.name in already_applied:
                continue
            print(f"Applying migration: {path.name}")
            sql = path.read_text()
            with conn.cursor() as cur:
                cur.execute(sql)
                cur.execute(
                    "INSERT INTO schema_migrations (filename) VALUES (%s)", (path.name,)
                )
            conn.commit()
        print("Migrations up to date.")
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()


if __name__ == "__main__":
    sys.exit(main())
