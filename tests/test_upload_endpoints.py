"""Covers every upload endpoint the frontend can hit, across the image
format/mode/size/error matrix, against the new SeaweedFS + imgproxy stack.
"""
import pytest

import image_factory as imf

UPLOAD_MEDIA = "/api/v1/upload/media"
UPLOAD_MEDIA_USER = "/api/v1/upload/media-user"
UPLOAD_PFP = "/api/v1/upload/media-user-pfp"
UPLOAD_PFP_FROM_URL = "/api/v1/upload/media-user-pfp-from-url"


# ---------------------------------------------------------------------------
# Format / mode / size matrix - /upload/media (chat) and /upload/media-user
# ---------------------------------------------------------------------------

FORMAT_MODE_CASES = [
    ("JPEG", "RGB", (400, 400)),
    ("PNG", "RGB", (400, 400)),
    ("PNG", "RGBA", (400, 400)),
    ("WEBP", "RGB", (400, 400)),
    ("GIF", "RGB", (400, 400)),
    ("JPEG", "L", (400, 400)),  # grayscale
    ("JPEG", "RGB", (2, 2)),  # tiny
    ("JPEG", "RGB", (100, 3000)),  # extreme aspect ratio
    ("PNG", "RGB", (1200, 900)),  # landscape, "normal" size
]


@pytest.mark.parametrize("fmt,mode,size", FORMAT_MODE_CASES)
def test_upload_media_chat_matrix(client, make_user, auth_header, seaweed_object, fmt, mode, size):
    user_id = make_user()
    content = imf.make_image_bytes(format=fmt, mode=mode, size=size)

    resp = client.post(
        UPLOAD_MEDIA,
        headers=auth_header(user_id),
        files={"file": (f"test.{fmt.lower()}", content, "application/octet-stream")},
        data={"media_type": "image"},
    )

    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["file_key"].startswith("sw/media/")
    seaweed_object(body["file_key"])
    assert body["metadata"]["format"] == "webp"
    assert body["metadata"]["width"] > 0
    assert body["metadata"]["height"] > 0
    assert body["metadata"]["blurhash"]
    assert body["metadata"]["file_url"].startswith("http")


@pytest.mark.parametrize("fmt,mode,size", FORMAT_MODE_CASES)
def test_upload_media_user_matrix(client, make_user, auth_header, seaweed_object, fmt, mode, size):
    user_id = make_user()
    content = imf.make_image_bytes(format=fmt, mode=mode, size=size)

    resp = client.post(
        UPLOAD_MEDIA_USER,
        headers=auth_header(user_id),
        files={"file": (f"test.{fmt.lower()}", content, "application/octet-stream")},
        data={"media_type": "image"},
    )

    assert resp.status_code == 200, resp.text
    body = resp.json()
    file_key = body["metadata"]["file_key"]
    assert file_key.startswith("sw/media/")
    seaweed_object(file_key)
    assert body["metadata"]["blurhash"]


# ---------------------------------------------------------------------------
# Error paths
# ---------------------------------------------------------------------------

def test_upload_media_chat_rejects_oversized_original(client, make_user, auth_header):
    """/upload/media checks raw upload size up front (before any processing)."""
    user_id = make_user()
    resp = client.post(
        UPLOAD_MEDIA,
        headers=auth_header(user_id),
        files={"file": ("big.jpg", imf.oversized_image_bytes(), "image/jpeg")},
        data={"media_type": "image"},
    )
    assert resp.status_code == 413


def test_upload_media_user_does_not_reject_oversized_original(client, make_user, auth_header, seaweed_object):
    """Known/documented asymmetry (pre-existing, not introduced by this
    migration): unlike /upload/media, /upload/media-user has no upfront
    raw-size check - it only rejects based on the *converted* webp size. A
    large-but-valid original that compresses well after resize+webp still
    goes through. Flagging this explicitly so it isn't silently "fixed" or
    regressed without a deliberate decision.
    """
    user_id = make_user()
    resp = client.post(
        UPLOAD_MEDIA_USER,
        headers=auth_header(user_id),
        files={"file": ("big.jpg", imf.oversized_image_bytes(), "image/jpeg")},
        data={"media_type": "image"},
    )
    assert resp.status_code == 200, resp.text
    seaweed_object(resp.json()["metadata"]["file_key"])


