"""Unit tests for the SSRF guard used by /upload/media-user-pfp-from-url."""
from app.features.media.url_safety import is_safe_url


def test_rejects_non_http_scheme():
    assert is_safe_url("ftp://example.com/image.jpg") is False


def test_rejects_malformed_url():
    assert is_safe_url("not a url at all") is False


def test_rejects_url_that_urlparse_cannot_parse():
    # An unterminated IPv6-literal bracket makes urlparse itself raise
    # ValueError, rather than just returning an unusable/empty hostname.
    assert is_safe_url("http://[::1/x.jpg") is False


def test_rejects_url_with_no_host():
    assert is_safe_url("http://") is False


def test_rejects_loopback():
    assert is_safe_url("http://127.0.0.1/x.jpg") is False
    assert is_safe_url("http://localhost/x.jpg") is False


def test_rejects_private_range():
    assert is_safe_url("http://192.168.1.5/x.jpg") is False
    assert is_safe_url("http://10.0.0.1/x.jpg") is False


def test_rejects_link_local():
    assert is_safe_url("http://169.254.169.254/latest/meta-data") is False


def test_rejects_unresolvable_host():
    assert is_safe_url("http://this-host-does-not-exist.invalid/x.jpg") is False


def test_allows_public_host():
    assert is_safe_url("https://raw.githubusercontent.com/foo/bar.jpg") is True
