"""Covers the non-API static/legal pages served directly by app.main."""

PAGES = ["/", "/terms", "/privacy", "/delete-account", "/child-safety", "/logs"]


def test_static_pages_serve_html(client):
    for path in PAGES:
        resp = client.get(path)
        assert resp.status_code == 200, f"{path}: {resp.status_code}"