def test_upload_media_user_rejects_oversized_converted_output(client, make_user, auth_header, monkeypatch):
    """Force the post-conversion size check to trip, without needing an
    adversarial image that survives webp compression above 5MB.
    """
    import app.routes.common.common_endpoints as endpoints_module

    def fake_process(content):
        return "/tmp/fake.webp", b"x" * (endpoints_module.MAX_FILE_SIZE_BYTES + 1), 100, 100

    monkeypatch.setattr(endpoints_module, "process_image_to_webp_file", fake_process)

    user_id = make_user()
    resp = client.post(
        UPLOAD_MEDIA_USER,
        headers=auth_header(user_id),
        files={"file": ("test.jpg", imf.make_image_bytes(), "image/jpeg")},
        data={"media_type": "image"},
    )
    assert resp.status_code == 413


def test_upload_media_rejects_corrupt_file(client, make_user, auth_header):
    user_id = make_user()
    resp = client.post(
        UPLOAD_MEDIA,
        headers=auth_header(user_id),
        files={"file": ("bad.jpg", imf.corrupt_bytes(), "image/jpeg")},
        data={"media_type": "image"},
    )
    # process_image_half_and_convert_webp raises on non-image bytes -> 500,
    # while /upload/media-user explicitly validates first -> 400 (see next
    # test). Documenting the current (inconsistent) behavior rather than
    # asserting a single "correct" code.
    assert resp.status_code == 500


def test_upload_media_user_rejects_corrupt_file(client, make_user, auth_header):
    user_id = make_user()
    resp = client.post(
        UPLOAD_MEDIA_USER,
        headers=auth_header(user_id),
        files={"file": ("bad.jpg", imf.corrupt_bytes(), "image/jpeg")},
        data={"media_type": "image"},
    )
    assert resp.status_code == 400


def test_upload_media_chat_rejects_oversized_converted_output(client, make_user, auth_header, monkeypatch):
    import app.routes.common.common_endpoints as endpoints_module

    def fake_process(content):
        return b"x" * (endpoints_module.MAX_FILE_SIZE_BYTES + 1), 100, 100

    monkeypatch.setattr(endpoints_module, "process_image_half_and_convert_webp", fake_process)

    user_id = make_user()
    resp = client.post(
        UPLOAD_MEDIA,
        headers=auth_header(user_id),
        files={"file": ("test.jpg", imf.make_image_bytes(), "image/jpeg")},
        data={"media_type": "image"},
    )
    assert resp.status_code == 413


def test_upload_media_user_generic_exception_500(client, make_user, auth_header, monkeypatch):
    import app.routes.common.common_endpoints as endpoints_module

    def _raise(content):
        raise RuntimeError("simulated unexpected failure")

    monkeypatch.setattr(endpoints_module, "process_image_to_webp_file", _raise)

    user_id = make_user()
    resp = client.post(
        UPLOAD_MEDIA_USER,
        headers=auth_header(user_id),
        files={"file": ("test.jpg", imf.make_image_bytes(), "image/jpeg")},
        data={"media_type": "image"},
    )
    assert resp.status_code == 500


def test_upload_media_requires_auth(client):
    resp = client.post(
        UPLOAD_MEDIA,
        files={"file": ("test.jpg", imf.make_image_bytes(), "image/jpeg")},
        data={"media_type": "image"},
    )
    assert resp.status_code == 401


def test_upload_media_rejects_invalid_token(client):
    resp = client.post(
        UPLOAD_MEDIA,
        headers={"Authorization": "Bearer not-a-real-token"},
        files={"file": ("test.jpg", imf.make_image_bytes(), "image/jpeg")},
        data={"media_type": "image"},
    )
    assert resp.status_code == 401


# ---------------------------------------------------------------------------
# Known pre-existing issue: media_type=VOICE still runs image processing.
# Documented here so it's a deliberate decision if it ever changes.
# ---------------------------------------------------------------------------

