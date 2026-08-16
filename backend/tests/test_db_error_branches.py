"""Forces the sync `db_pool` (app.core.controllers.db_controller.db_pool) to fail
on every query, to exercise the except-branches that catch psycopg2.Error /
generic DB failures across route handlers. These branches can't be reached
through normal request flows - only by breaking the DB mid-request.
"""
import uuid

import psycopg2
import pytest
from fastapi import HTTPException

from app.core.controllers.db_controller import db_pool
from app.core.token_utilities import create_email_token
from app.features.user.user_db_utilities import get_user_from_db

REPORT = "/api/v1/user/report"
DELETE = "/api/v1/user/delete"
BLOCK = "/api/v1/user/block"
GET_DETAIL = "/api/v1/user/get/detail/{}"
GET_PREFERENCES = "/api/v1/user/get/preferences"
UPDATE_METADATA = "/api/v1/user/update/metadata"
UPDATE_PREFERENCES = "/api/v1/user/update/preferences"
REGISTER = "/api/v1/register"
TOKEN = "/api/v1/token"
GET_MATCHES = "/api/v1/matches/get-matches"
GET_CONNECTIONS = "/api/v1/matches/get-connections"
SWIPE_RIGHT = "/api/v1/swipe/right"


class FakeCursor:
    def execute(self, *args, **kwargs):
        raise psycopg2.Error("simulated db failure")

    def fetchone(self):
        raise psycopg2.Error("simulated db failure")

    def fetchall(self):
        raise psycopg2.Error("simulated db failure")

    def close(self):
        pass

    def __enter__(self):
        return self

    def __exit__(self, *args):
        return False


class FakeConn:
    def cursor(self):
        return FakeCursor()

    def commit(self):
        pass

    def rollback(self):
        pass

    def close(self):
        pass


@pytest.fixture
def broken_db(monkeypatch):
    """Makes every query issued through the sync db_pool raise psycopg2.Error."""
    monkeypatch.setattr(db_pool, "getconn", lambda: FakeConn())
    monkeypatch.setattr(db_pool, "putconn", lambda conn: None)


def test_report_user_db_error_500(client, make_user, auth_header, broken_db):
    user_id = make_user()
    resp = client.post(
        REPORT, json={"reported_user_id": 1, "reason": "x"}, headers=auth_header(user_id)
    )
    assert resp.status_code == 500


def test_delete_account_db_error_500(client, make_user, auth_header, broken_db):
    user_id = make_user()
    resp = client.delete(DELETE, headers=auth_header(user_id))
    assert resp.status_code == 500


def test_block_user_db_error_500(client, make_user, auth_header, broken_db):
    user_id = make_user()
    resp = client.post(BLOCK, json={"blocked_user_id": 1}, headers=auth_header(user_id))
    assert resp.status_code == 500


def test_get_detail_self_db_error_500(client, make_user, auth_header, broken_db):
    user_id = make_user()
    resp = client.get(GET_DETAIL.format(user_id), headers=auth_header(user_id))
    assert resp.status_code == 500


def test_get_preferences_db_error_500(client, make_user, auth_header, broken_db):
    user_id = make_user()
    resp = client.get(GET_PREFERENCES, headers=auth_header(user_id))
    assert resp.status_code == 500


def test_update_metadata_db_error_500(client, make_user, auth_header, broken_db):
    user_id = make_user()
    resp = client.post(UPDATE_METADATA, json={"about": "x"}, headers=auth_header(user_id))
    assert resp.status_code == 500


def test_update_preferences_db_error_500(client, make_user, auth_header, broken_db):
    user_id = make_user()
    resp = client.post(
        UPDATE_PREFERENCES, json={"interested_gender": "Male"}, headers=auth_header(user_id)
    )
    assert resp.status_code == 500


def test_register_db_error_500(client, make_user, auth_header, broken_db):
    user_id = make_user()
    payload = {
        "username": f"user_{uuid.uuid4().hex[:8]}",
        "university_year": 2,
        "profile_picture": {"file_key": "sw/profile_pictures/1/pfp.webp"},
        "gender": "Male",
        "dob": "2000-01-01",
        "interested_gender": "Female",
        "university_major": "BTech",
        "photos": [{"file_key": "sw/media/1/a.webp"}, {"file_key": "sw/media/1/b.webp"}],
        "about": "test bio",
        "currently_staying": "Campus Hostel",
        "hometown": "Testville",
    }
    resp = client.post(REGISTER, json=payload, headers=auth_header(user_id))
    assert resp.status_code == 500


def test_login_db_error_500(client, broken_db):
    resp = client.post(TOKEN, data={"username": "whoever@example.com", "password": "whatever"})
    assert resp.status_code == 500


def test_get_matches_db_error_500(client, make_user, auth_header, broken_db):
    user_id = make_user()
    resp = client.get(GET_MATCHES, headers=auth_header(user_id))
    assert resp.status_code == 500


def test_get_connections_db_error_500(client, make_user, auth_header, broken_db):
    user_id = make_user()
    resp = client.get(GET_CONNECTIONS, headers=auth_header(user_id))
    assert resp.status_code == 500


def test_swipe_right_db_error_500(client, make_user, auth_header, broken_db):
    # Exercises handle_db_errors' `except psycopg2.Error` branch directly
    # (assert_in_match_queue's cursor.execute fails before any business logic).
    user_id = make_user()
    resp = client.post(SWIPE_RIGHT, json={"liked_id": 1}, headers=auth_header(user_id))
    assert resp.status_code == 500


def test_get_user_from_db_requires_email_or_id():
    with pytest.raises(HTTPException) as exc_info:
        get_user_from_db()
    assert exc_info.value.status_code == 400


def test_update_metadata_token_missing_id_claim_401(client):
    # A well-formed, correctly-signed JWT that just doesn't carry an "id"
    # claim (e.g. an email-purpose token) - hits the `if not user_id:` guard
    # rather than the PyJWTError branch.
    token = create_email_token(subject="email_verification", email="x@example.com")
    resp = client.post(
        UPDATE_METADATA, json={"about": "x"}, headers={"Authorization": f"Bearer {token}"}
    )
    assert resp.status_code == 401
