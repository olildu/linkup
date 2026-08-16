"""Covers /internal/status."""
import pytest

import app.core.status_endpoints as status_module
from app.core.constants.global_constants import STATUS_PAGE_TOKEN
from app.core.controllers.db_controller import db_pool
from app.core.controllers.redis_controller import redis_client

STATUS = "/api/v1/internal/status"


def test_status_with_valid_token(client):
    resp = client.get(STATUS, headers={"X-Status-Token": STATUS_PAGE_TOKEN})

    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["status"] == "ok"
    assert body["database"] == "ok"
    assert body["redis"] == "ok"
    assert "uptime_seconds" in body
    assert "recent_logs" in body


def test_status_missing_token_401(client):
    resp = client.get(STATUS)
    assert resp.status_code == 401


def test_status_wrong_token_401(client):
    resp = client.get(STATUS, headers={"X-Status-Token": "definitely-wrong-token"})
    assert resp.status_code == 401


def test_status_reports_database_error(client, monkeypatch):
    # _check_database's `conn = db_pool.getconn()` call sits *before* its own
    # try/except, so a failure there isn't gracefully caught (see the next
    # test) - the try/except only covers query execution after a connection
    # was already obtained. Simulate that by returning a connection whose
    # cursor blows up instead.
    class FailingCursor:
        def execute(self, *a, **kw):
            raise RuntimeError("simulated query failure")

        def close(self):
            pass

    class FakeConn:
        def cursor(self):
            return FailingCursor()

    monkeypatch.setattr(db_pool, "getconn", lambda: FakeConn())
    monkeypatch.setattr(db_pool, "putconn", lambda conn: None)

    resp = client.get(STATUS, headers={"X-Status-Token": STATUS_PAGE_TOKEN})

    assert resp.status_code == 200, resp.text
    assert resp.json()["database"] == "error"


def test_status_getconn_failure_is_not_caught(client, monkeypatch):
    # Documents an existing bug: unlike a query failure, a failure in
    # db_pool.getconn() itself happens outside _check_database's try/except,
    # so the exception propagates uncaught (TestClient re-raises it directly
    # rather than turning it into a 500 response) instead of the endpoint
    # gracefully reporting "database": "error".
    def _raise():
        raise RuntimeError("simulated pool exhaustion")

    monkeypatch.setattr(db_pool, "getconn", _raise)

    with pytest.raises(RuntimeError):
        client.get(STATUS, headers={"X-Status-Token": STATUS_PAGE_TOKEN})


def test_status_reports_redis_error(client, monkeypatch):
    monkeypatch.setattr(redis_client, "ping", lambda: (_ for _ in ()).throw(RuntimeError("simulated redis outage")))

    resp = client.get(STATUS, headers={"X-Status-Token": STATUS_PAGE_TOKEN})

    assert resp.status_code == 200, resp.text
    assert resp.json()["redis"] == "error"


def test_status_recent_logs_empty_when_log_file_missing(client, monkeypatch):
    monkeypatch.setattr(status_module, "LOG_FILE_PATH", "/tmp/definitely-does-not-exist.log")

    resp = client.get(STATUS, headers={"X-Status-Token": STATUS_PAGE_TOKEN})

    assert resp.status_code == 200, resp.text
    assert resp.json()["recent_logs"] == []