def test_upload_media_voice_type_currently_runs_image_pipeline(client, make_user, auth_header):
    user_id = make_user()
    resp = client.post(
        UPLOAD_MEDIA,
        headers=auth_header(user_id),
        files={"file": ("voice.ogg", b"not actually audio bytes either way", "audio/ogg")},
        data={"media_type": "voice"},
    )
    # A real voice upload (non-image bytes) blows up in the image pipeline.
    assert resp.status_code == 500


# ---------------------------------------------------------------------------
# Profile picture (face-crop) endpoints
# ---------------------------------------------------------------------------

def test_upload_media_user_pfp_with_detectable_face(client, make_user, auth_header, seaweed_object):
    user_id = make_user()
    resp = client.post(
        UPLOAD_PFP,
        headers=auth_header(user_id),
        files={"file": ("face.jpg", imf.face_image_bytes(), "image/jpeg")},
        data={"media_type": "image"},
    )
    assert resp.status_code == 200, resp.text
    body = resp.json()
    profile_key = body["profile_metadata"]["file_key"]
    original_key = body["original_image_metadata"]["file_key"]
    assert profile_key.startswith("sw/profile_pictures/")
    assert original_key.startswith("sw/media/")
    seaweed_object(profile_key)
    seaweed_object(original_key)
    assert body["profile_picture_url"].startswith("http")
    assert body["original_image_url"].startswith("http")


def test_upload_media_user_pfp_no_face_detected(client, make_user, auth_header):
    user_id = make_user()
    resp = client.post(
        UPLOAD_PFP,
        headers=auth_header(user_id),
        files={"file": ("noface.jpg", imf.no_face_image_bytes(), "image/jpeg")},
        data={"media_type": "image"},
    )
    assert resp.status_code == 422


def test_upload_media_user_pfp_invalid_image(client, make_user, auth_header):
    user_id = make_user()
    resp = client.post(
        UPLOAD_PFP,
        headers=auth_header(user_id),
        files={"file": ("bad.jpg", imf.corrupt_bytes(), "image/jpeg")},
        data={"media_type": "image"},
    )
    assert resp.status_code == 400


def test_upload_media_user_pfp_rejects_oversized_converted_output(client, make_user, auth_header, seaweed_object, monkeypatch):
    # The 413 response doesn't expose the original image's file_key (raised
    # before the return statement), so the original upload made just before
    # the size check trips is left in SeaweedFS - acceptable for a local dev
    # bucket, not worth threading the key through just to clean it up here.
    import app.routes.common.common_endpoints as endpoints_module

    def fake_process(content):
        return "/tmp/fake.webp", b"x" * (endpoints_module.MAX_FILE_SIZE_BYTES + 1), 100, 100

    monkeypatch.setattr(endpoints_module, "process_image_to_webp_file", fake_process)

    user_id = make_user()
    resp = client.post(
        UPLOAD_PFP,
        headers=auth_header(user_id),
        files={"file": ("face.jpg", imf.face_image_bytes(), "image/jpeg")},
        data={"media_type": "image"},
    )
    assert resp.status_code == 413


def test_upload_media_user_pfp_generic_exception_500(client, make_user, auth_header, monkeypatch):
    import app.routes.common.common_endpoints as endpoints_module

    def _raise(*a, **kw):
        raise RuntimeError("simulated unexpected failure")

    monkeypatch.setattr(endpoints_module, "extract_face", _raise)

    user_id = make_user()
    resp = client.post(
        UPLOAD_PFP,
        headers=auth_header(user_id),
        files={"file": ("face.jpg", imf.face_image_bytes(), "image/jpeg")},
        data={"media_type": "image"},
    )
    assert resp.status_code == 500


def test_upload_media_user_pfp_from_url(client, make_user, auth_header, seaweed_object, monkeypatch):
    import app.routes.common.common_endpoints as endpoints_module

    class FakeResponse:
        status_code = 200
        content = imf.face_image_bytes()

    monkeypatch.setattr(endpoints_module.requests, "get", lambda url, **kwargs: FakeResponse())

    user_id = make_user()
    resp = client.post(
        UPLOAD_PFP_FROM_URL,
        headers=auth_header(user_id),
        data={"image_url": "https://example.com/avatar.jpg"},
    )
    assert resp.status_code == 200, resp.text
    body = resp.json()
    profile_key = body["profile_metadata"]["file_key"]
    assert profile_key.startswith("sw/profile_pictures/")
    seaweed_object(profile_key)
    assert body["profile_picture_url"].startswith("http")


