"""Covers /chats/start-chat, /chats/get/chat, /chats/get/chat-paginated."""
import uuid

import pytest
from fastapi.testclient import TestClient

from app.main import app

START_CHAT = "/api/v1/chats/start-chat"
GET_CHAT = "/api/v1/chats/get/chat"
GET_CHAT_PAGINATED = "/api/v1/chats/get/chat-paginated"


@pytest.fixture(scope="module")
def async_client():
    """/chats/get/chat and /chats/get/chat-paginated read from
    `request.app.state.db_pool` (an asyncpg pool created in app.main's
    lifespan). The shared `client` fixture never triggers that lifespan
    (plain `TestClient(app)`, not used as a context manager), so it's only
    usable here where the pool is actually needed. Module-scoped so the
    whole file shares one pool instead of spinning up/tearing down a fresh
    one per test (which showed up as an intermittent flake under full-suite
    load).
    """
    with TestClient(app) as c:
        yield c


def _insert_message(db_cursor, chat_id: int, sender_id: int, message: str):
    message_id = str(uuid.uuid4())
    db_cursor.execute(
        "INSERT INTO messages (id, chat_id, sender_id, message) VALUES (%s, %s, %s, %s);",
        (message_id, chat_id, sender_id, message),
    )
    return message_id


def test_start_chat_no_match_400(client, make_user, auth_header):
    user_id = make_user()
    other_id = make_user()

    resp = client.post(START_CHAT, json={"id": other_id}, headers=auth_header(user_id))

    assert resp.status_code == 400


def test_start_chat_success_creates_chat_and_deletes_match(
    client, make_user, auth_header, db_cursor
):
    user_id = make_user()
    other_id = make_user()
    db_cursor.execute(
        "INSERT INTO matches (user1_id, user2_id) VALUES (%s, %s);", (user_id, other_id)
    )

    resp = client.post(START_CHAT, json={"id": other_id}, headers=auth_header(user_id))

    assert resp.status_code == 200, resp.text
    chat_id = resp.json()["chat_room_id"]

    db_cursor.execute(
        "SELECT COUNT(*) FROM chat_participants WHERE chat_id = %s;", (chat_id,)
    )
    assert db_cursor.fetchone()[0] == 2

    db_cursor.execute(
        "SELECT COUNT(*) FROM matches WHERE user1_id = %s AND user2_id = %s;",
        (user_id, other_id),
    )
    assert db_cursor.fetchone()[0] == 0

    db_cursor.execute("DELETE FROM chat_participants WHERE chat_id = %s;", (chat_id,))
    db_cursor.execute("DELETE FROM chats WHERE id = %s;", (chat_id,))


def test_start_chat_no_token_401(client):
    resp = client.post(START_CHAT, json={"id": 1})
    assert resp.status_code == 401


@pytest.fixture
def chat_with_message(make_user, db_cursor):
    user_id = make_user()
    other_id = make_user()
    db_cursor.execute("INSERT INTO chats DEFAULT VALUES RETURNING id;")
    chat_id = db_cursor.fetchone()[0]
    db_cursor.execute(
        "INSERT INTO chat_participants (chat_id, user_id) VALUES (%s, %s), (%s, %s);",
        (chat_id, user_id, chat_id, other_id),
    )
    message_id = _insert_message(db_cursor, chat_id, other_id, "hello")

    yield user_id, other_id, chat_id, message_id

    db_cursor.execute("DELETE FROM messages WHERE chat_id = %s;", (chat_id,))
    db_cursor.execute("DELETE FROM chat_participants WHERE chat_id = %s;", (chat_id,))
    db_cursor.execute("DELETE FROM chats WHERE id = %s;", (chat_id,))


def test_get_chat_success_marks_seen(async_client, chat_with_message, auth_header, db_cursor):
    user_id, other_id, chat_id, message_id = chat_with_message

    resp = async_client.post(GET_CHAT, json={"chat_room_id": chat_id}, headers=auth_header(user_id))

    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert len(body["messages"]) == 1
    assert body["messages"][0]["message"] == "hello"

    db_cursor.execute(
        "SELECT unseen_count FROM chat_participants WHERE chat_id = %s AND user_id = %s;",
        (chat_id, user_id),
    )
    assert db_cursor.fetchone()[0] == 0


