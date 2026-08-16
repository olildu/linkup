import json
from datetime import timedelta

import requests

from app.controllers.redis_controller import redis_client

_REMOTE_URL = "https://raw.githubusercontent.com/olildu/linkup-frontend/refs/heads/main/assets/json/signup_options.json"
_FALLBACK_PATH = "app/constants/signup_options_fallback.json"

_CACHE_KEY = "signup_options:labels"
_CACHE_TTL = timedelta(hours=12)
_FALLBACK_CACHE_TTL = timedelta(hours=1)

def _extract_labels(programs_json: dict) -> list[str]:
    return [program["label"] for program in programs_json["programs"]]

def _load_fallback_labels() -> list[str]:
    with open(_FALLBACK_PATH, "r", encoding="utf-8") as file:
        return _extract_labels(json.load(file))

def get_allowed_majors() -> list[str]:
    cached = redis_client.get(_CACHE_KEY)
    if cached:
        return json.loads(cached)

    try:
        response = requests.get(_REMOTE_URL, timeout=5)
        response.raise_for_status()
        labels = _extract_labels(response.json())
        redis_client.setex(_CACHE_KEY, _CACHE_TTL, json.dumps(labels))
        return labels
    except Exception:
        labels = _load_fallback_labels()
        redis_client.setex(_CACHE_KEY, _FALLBACK_CACHE_TTL, json.dumps(labels))
        return labels
