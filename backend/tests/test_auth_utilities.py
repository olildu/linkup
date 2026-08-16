"""Unit tests for app/utilities/auth/auth_utilities.py branches not
reachable through the /verify-email or /verify-otp HTTP routes (Brevo send
success/failure, and the redis-key-not-found OTP branch)."""
import pytest
from fastapi import HTTPException

import app.features.auth.auth_utilities as auth_utilities_module
from app.features.auth.auth_utilities import EmailOTPData, retrieve_otp_email, send_otp_email


def test_send_otp_email_success(monkeypatch):
    sent = {}
    monkeypatch.setattr(
        auth_utilities_module.client, "send_transac_email", lambda payload: sent.setdefault("payload", payload)
    )
    send_otp_email("someone@example.com", "123456")
    assert sent["payload"].to == [{"email": "someone@example.com"}]


def test_send_otp_email_brevo_failure_raises_500(monkeypatch):
    from brevo_python.rest import ApiException

    def _raise(payload):
        raise ApiException(status=500, reason="boom")

    monkeypatch.setattr(auth_utilities_module.client, "send_transac_email", _raise)

    with pytest.raises(HTTPException) as exc_info:
        send_otp_email("someone@example.com", "123456")
    assert exc_info.value.status_code == 500


def test_retrieve_otp_email_not_found_500():
    data = EmailOTPData(email="nobody-has-this-otp@example.com", otp=123456, subject="email_verification")
    with pytest.raises(HTTPException) as exc_info:
        retrieve_otp_email(data)
    # Documents an existing bug: the deliberate 400 "OTP expired or not
    # found" gets caught by this function's own `except Exception` and
    # re-raised as a 500.
    assert exc_info.value.status_code == 500
