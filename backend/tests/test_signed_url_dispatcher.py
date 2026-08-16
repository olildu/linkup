"""Unit tests for the sw/-prefix dispatch logic added to the two legacy
signed-URL functions, so both the new and old code paths stay wired up
correctly regardless of live external credentials.
"""
from app.utilities.common import common_utilites
from app.utilities.media import media_utilities


def test_generate_signed_url_dispatches_new_keys_to_imgproxy(monkeypatch):
    called = {}

    def fake_build_signed_url(file_key, expire_seconds=1200):
        called["args"] = (file_key, expire_seconds)
        return "https://imgproxy/x"

    monkeypatch.setattr(media_utilities, "build_signed_url", fake_build_signed_url)
    monkeypatch.setattr(media_utilities.bucket, "get_download_authorization", lambda **kw: (_ for _ in ()).throw(AssertionError("should not call legacy B2")))

    result = media_utilities.generate_signed_url("sw/media/1/x.webp", valid_duration=600)

    assert result == "https://imgproxy/x"
    assert called["args"] == ("sw/media/1/x.webp", 600)


def test_generate_signed_url_dispatches_legacy_keys_to_b2(monkeypatch):
    monkeypatch.setattr(media_utilities, "build_signed_url", lambda *a, **kw: (_ for _ in ()).throw(AssertionError("should not call imgproxy for legacy key")))
    monkeypatch.setattr(media_utilities.bucket, "get_download_authorization", lambda **kw: "authtoken")
    monkeypatch.setattr(media_utilities.bucket, "get_download_url", lambda key: "https://b2/legacy")

    result = media_utilities.generate_signed_url("media/1/x.webp")

    assert result == "https://b2/legacy?Authorization=authtoken"


def test_get_signed_imagekit_dispatches_new_keys_to_imgproxy(monkeypatch):
    monkeypatch.setattr(
        common_utilites,
        "build_signed_url",
        lambda file_key, expire_seconds=7200: "https://imgproxy/y",
    )
    monkeypatch.setattr(common_utilites.imagekit, "url", lambda opts: (_ for _ in ()).throw(AssertionError("should not call legacy ImageKit")))

    result = common_utilites.get_signed_imagekit({"file_key": "sw/profile_pictures/1/pfp.webp"})

    assert result["url"] == "https://imgproxy/y"


def test_get_signed_imagekit_dispatches_legacy_keys_to_imagekit(monkeypatch):
    monkeypatch.setattr(common_utilites, "build_signed_url", lambda *a, **kw: (_ for _ in ()).throw(AssertionError("should not call imgproxy for legacy key")))
    monkeypatch.setattr(common_utilites.imagekit, "url", lambda opts: "https://imagekit/legacy")

    result = common_utilites.get_signed_imagekit({"file_key": "profile_pictures/1/pfp.webp"})

    assert result["url"] == "https://imagekit/legacy"
