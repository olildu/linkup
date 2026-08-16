import os
import time

from fastapi import APIRouter, Header, HTTPException

from app.constants.global_constants import STATUS_PAGE_TOKEN
from app.controllers.db_controller import db_pool
from app.controllers.redis_controller import redis_client

status_router = APIRouter()

LOG_FILE_PATH = "app.log"
LOG_TAIL_LINES = 200

# Captured when this module is first imported, i.e. at process startup.
_STARTED_AT = time.time()


def _check_database() -> str:
    conn = db_pool.getconn()
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT 1;")
        cursor.close()
        return "ok"
    except Exception:
        return "error"
    finally:
        db_pool.putconn(conn)


def _check_redis() -> str:
    try:
        redis_client.ping()
        return "ok"
    except Exception:
        return "error"


def _tail_log(path: str, num_lines: int) -> list[str]:
    if not os.path.exists(path):
        return []
    with open(path, "r", encoding="utf-8", errors="replace") as f:
        lines = f.readlines()
    return [line.rstrip("\n") for line in lines[-num_lines:]]


@status_router.get("/internal/status")
async def get_status(x_status_token: str = Header(default=None)):
    if not STATUS_PAGE_TOKEN or x_status_token != STATUS_PAGE_TOKEN:
        raise HTTPException(status_code=401, detail="Invalid or missing status token")

    return {
        "status": "ok",
        "version": os.environ.get("APP_VERSION", "unknown"),
        "uptime_seconds": int(time.time() - _STARTED_AT),
        "database": _check_database(),
        "redis": _check_redis(),
        "recent_logs": _tail_log(LOG_FILE_PATH, LOG_TAIL_LINES),
    }
