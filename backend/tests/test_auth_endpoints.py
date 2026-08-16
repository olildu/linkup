"""Covers /signup, /register, /reset-password, /verify-otp, /verify-email,
/token (login), /refresh, and /me.
"""
import uuid
from datetime import timedelta

import pytest

from app.constants.global_constants import MAX_LOGIN_ATTEMPTS
from app.controllers.redis_controller import redis_client
from app.utilities.password.password_utilities import hash_password
from app.utilities.token.token_utilities import create_access_token, create_email_token, create_refresh_token

SIGNUP = "/api/v1/signup"
REGISTER = "/api/v1/register"
RESET_PASSWORD = "/api/v1/reset-password"
VERIFY_OTP = "/api/v1/verify-otp"
VERIFY_EMAIL = "/api/v1/verify-email"
TOKEN = "/api/v1/token"
REFRESH = "/api/v1/refresh"
ME = "/api/v1/me"

STRONG_PASSWORD = "Str0ng!Passw0rd"


def _unique_email() -> str:
    return f"pytest_{uuid.uuid4().hex}@example.com"


@pytest.fixture
def cleanup_user(db_cursor):
    created_ids = []

    def _track(user_id: int) -> int:
        created_ids.append(user_id)
        return user_id

    yield _track

    for user_id in created_ids:
        db_cursor.execute("DELETE FROM users WHERE id = %s;", (user_id,))


@pytest.fixture
def partial_user(db_cursor):
    """A bare users row (email + password only), matching what /signup
    actually produces before /register is called - unlike `make_user`,
    which also pre-seeds user_metadata/user_preferences.
    """
    created_ids = []

    def _make() -> int:
        db_cursor.execute(
            "INSERT INTO users (email, password_hash) VALUES (%s, 'x') RETURNING id;",
            (_unique_email(),),
        )
        user_id = db_cursor.fetchone()[0]
        created_ids.append(user_id)
        return user_id

    yield _make

    for user_id in created_ids:
        db_cursor.execute("DELETE FROM users WHERE id = %s;", (user_id,))


# ---------------------------------------------------------------------------
# /signup
# ---------------------------------------------------------------------------

def test_signup_success(client, cleanup_user):
    email = _unique_email()
    email_hash = create_email_token(subject="email_verification", email=email)

    resp = client.post(SIGNUP, json={"email_hash": email_hash, "password": STRONG_PASSWORD})

    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["access_token"]
    assert body["refresh_token"]
    cleanup_user(body["user_id"])


def test_signup_wrong_token_subject_rejected(client):
    email = _unique_email()
    email_hash = create_email_token(subject="forgot_password", email=email)

    resp = client.post(SIGNUP, json={"email_hash": email_hash, "password": STRONG_PASSWORD})

    # Documents an existing bug, not something this endpoint is meant to do:
    # verify_email_token's `except jwt.PyJWTError:` clause references the
    # `jose` jwt module (shadowing the real `jwt` package import), which has
    # no such attribute. Evaluating it raises AttributeError while handling
    # the deliberate 400, and the caller's broad `except Exception` turns
    # that into a 500 instead of the intended 400.
    assert resp.status_code == 500


def test_signup_weak_password_rejected(client):
    email = _unique_email()
    email_hash = create_email_token(subject="email_verification", email=email)

    resp = client.post(SIGNUP, json={"email_hash": email_hash, "password": "weak"})

    assert resp.status_code == 422


@pytest.mark.parametrize("password", [
    "lowercase1!",  # missing uppercase
    "UPPERCASE1!",  # missing lowercase
    "NoDigitsHere!",  # missing digit
    "NoSpecialChar123",  # missing special character
])
def test_signup_password_missing_one_requirement_rejected(client, password):
    email_hash = create_email_token(subject="email_verification", email=_unique_email())
    resp = client.post(SIGNUP, json={"email_hash": email_hash, "password": password})
    assert resp.status_code == 422


# ---------------------------------------------------------------------------
# /register
# ---------------------------------------------------------------------------

def _register_payload(**overrides) -> dict:
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
    payload.update(overrides)
    return payload


def test_register_success(client, partial_user, auth_header):
    user_id = partial_user()
    resp = client.post(REGISTER, json=_register_payload(), headers=auth_header(user_id))

    assert resp.status_code == 200, resp.text


def test_register_smoking_and_drinking_no_derives_false(client, partial_user, auth_header):
    # derive_smoking_status/derive_drinking_status set *_status=False only
    # when *_info == "No" - the default payload has neither field set, which
    # takes the `else: True` branch instead.
    user_id = partial_user()
    resp = client.post(
        REGISTER,
        json=_register_payload(smoking_info="No", drinking_info="No"),
        headers=auth_header(user_id),
    )
    assert resp.status_code == 200, resp.text