def test_upload_media_user_pfp_from_url_unreachable(client, make_user, auth_header, monkeypatch):
    import app.routes.common.common_endpoints as endpoints_module

    class FakeResponse:
        status_code = 404
        content = b""

    monkeypatch.setattr(endpoints_module.requests, "get", lambda url, **kwargs: FakeResponse())

    user_id = make_user()
    resp = client.post(
        UPLOAD_PFP_FROM_URL,
        headers=auth_header(user_id),
        data={"image_url": "https://example.com/missing.jpg"},
    )
    assert resp.status_code == 400


def test_upload_media_user_pfp_from_url_no_face(client, make_user, auth_header, monkeypatch):
    import app.routes.common.common_endpoints as endpoints_module

    class FakeResponse:
        status_code = 200
        content = imf.no_face_image_bytes()

    monkeypatch.setattr(endpoints_module.requests, "get", lambda url, **kwargs: FakeResponse())

    user_id = make_user()
    resp = client.post(
        UPLOAD_PFP_FROM_URL,
        headers=auth_header(user_id),
        data={"image_url": "https://example.com/noface.jpg"},
    )
    assert resp.status_code == 422


def test_upload_media_user_pfp_from_url_ssrf_blocked(client, make_user, auth_header, monkeypatch):
    import app.routes.common.common_endpoints as endpoints_module

    def _fail(*a, **kw):
        raise AssertionError("should never fetch an unsafe URL")

    monkeypatch.setattr(endpoints_module.requests, "get", _fail)

    user_id = make_user()
    resp = client.post(
        UPLOAD_PFP_FROM_URL,
        headers=auth_header(user_id),
        data={"image_url": "http://169.254.169.254/latest/meta-data/"},
    )
    assert resp.status_code == 400


def test_upload_media_user_pfp_from_url_invalid_image_content(client, make_user, auth_header, monkeypatch):
    import app.routes.common.common_endpoints as endpoints_module

    class FakeResponse:
        status_code = 200
        content = b"this is not image data"

    monkeypatch.setattr(endpoints_module.requests, "get", lambda url, **kwargs: FakeResponse())

    user_id = make_user()
    resp = client.post(
        UPLOAD_PFP_FROM_URL,
        headers=auth_header(user_id),
        data={"image_url": "https://example.com/notanimage.jpg"},
    )
    assert resp.status_code == 400


def test_upload_media_user_pfp_from_url_rejects_oversized_converted_output(client, make_user, auth_header, monkeypatch):
    import app.routes.common.common_endpoints as endpoints_module

    class FakeResponse:
        status_code = 200
        content = imf.face_image_bytes()

    def fake_process(content):
        return "/tmp/fake.webp", b"x" * (endpoints_module.MAX_FILE_SIZE_BYTES + 1), 100, 100

    monkeypatch.setattr(endpoints_module.requests, "get", lambda url, **kwargs: FakeResponse())
    monkeypatch.setattr(endpoints_module, "process_image_to_webp_file", fake_process)

    user_id = make_user()
    resp = client.post(
        UPLOAD_PFP_FROM_URL,
        headers=auth_header(user_id),
        data={"image_url": "https://example.com/avatar.jpg"},
    )
    assert resp.status_code == 413


def test_upload_media_user_pfp_from_url_generic_exception_500(client, make_user, auth_header, monkeypatch):
    import app.routes.common.common_endpoints as endpoints_module

    class FakeResponse:
        status_code = 200
        content = imf.face_image_bytes()

    def _raise(*a, **kw):
        raise RuntimeError("simulated unexpected failure")

    monkeypatch.setattr(endpoints_module.requests, "get", lambda url, **kwargs: FakeResponse())
    monkeypatch.setattr(endpoints_module, "extract_face", _raise)

    user_id = make_user()
    resp = client.post(
        UPLOAD_PFP_FROM_URL,
        headers=auth_header(user_id),
        data={"image_url": "https://example.com/avatar.jpg"},
    )
    assert resp.status_code == 500
