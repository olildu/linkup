"""Verifies the SeaweedFS + imgproxy plumbing itself: objects actually land
in storage, signed URLs resolve to real image bytes, expired URLs are
rejected, and blurhash strings are decodable.
"""
import time

import blurhash
import httpx
import pytest

import image_factory as imf
from app.constants.global_constants import IMGPROXY_PUBLIC_URL, SEAWEEDFS_BUCKET
from app.utilities.media.imgproxy_utilities import build_signed_url

UPLOAD_MEDIA_USER = "/api/v1/upload/media-user"

# IMGPROXY_PUBLIC_URL is the externally-facing address (host-mapped
# localhost:8006 in local dev, the real domain in prod) - this test suite
# runs *inside* the backend container, where that address isn't reachable.
# Rewrite to the internal compose service name/port to actually fetch it.
INTERNAL_IMGPROXY_URL = "http://imgproxy:8080"


def _reachable(url: str) -> str:
    return url.replace(IMGPROXY_PUBLIC_URL, INTERNAL_IMGPROXY_URL, 1)


def test_uploaded_object_present_in_seaweedfs(client, make_user, auth_header, s3_client, seaweed_object):
    user_id = make_user()
    resp = client.post(
        UPLOAD_MEDIA_USER,
        headers=auth_header(user_id),
        files={"file": ("test.jpg", imf.make_image_bytes(), "image/jpeg")},
        data={"media_type": "image"},
    )
    assert resp.status_code == 200
    file_key = resp.json()["metadata"]["file_key"]
    seaweed_object(file_key)

    head = s3_client.head_object(Bucket=SEAWEEDFS_BUCKET, Key=file_key)
    assert head["ContentLength"] > 0


def test_signed_url_resolves_to_real_image(client, make_user, auth_header, seaweed_object):
    user_id = make_user()
    resp = client.post(
        UPLOAD_MEDIA_USER,
        headers=auth_header(user_id),
        files={"file": ("test.jpg", imf.make_image_bytes(size=(300, 200)), "image/jpeg")},
        data={"media_type": "image"},
    )
    assert resp.status_code == 200
    file_key = resp.json()["metadata"]["file_key"]
    seaweed_object(file_key)

    url = build_signed_url(file_key)
    img_resp = httpx.get(_reachable(url), timeout=10)
    assert img_resp.status_code == 200
    assert img_resp.headers["content-type"].startswith("image/")
    assert len(img_resp.content) > 0


def test_signed_url_rejects_after_expiry(seaweed_object, s3_client):
    file_key = "sw/media/pytest-expiry-test/probe.webp"
    s3_client.put_object(Bucket=SEAWEEDFS_BUCKET, Key=file_key, Body=imf.make_image_bytes())
    seaweed_object(file_key)

    expired_url = build_signed_url(file_key, expire_seconds=-10)
    resp = httpx.get(_reachable(expired_url), timeout=10)
    assert resp.status_code == 404


def test_signed_url_signature_tamper_rejected(seaweed_object, s3_client):
    file_key = "sw/media/pytest-tamper-test/probe.webp"
    s3_client.put_object(Bucket=SEAWEEDFS_BUCKET, Key=file_key, Body=imf.make_image_bytes())
    seaweed_object(file_key)

    url = build_signed_url(file_key)
    # Flip a character in the signature segment (first path component).
    parts = url.split("/")
    parts[3] = parts[3][:-1] + ("A" if parts[3][-1] != "A" else "B")
    tampered_url = "/".join(parts)

    resp = httpx.get(_reachable(tampered_url), timeout=10)
    assert resp.status_code == 403


@pytest.mark.parametrize("size", [(300, 200), (2, 2), (1200, 900)])
def test_blurhash_is_decodable(client, make_user, auth_header, seaweed_object, size):
    user_id = make_user()
    resp = client.post(
        UPLOAD_MEDIA_USER,
        headers=auth_header(user_id),
        files={"file": ("test.jpg", imf.make_image_bytes(size=size), "image/jpeg")},
        data={"media_type": "image"},
    )
    assert resp.status_code == 200
    seaweed_object(resp.json()["metadata"]["file_key"])

    hash_str = resp.json()["metadata"]["blurhash"]
    decoded = blurhash.decode(hash_str, 32, 32)
    assert decoded is not None