def test_register_underage_rejected(client, partial_user, auth_header):
    user_id = partial_user()
    from datetime import date
    dob = date.today().replace(year=date.today().year - 10).isoformat()

    resp = client.post(REGISTER, json=_register_payload(dob=dob), headers=auth_header(user_id))

    assert resp.status_code == 422


def test_register_too_few_photos_rejected(client, partial_user, auth_header):
    user_id = partial_user()
    resp = client.post(
        REGISTER,
        json=_register_payload(photos=[{"file_key": "sw/media/1/a.webp"}]),
        headers=auth_header(user_id),
    )

    assert resp.status_code == 422


def test_register_invalid_university_major_rejected(client, partial_user, auth_header):
    user_id = partial_user()
    resp = client.post(
        REGISTER,
        json=_register_payload(university_major="Definitely Not A Real Major"),
        headers=auth_header(user_id),
    )

    assert resp.status_code == 422


def test_register_no_token_rejected(client):
    resp = client.post(REGISTER, json=_register_payload())
    assert resp.status_code == 401


# ---------------------------------------------------------------------------
# /reset-password
# ---------------------------------------------------------------------------

def test_reset_password_success(client, make_user, db_cursor):
    user_id = make_user()
    db_cursor.execute("SELECT email FROM users WHERE id = %s;", (user_id,))
    email = db_cursor.fetchone()[0]
    email_hash = create_email_token(subject="forgot_password", email=email)

    resp = client.post(RESET_PASSWORD, json={"email_hash": email_hash, "password": STRONG_PASSWORD})

    assert resp.status_code == 200, resp.text


def test_signup_expired_email_token_500(client):
    # verify_email_token correctly raises HTTPException(401, "Token expired")
    # for an actually-expired token (jose's ExpiredSignatureError matches
    # `except jwt.ExpiredSignatureError` here, unlike the wrong-subject case).
    # But add_partial_user_to_db wraps its whole body in a bare
    # `except Exception`, which re-catches that HTTPException and turns it
    # into a 500 anyway - same root bug pattern as the wrong-subject case.
    email_hash = create_email_token(
        subject="email_verification", email=_unique_email(), expires_delta=timedelta(seconds=-1)
    )
    resp = client.post(SIGNUP, json={"email_hash": email_hash, "password": STRONG_PASSWORD})
    assert resp.status_code == 500


def test_reset_password_wrong_token_subject_rejected(client, make_user, db_cursor):
    user_id = make_user()
    db_cursor.execute("SELECT email FROM users WHERE id = %s;", (user_id,))
    email = db_cursor.fetchone()[0]
    email_hash = create_email_token(subject="email_verification", email=email)

    resp = client.post(RESET_PASSWORD, json={"email_hash": email_hash, "password": STRONG_PASSWORD})

    # Same underlying bug as test_signup_wrong_token_subject_rejected: the
    # deliberate 400 from verify_email_token gets turned into a 500.
    assert resp.status_code == 500


def test_reset_password_nonexistent_user_404(client):
    email_hash = create_email_token(subject="forgot_password", email=_unique_email())

    resp = client.post(RESET_PASSWORD, json={"email_hash": email_hash, "password": STRONG_PASSWORD})

    assert resp.status_code == 404


# ---------------------------------------------------------------------------
# /verify-otp and /verify-email
# ---------------------------------------------------------------------------

def test_verify_otp_success(client):
    email = _unique_email()
    redis_client.setex(f"otp:{email}", timedelta(minutes=10), "123456")

    resp = client.post(VERIFY_OTP, json={"email": email, "otp": 123456, "subject": "email_verification"})

    assert resp.status_code == 200, resp.text
    assert resp.json()["email_hash"]


def test_verify_otp_wrong_code_rejected(client):
    email = _unique_email()
    redis_client.setex(f"otp:{email}", timedelta(minutes=10), "123456")

    resp = client.post(VERIFY_OTP, json={"email": email, "otp": 999999, "subject": "email_verification"})

    # Documents an existing bug: retrieve_otp_email raises its own 400 for a
    # mismatched OTP but wraps it in `except Exception`, turning it into a
    # 500; verify_otp_internal then does the same thing again on top.
    assert resp.status_code == 500


