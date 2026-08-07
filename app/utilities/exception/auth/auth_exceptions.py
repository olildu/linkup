from fastapi import HTTPException

from app.constants.global_constants import LOGIN_ATTEMPT_WINDOW_SECONDS, MAX_LOGIN_ATTEMPTS
from app.controllers.redis_controller import redis_client


def _login_attempts_key(email: str) -> str:
    return f"login_attempts:{email.lower()}"


def assert_under_login_attempt_limit(email: str):
    """
    Raises HTTP 429 if `email` already has MAX_LOGIN_ATTEMPTS or more failed
    logins within the rolling LOGIN_ATTEMPT_WINDOW_SECONDS window. Read-only —
    checking the limit never counts as an attempt itself.
    """
    raw = redis_client.get(_login_attempts_key(email))
    attempts = int(raw) if raw is not None else 0
    if attempts >= MAX_LOGIN_ATTEMPTS:
        raise HTTPException(status_code=429, detail="Too many login attempts. Please try again later.")


def record_failed_login_attempt(email: str):
    key = _login_attempts_key(email)
    attempts = redis_client.incr(key)
    if attempts == 1:
        redis_client.expire(key, LOGIN_ATTEMPT_WINDOW_SECONDS)


def reset_login_attempts(email: str):
    redis_client.delete(_login_attempts_key(email))