def test_get_chat_non_participant_403(async_client, chat_with_message, make_user, auth_header):
    _, _, chat_id, _ = chat_with_message
    stranger_id = make_user()

    resp = async_client.post(GET_CHAT, json={"chat_room_id": chat_id}, headers=auth_header(stranger_id))

    assert resp.status_code == 403


def test_get_chat_paginated_returns_has_more(async_client, make_user, auth_header, db_cursor):
    user_id = make_user()
    other_id = make_user()
    db_cursor.execute("INSERT INTO chats DEFAULT VALUES RETURNING id;")
    chat_id = db_cursor.fetchone()[0]
    db_cursor.execute(
        "INSERT INTO chat_participants (chat_id, user_id) VALUES (%s, %s), (%s, %s);",
        (chat_id, user_id, chat_id, other_id),
    )

    message_ids = [_insert_message(db_cursor, chat_id, other_id, f"msg {i}") for i in range(25)]

    resp = async_client.post(
        GET_CHAT_PAGINATED, json={"chat_room_id": chat_id}, headers=auth_header(user_id)
    )

    # Documents an existing bug: with no cursor supplied, `last_message_id`/
    # `last_message_timestamp` are both NULL, and the query's
    # `(m.timestamp, m.id) < ($3::timestamp, $4::uuid)` row comparison is
    # NULL (never true) when either side is NULL - so the "first page, no
    # cursor yet" case returns zero messages instead of the latest 20.
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["messages"] == []
    assert body["has_more"] is False

    db_cursor.execute("DELETE FROM messages WHERE chat_id = %s;", (chat_id,))
    db_cursor.execute("DELETE FROM chat_participants WHERE chat_id = %s;", (chat_id,))
    db_cursor.execute("DELETE FROM chats WHERE id = %s;", (chat_id,))


def test_get_chat_paginated_with_explicit_cursor_returns_has_more(
    async_client, make_user, auth_header, db_cursor
):
    # Working around the NULL-cursor bug documented above: supplying an
    # explicit (far-future timestamp, arbitrary uuid) cursor makes the
    # `(m.timestamp, m.id) < (cursor)` comparison match real rows, which is
    # the only way to exercise the has_more/next_page_cursor branch.
    user_id = make_user()
    other_id = make_user()
    db_cursor.execute("INSERT INTO chats DEFAULT VALUES RETURNING id;")
    chat_id = db_cursor.fetchone()[0]
    db_cursor.execute(
        "INSERT INTO chat_participants (chat_id, user_id) VALUES (%s, %s), (%s, %s);",
        (chat_id, user_id, chat_id, other_id),
    )
    for i in range(25):
        _insert_message(db_cursor, chat_id, other_id, f"msg {i}")

    resp = async_client.post(
        GET_CHAT_PAGINATED,
        json={
            "chat_room_id": chat_id,
            "last_message_id": str(uuid.uuid4()),
            "last_message_timestamp": "2099-01-01T00:00:00",
        },
        headers=auth_header(user_id),
    )

    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert len(body["messages"]) == 20
    assert body["has_more"] is True
    assert body["next_page_cursor"] is not None

    db_cursor.execute("DELETE FROM messages WHERE chat_id = %s;", (chat_id,))
    db_cursor.execute("DELETE FROM chat_participants WHERE chat_id = %s;", (chat_id,))
    db_cursor.execute("DELETE FROM chats WHERE id = %s;", (chat_id,))


def test_get_chat_paginated_non_participant_returns_500_not_403(
    async_client, chat_with_message, make_user, auth_header
):
    # Documents an existing bug: unlike /chats/get/chat, this handler wraps
    # the whole body (including the participant check) in a bare
    # `except Exception`, which catches the deliberate 403 HTTPException and
    # re-raises it as a 500 "Failed to fetch chat messages" instead.
    _, _, chat_id, _ = chat_with_message
    stranger_id = make_user()

    resp = async_client.post(
        GET_CHAT_PAGINATED, json={"chat_room_id": chat_id}, headers=auth_header(stranger_id)
    )

    assert resp.status_code == 500