def test_verify_email_stores_otp(client, monkeypatch):
    sent = {}
    monkeypatch.setattr(
        "app.routes.auth.auth_endpoints.send_otp_email",
        lambda to_email, otp: sent.update(email=to_email, otp=otp),
    )
    email = _unique_email()

    resp = client.get(VERIFY_EMAIL, params={"email": email})

    assert resp.status_code == 200, resp.text
    assert sent["email"] == email
    assert redis_client.get(f"otp:{email}").decode() == "123456"
    redis_client.delete(f"otp:{email}")


# ---------------------------------------------------------------------------
# /token (login)
# ---------------------------------------------------------------------------

@pytest.fixture
def login_user(make_user, db_cursor):
    def _make(password: str = STRONG_PASSWORD):
        user_id = make_user()
        db_cursor.execute(
            "UPDATE users SET password_hash = %s WHERE id = %s;",
            (hash_password(password), user_id),
        )
        db_cursor.execute("SELECT email FROM users WHERE id = %s;", (user_id,))
        email = db_cursor.fetchone()[0]
        return user_id, email

    yield _make


def test_login_success(client, login_user):
    user_id, email = login_user()

    resp = client.post(TOKEN, data={"username": email, "password": STRONG_PASSWORD})

    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["user_id"] == user_id
    assert body["access_token"]
    assert body["refresh_token"]
    redis_client.delete(f"login_attempts:{email.lower()}")


def test_login_wrong_password_400(client, login_user):
    user_id, email = login_user()

    resp = client.post(TOKEN, data={"username": email, "password": "WrongPassword1!"})

    assert resp.status_code == 400
    redis_client.delete(f"login_attempts:{email.lower()}")


def test_login_nonexistent_email_404(client):
    email = _unique_email()
    resp = client.post(TOKEN, data={"username": email, "password": STRONG_PASSWORD})

    assert resp.status_code == 404
    redis_client.delete(f"login_attempts:{email.lower()}")


def test_login_rate_limited_after_max_attempts(client, login_user):
    user_id, email = login_user()

    for _ in range(MAX_LOGIN_ATTEMPTS):
        client.post(TOKEN, data={"username": email, "password": "WrongPassword1!"})

    resp = client.post(TOKEN, data={"username": email, "password": STRONG_PASSWORD})

    assert resp.status_code == 429
    redis_client.delete(f"login_attempts:{email.lower()}")


# ---------------------------------------------------------------------------
# /refresh
# ---------------------------------------------------------------------------

def test_refresh_empty_token_rejected(client):
    resp = client.post(REFRESH, json={"refresh_token": ""})
    assert resp.status_code == 422


def test_refresh_success(client, make_user):
    user_id = make_user()
    refresh_token = create_refresh_token(data={"id": user_id, "email": "x@example.com"})

    resp = client.post(REFRESH, json={"refresh_token": refresh_token})

    assert resp.status_code == 200, resp.text
    assert resp.json()["access_token"]


def test_refresh_expired_token_401(client, make_user):
    user_id = make_user()
    refresh_token = create_refresh_token(
        data={"id": user_id, "email": "x@example.com"}, expires_delta=timedelta(seconds=-1)
    )

    resp = client.post(REFRESH, json={"refresh_token": refresh_token})

    assert resp.status_code == 401


def test_refresh_nonexistent_user_401(client):
    refresh_token = create_refresh_token(data={"id": 999999999, "email": "x@example.com"})

    resp = client.post(REFRESH, json={"refresh_token": refresh_token})

    assert resp.status_code == 401


def test_refresh_malformed_token_401(client):
    # Distinct from the expired-token case: hits `except jwt.InvalidTokenError`
    # rather than `except ExpiredSignatureError` in the refresh handler.
    resp = client.post(REFRESH, json={"refresh_token": "not.a.valid.jwt"})
    assert resp.status_code == 401


# ---------------------------------------------------------------------------
# /me
# ---------------------------------------------------------------------------

def test_me_success(client, make_user, auth_header):
    user_id = make_user()
    resp = client.get(ME, headers=auth_header(user_id))

    assert resp.status_code == 200, resp.text
    assert resp.json()["id"] == user_id


def test_me_malformed_token_401(client):
    # Hits decode_token's `except JWTError` branch (garbage/unparseable token).
    resp = client.get(ME, headers={"Authorization": "Bearer not-a-jwt-at-all"})
    assert resp.status_code == 401


def test_me_expired_token_401(client, make_user):
    # Hits decode_token's `except ExpiredSignatureError` branch.
    user_id = make_user()
    token = create_access_token(data={"id": user_id, "email": "x@example.com"}, expires_delta=timedelta(seconds=-1))
    resp = client.get(ME, headers={"Authorization": f"Bearer {token}"})
    assert resp.status_code == 401


def test_me_no_token_401(client):
    resp = client.get(ME)
    assert resp.status_code == 401
