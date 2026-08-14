"""Unit tests for get_allowed_majors' redis-cache / remote-fetch / fallback
branches (app/utilities/signup/signup_options_utilities.py)."""
import json

import pytest

import app.utilities.signup.signup_options_utilities as signup_options_module
from app.controllers.redis_controller import redis_client

CACHE_KEY = "signup_options:labels"


@pytest.fixture(autouse=True)
def clear_cache():
    redis_client.delete(CACHE_KEY)
    yield
    redis_client.delete(CACHE_KEY)


def test_returns_cached_labels_without_network_call(monkeypatch):
    redis_client.set(CACHE_KEY, json.dumps(["Custom Major"]))

    def _fail(*a, **kw):
        raise AssertionError("should not hit the network when cache is warm")

    monkeypatch.setattr(signup_options_module.requests, "get", _fail)

    assert signup_options_module.get_allowed_majors() == ["Custom Major"]


def test_fetches_remote_and_caches_on_cold_cache(monkeypatch):
    class FakeResponse:
        def raise_for_status(self):
            pass

        def json(self):
            return {"programs": [{"label": "Remote Major"}]}

    monkeypatch.setattr(signup_options_module.requests, "get", lambda *a, **kw: FakeResponse())

    labels = signup_options_module.get_allowed_majors()

    assert labels == ["Remote Major"]
    assert json.loads(redis_client.get(CACHE_KEY)) == ["Remote Major"]


def test_falls_back_to_local_file_on_remote_failure(monkeypatch):
    def _raise(*a, **kw):
        raise ConnectionError("network unreachable")

    monkeypatch.setattr(signup_options_module.requests, "get", _raise)

    labels = signup_options_module.get_allowed_majors()

    assert "BTech" in labels
    assert json.loads(redis_client.get(CACHE_KEY)) == labels
