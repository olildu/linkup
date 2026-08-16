import argparse
import os

import psycopg2
from dotenv import load_dotenv

from add_data import SEED_EMAIL_DOMAIN, SEED_RECORD_FILE

# Prod DB host/port/name/user live here (gitignored). Password is never stored
# on disk — it must be passed with --db-password every run.
load_dotenv(os.path.join(os.path.dirname(__file__), ".env.prod"))
PROD_DB_HOST = os.environ.get("DATABASE_HOST")
PROD_DB_PORT = os.environ.get("DATABASE_PORT")
PROD_DB_NAME = os.environ.get("DATABASE_NAME")
PROD_DB_USER = os.environ.get("DATABASE_USER")


def main():
    parser = argparse.ArgumentParser(
        description="Hard-delete all seed profiles created by add_data.py (matched by tagged email domain)."
    )
    parser.add_argument(
        "--domain",
        default=SEED_EMAIL_DOMAIN,
        help=f"Seed email domain to match (default: {SEED_EMAIL_DOMAIN})",
    )
    parser.add_argument("--yes", action="store_true", help="Skip the confirmation prompt")
    parser.add_argument("--db-host", default=PROD_DB_HOST, help="Postgres host (default: from .env.prod)")
    parser.add_argument("--db-port", default=PROD_DB_PORT, help="Postgres port (default: from .env.prod)")
    parser.add_argument("--db-name", default=PROD_DB_NAME, help="Postgres database name (default: from .env.prod)")
    parser.add_argument("--db-user", default=PROD_DB_USER, help="Postgres user (default: from .env.prod)")
    parser.add_argument("--db-password", required=True, help="Postgres password (never stored on disk)")
    args = parser.parse_args()

    like_pattern = f"%@{args.domain}"

    conn = psycopg2.connect(
        host=args.db_host,
        database=args.db_name,
        user=args.db_user,
        password=args.db_password,
        port=args.db_port,
    )
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT id, email FROM users WHERE email LIKE %s;", (like_pattern,))
        rows = cursor.fetchall()

        if not rows:
            print(f"No seed profiles found matching '{like_pattern}'. Nothing to do.")
            return

        print(f"Found {len(rows)} seed profile(s) matching '{like_pattern}':")
        for user_id, email in rows:
            print(f"  id={user_id} email={email}")

        if not args.yes:
            confirm = input(f"Hard-delete these {len(rows)} user(s) and all related data? [y/N] ").strip().lower()
            if confirm != "y":
                print("Aborted.")
                return

        cursor.execute("DELETE FROM users WHERE email LIKE %s;", (like_pattern,))
        conn.commit()
        print(f"\nDeleted {cursor.rowcount} user(s). Related user_preferences/user_metadata rows cascaded.")
    except psycopg2.Error as e:
        conn.rollback()
        print(f"[ERROR] {e}")
        raise
    finally:
        cursor.close()
        conn.close()

    if os.path.exists(SEED_RECORD_FILE):
        os.remove(SEED_RECORD_FILE)
        print(f"Cleared {SEED_RECORD_FILE}.")


if __name__ == "__main__":
    main()
