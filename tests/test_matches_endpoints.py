"""Covers /matches/get-matches and /matches/get-connections."""
import pytest
import uuid

GET_MATCHES = "/api/v1/matches/get-matches"
GET_CONNECTIONS = "/api/v1/matches/get-connections"


def test_get_matches_returns_response_shape(client, make_user, auth_header):
    requester_id = make_user()

    resp = client.get(GET_MATCHES, headers=auth_header(requester_id))

    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert "matches" in body
    assert "swipes_remaining" in body
    assert "preferences_set" in body


def test_get_matches_no_token_401(client):
    resp = client.get(GET_MATCHES)
    assert resp.status_code == 401


def test_get_matches_nonexistent_user_returns_null(client, auth_header):
    # get_matches() returns None (not 404) when the token's user id no
    # longer exists in `users` - documenting current behavior.
    resp = client.get(GET_MATCHES, headers=auth_header(999999999))
    assert resp.status_code == 200
    assert resp.json() is None


def test_get_matches_refresh_clears_queue(client, make_user, auth_header, db_cursor):
    requester_id = make_user()

    resp1 = client.get(GET_MATCHES, headers=auth_header(requester_id))
    assert resp1.status_code == 200, resp1.text

    resp2 = client.get(GET_MATCHES, params={"refresh": True}, headers=auth_header(requester_id))
    assert resp2.status_code == 200, resp2.text


def test_get_connections_no_token_401(client):
    resp = client.get(GET_CONNECTIONS)
    assert resp.status_code == 401


def test_get_connections_empty(client, make_user, auth_header):
    user_id = make_user()
    resp = client.get(GET_CONNECTIONS, headers=auth_header(user_id))

    assert resp.status_code == 200, resp.text
    assert resp.json() == {"matches": [], "chats": []}


def test_get_connections_includes_match_and_chat(client, make_user, auth_header, db_cursor):
    user_id = make_user()
    matched_user_id = make_user()
    chat_partner_id = make_user()

    db_cursor.execute(
        "INSERT INTO matches (user1_id, user2_id) VALUES (%s, %s);", (user_id, matched_user_id)
    )

    db_cursor.execute("INSERT INTO chats DEFAULT VALUES RETURNING id;")
    chat_id = db_cursor.fetchone()[0]
    db_cursor.execute(
        "INSERT INTO chat_participants (chat_id, user_id) VALUES (%s, %s), (%s, %s);",
        (chat_id, user_id, chat_id, chat_partner_id),
    )
    message_id = str(uuid.uuid4())
    db_cursor.execute(
        "INSERT INTO messages (id, chat_id, sender_id, message) VALUES (%s, %s, %s, %s);",
        (message_id, chat_id, chat_partner_id, "hello there"),
    )
    db_cursor.execute("UPDATE chats SET last_message_id = %s WHERE id = %s;", (message_id, chat_id))

    resp = client.get(GET_CONNECTIONS, headers=auth_header(user_id))

    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert len(body["matches"]) == 1
    assert body["matches"][0]["id"] == matched_user_id
    assert len(body["chats"]) == 1
    assert body["chats"][0]["id"] == chat_partner_id
    assert body["chats"][0]["chat_room_id"] == chat_id
    assert body["chats"][0]["last_message"] == "hello there"


def test_get_connections_chat_with_no_messages_sorts_last(client, make_user, auth_header, db_cursor):
    # A chat with zero messages has no row in chat_last_message (the SQL
    # inner-joins chats.last_message_id -> messages.id), so
    # get_last_message_timestamp's `else: return datetime.min` branch is
    # what places it at the end of the sort - exercised here directly.
    user_id = make_user()
    chat_partner_id = make_user()

    db_cursor.execute("INSERT INTO chats DEFAULT VALUES RETURNING id;")
    chat_id = db_cursor.fetchone()[0]
    db_cursor.execute(
        "INSERT INTO chat_participants (chat_id, user_id) VALUES (%s, %s), (%s, %s);",
        (chat_id, user_id, chat_id, chat_partner_id),
    )

    resp = client.get(GET_CONNECTIONS, headers=auth_header(user_id))

    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert len(body["chats"]) == 1
    assert body["chats"][0]["id"] == chat_partner_id
    assert body["chats"][0]["last_message"] is None

    db_cursor.execute("DELETE FROM chat_participants WHERE chat_id = %s;", (chat_id,))
    db_cursor.execute("DELETE FROM chats WHERE id = %s;", (chat_id,))
