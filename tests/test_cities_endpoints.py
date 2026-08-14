"""Covers /locations/india/search/{query}."""

SEARCH = "/api/v1/locations/india/search/{}"


def test_search_cities_matches(client):
    resp = client.get(SEARCH.format("Port Blair"))
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert any("Port Blair" in entry for entry in body)


def test_search_cities_case_insensitive(client):
    resp = client.get(SEARCH.format("port blair"))
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert any("Port Blair" in entry for entry in body)


def test_search_cities_matches_by_state(client):
    resp = client.get(SEARCH.format("Nicobar"))
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert len(body) > 1


def test_search_cities_no_match_empty_list(client):
    resp = client.get(SEARCH.format("Definitely Not A Real Place Xyz"))
    assert resp.status_code == 200, resp.text
    assert resp.json() == []


def test_search_cities_no_auth_required(client):
    resp = client.get(SEARCH.format("Mumbai"))
    assert resp.status_code == 200
