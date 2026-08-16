"""Covers /ws/chat, /ws/connections, /ws/lobby."""
import json
import uuid
from datetime import timedelta

import pytest
from starlette.websockets import WebSocketDisconnect

import app.routes.chats.chat_websocket_endpoints as chat_ws_module
import app.routes.matches.connections_websocket_endpoints as connections_ws_module
import app.routes.matches.lobby.lobby_websocket_endpoints as lobby_module
from app.utilities.token.token_utilities import create_access_token

CHAT_WS = "/api/v1/ws/chat"
CONNECTIONS_WS = "/api/v1/ws/connections"
LOBBY_WS = "/api/v1/ws/lobby"
START_CHAT = "/api/v1/chats/start-chat"


def _token(user_id: int) -> str:
    return create_access_token(data={"id": user_id, "email": "x@example.com"}, expires_delta=timedelta(minutes=30))


class FakeWebSocket:
    def __init__(self, fail_send=False):
        self.sent = []
        self.fail_send = fail_send

    async def send_text(self, text):
        if self.fail_send:
            raise RuntimeError("simulated send failure")
        self.sent.append(json.loads(text))

    async def send_json(self, data):
        if self.fail_send:
            raise RuntimeError("simulated send failure")
        self.sent.append(data)


# ---------------------------------------------------------------------------
# /ws/chat
# ---------------------------------------------------------------------------

def test_ws_chat_missing_token_closes(client):
    with pytest.raises(WebSocketDisconnect) as exc_info:
        with client.websocket_connect(CHAT_WS):
            pass
    assert exc_info.value.code == 1008


def test_ws_chat_auth_via_bearer_header(client, make_user):
    user_id = make_user()
    with client.websocket_connect(CHAT_WS, headers={"Authorization": f"Bearer {_token(user_id)}"}) as ws:
        assert "Connected" in ws.receive_text()


@pytest.mark.asyncio
async def test_send_event_to_user_chat_relays_to_connected_recipient(make_user, db_cursor):
    sender_id = make_user()
    receiver_id = make_user()
    db_cursor.execute("INSERT INTO chats DEFAULT VALUES RETURNING id;")
    chat_id = db_cursor.fetchone()[0]
    db_cursor.execute(
        "INSERT INTO chat_participants (chat_id, user_id) VALUES (%s, %s), (%s, %s);",
        (chat_id, sender_id, chat_id, receiver_id),
    )
    message_id = str(uuid.uuid4())
    db_cursor.execute(
        "INSERT INTO messages (id, chat_id, sender_id, message) VALUES (%s, %s, %s, %s);",
        (message_id, chat_id, sender_id, "hi"),
    )

    from app.models.messages.message_model import ChatMessage

    receiver_ws = FakeWebSocket()
    chat_ws_module.active_connections_chats[receiver_id] = receiver_ws
    try:
        await chat_ws_module.send_event_to_user_chat(ChatMessage(
            type="chats", chats_type="message", message_id=message_id, message="hi",
            to=receiver_id, from_=sender_id, chat_room_id=chat_id,
        ))
        assert receiver_ws.sent[0]["message"] == "hi"

        db_cursor.execute(
            "SELECT unseen_count FROM chat_participants WHERE chat_id = %s AND user_id = %s;",
            (chat_id, receiver_id),
        )
        assert db_cursor.fetchone()[0] == 1
    finally:
        chat_ws_module.active_connections_chats.pop(receiver_id, None)
        db_cursor.execute("DELETE FROM messages WHERE chat_id = %s;", (chat_id,))
        db_cursor.execute("DELETE FROM chat_participants WHERE chat_id = %s;", (chat_id,))
        db_cursor.execute("DELETE FROM chats WHERE id = %s;", (chat_id,))


@pytest.mark.asyncio
async def test_send_event_to_user_chat_swallows_send_failure(make_user):
    from app.models.messages.event_models import SeenEvent

    receiver_id = make_user()
    receiver_ws = FakeWebSocket(fail_send=True)
    chat_ws_module.active_connections_chats[receiver_id] = receiver_ws
    try:
        # Should not raise even though the underlying send_text blows up.
        await chat_ws_module.send_event_to_user_chat(
            SeenEvent(type="chats", chats_type="seen", to=receiver_id, from_=1, message_id=str(uuid.uuid4()))
        )
    finally:
        chat_ws_module.active_connections_chats.pop(receiver_id, None)


def test_ws_chat_malformed_event_is_skipped(client, make_user):
    # Sends something that doesn't match ChatMessage/TypingEvent/SeenEvent -
    # the server should log-and-continue rather than close the connection.
    sender_id = make_user()
    with client.websocket_connect(f"{CHAT_WS}?token={_token(sender_id)}") as ws:
        assert "Connected" in ws.receive_text()
        ws.send_json({"type": "not-a-real-event"})

        # Connection should still be alive afterward - a valid TypingEvent
        # addressed to an offline recipient produces no reply, so instead
        # send one addressed to self to get a synchronizing echo back.
        ws.send_json({
            "type": "chats", "chats_type": "typing", "to": sender_id, "from_": sender_id,
            "chat_room_id": 1,
        })
        reply = ws.receive_json()
        assert reply["chats_type"] == "typing"


def test_ws_chat_message_persists_and_bumps_unseen_for_offline_receiver(client, make_user, db_cursor):
    # A single TestClient drives one ASGI portal thread; two simultaneously
    # open `websocket_connect` blocks on it deadlock (sender waiting to send
    # while the receiver's own connect handshake is still queued). So this
    # exercises the "receiver not connected" branch instead of live relay -
    # sender connects alone, receiver stays offline the whole time.
    sender_id = make_user()
    receiver_id = make_user()
    db_cursor.execute("INSERT INTO chats DEFAULT VALUES RETURNING id;")
    chat_id = db_cursor.fetchone()[0]
    db_cursor.execute(
        "INSERT INTO chat_participants (chat_id, user_id) VALUES (%s, %s), (%s, %s);",
        (chat_id, sender_id, chat_id, receiver_id),
    )

    message_id = str(uuid.uuid4())
    with client.websocket_connect(f"{CHAT_WS}?token={_token(sender_id)}") as sender_ws:
        assert "Connected" in sender_ws.receive_text()

        sender_ws.send_json({
            "type": "chats",
            "chats_type": "message",
            "message_id": message_id,
            "message": "hello there",
            "to": receiver_id,
            "from_": sender_id,
            "chat_room_id": chat_id,
        })

        # No reply is expected back on the sender's socket for an offline
        # recipient; send a second, self-addressed no-op event and wait for
        # it to synchronize with the server having processed the first one.
        sender_ws.send_json({
            "type": "chats",
            "chats_type": "seen",
            "to": sender_id,
            "from_": sender_id,
            "message_id": message_id,
        })
        sender_ws.receive_json()

    db_cursor.execute("SELECT message FROM messages WHERE id = %s;", (message_id,))
    assert db_cursor.fetchone()[0] == "hello there"

    db_cursor.execute(
        "SELECT unseen_count FROM chat_participants WHERE chat_id = %s AND user_id = %s;",
        (chat_id, receiver_id),
    )
    assert db_cursor.fetchone()[0] == 1

    db_cursor.execute("DELETE FROM messages WHERE chat_id = %s;", (chat_id,))
    db_cursor.execute("DELETE FROM chat_participants WHERE chat_id = %s;", (chat_id,))
    db_cursor.execute("DELETE FROM chats WHERE id = %s;", (chat_id,))


def test_add_to_unseen_and_last_message_picks_up_media_type(make_user, db_cursor):
    import app.utilities.chat.chat_utilities as chat_utilities_module

    sender_id = make_user()
    receiver_id = make_user()
    db_cursor.execute("INSERT INTO chats DEFAULT VALUES RETURNING id;")
    chat_id = db_cursor.fetchone()[0]
    db_cursor.execute(
        "INSERT INTO chat_participants (chat_id, user_id) VALUES (%s, %s), (%s, %s);",
        (chat_id, sender_id, chat_id, receiver_id),
    )
    message_id = str(uuid.uuid4())
    db_cursor.execute(
        "INSERT INTO messages (id, chat_id, sender_id, message) VALUES (%s, %s, %s, %s);",
        (message_id, chat_id, sender_id, "img"),
    )
    db_cursor.execute(
        """
        INSERT INTO media_files (message_id, file_key, media_type, size_bytes, metadata, user_id)
        VALUES (%s, 'sw/media/x.webp', 'image', 100, '{}', %s);
        """,
        (message_id, sender_id),
    )

    chat_utilities_module.add_to_unseen_and_last_message(
        receiver_id=receiver_id, chat_room_id=chat_id, message_id=message_id
    )

    db_cursor.execute("SELECT last_message_media_type FROM chats WHERE id = %s;", (chat_id,))
    assert db_cursor.fetchone()[0] == "image"

    db_cursor.execute("DELETE FROM media_files WHERE message_id = %s;", (message_id,))
    db_cursor.execute("DELETE FROM messages WHERE chat_id = %s;", (chat_id,))
    db_cursor.execute("DELETE FROM chat_participants WHERE chat_id = %s;", (chat_id,))
    db_cursor.execute("DELETE FROM chats WHERE id = %s;", (chat_id,))


def test_add_to_unseen_and_last_message_rolls_back_on_error(monkeypatch):
    import app.utilities.chat.chat_utilities as chat_utilities_module

    class FailingCursor:
        def execute(self, *a, **kw):
            raise RuntimeError("simulated failure")

        def __enter__(self):
            return self

        def __exit__(self, *a):
            return False

    class FakeConn:
        def cursor(self):
            return FailingCursor()

        def commit(self):
            pass

        def rollback(self):
            self.rolled_back = True

    fake_conn = FakeConn()
    monkeypatch.setattr(chat_utilities_module.db_pool, "getconn", lambda: fake_conn)
    monkeypatch.setattr(chat_utilities_module.db_pool, "putconn", lambda conn: None)

    # Should not raise - the failure is caught and logged internally.
    chat_utilities_module.add_to_unseen_and_last_message(
        receiver_id=1, chat_room_id=1, message_id=str(uuid.uuid4())
    )
    assert fake_conn.rolled_back is True


# ---------------------------------------------------------------------------
# /ws/connections
# ---------------------------------------------------------------------------

def test_ws_connections_missing_token_closes(client):
    with pytest.raises(WebSocketDisconnect) as exc_info:
        with client.websocket_connect(CONNECTIONS_WS):
            pass
    assert exc_info.value.code == 1008


def test_ws_connections_auth_via_bearer_header(client, make_user):
    user_id = make_user()
    with client.websocket_connect(
        CONNECTIONS_WS, headers={"Authorization": f"Bearer {_token(user_id)}"}
    ) as ws:
        assert "Connected" in ws.receive_text()
        # Exercise the no-op message-listening loop before disconnecting.
        ws.send_json({"anything": "goes"})


@pytest.mark.asyncio
async def test_send_event_to_user_connection_swallows_send_failure(make_user):
    from app.routes.matches.connections_websocket_endpoints import DataModel

    user_id = make_user()
    ws = FakeWebSocket(fail_send=True)
    connections_ws_module.active_connections_connections[user_id] = ws
    try:
        # Should not raise even though the underlying send_text blows up.
        await connections_ws_module.send_event_to_user_connection(
            DataModel(from_=1, to=user_id, type="connections-reload", sub_type="like")
        )
    finally:
        connections_ws_module.active_connections_connections.pop(user_id, None)


def test_ws_connections_receives_reload_on_start_chat(client, make_user, auth_header, db_cursor):
    user_a = make_user()
    user_b = make_user()
    db_cursor.execute(
        "INSERT INTO matches (user1_id, user2_id) VALUES (%s, %s);", (user_a, user_b)
    )

    chat_id = None
    with client.websocket_connect(f"{CONNECTIONS_WS}?token={_token(user_a)}") as ws:
        assert "Connected" in ws.receive_text()

        resp = client.post(START_CHAT, json={"id": user_b}, headers=auth_header(user_a))
        assert resp.status_code == 200, resp.text
        chat_id = resp.json()["chat_room_id"]

        event = ws.receive_json()
        assert event["type"] == "connections-reload"
        assert event["sub_type"] == "chat"

    db_cursor.execute("DELETE FROM chat_participants WHERE chat_id = %s;", (chat_id,))
    db_cursor.execute("DELETE FROM chats WHERE id = %s;", (chat_id,))


# ---------------------------------------------------------------------------
# /ws/lobby - connection handshake
# ---------------------------------------------------------------------------

def test_ws_lobby_missing_token_closes(client):
    with pytest.raises(WebSocketDisconnect) as exc_info:
        with client.websocket_connect(LOBBY_WS):
            pass
    assert exc_info.value.code == 1008


def test_ws_lobby_connect_sends_status(client, make_user):
    user_id = make_user()
    with client.websocket_connect(f"{LOBBY_WS}?token={_token(user_id)}") as ws:
        assert "Connected" in ws.receive_text()
        status = ws.receive_json()
        assert status["type"] == "lobby"
        assert status["event"] in ("event-start", "event-end")
        # Exercise the no-op message-listening loop before disconnecting.
        ws.send_json({"anything": "goes"})


def test_ws_lobby_auth_via_bearer_header(client, make_user):
    user_id = make_user()
    with client.websocket_connect(
        LOBBY_WS, headers={"Authorization": f"Bearer {_token(user_id)}"}
    ) as ws:
        assert "Connected" in ws.receive_text()


# ---------------------------------------------------------------------------
# /ws/lobby - matchmaking logic (get_lobby_users), exercised directly against
# fake sockets rather than through the 20:00 IST cron / 5-minute wait.
# ---------------------------------------------------------------------------

@pytest.mark.asyncio
async def test_get_lobby_users_no_connected_users_returns_early():
    assert lobby_module.active_connections == {}
    assert await lobby_module.get_lobby_users() == {}


@pytest.mark.asyncio
async def test_start_waiting_period_runs_matchmaking(make_user, db_cursor, monkeypatch):
    # Skips the real 5-minute wait so the cron-triggered flow (event-start
    # broadcast -> wait -> matchmaking -> event flags reset) can be tested
    # directly instead of only via get_lobby_users().
    async def _no_sleep(seconds):
        return None

    monkeypatch.setattr(lobby_module.asyncio, "sleep", _no_sleep)

    user_a = make_user(preferences={"interested_gender": "Male"})
    user_b = make_user(preferences={"interested_gender": "Male"})
    ws_a, ws_b = FakeWebSocket(), FakeWebSocket()
    lobby_module.active_connections[user_a] = ws_a
    lobby_module.active_connections[user_b] = ws_b

    try:
        await lobby_module.start_waiting_period()

        assert lobby_module.event_active is False
        assert any(msg.get("event") == "event-start" for msg in ws_a.sent)
        assert any(msg.get("matched") is True for msg in ws_a.sent)
        assert any(msg.get("matched") is True for msg in ws_b.sent)
    finally:
        lobby_module.active_connections.pop(user_a, None)
        lobby_module.active_connections.pop(user_b, None)
        lobby_module.event_active = False
        lobby_module.event_end_time = None
        db_cursor.execute(
            "DELETE FROM matches WHERE (user1_id = %s AND user2_id = %s) OR (user1_id = %s AND user2_id = %s);",
            (user_a, user_b, user_b, user_a),
        )


@pytest.mark.asyncio
async def test_get_lobby_users_matches_mutual_preference(make_user, db_cursor):
    user_a = make_user(preferences={"interested_gender": "Male"})
    user_b = make_user(preferences={"interested_gender": "Male"})
    ws_a, ws_b = FakeWebSocket(), FakeWebSocket()
    lobby_module.active_connections[user_a] = ws_a
    lobby_module.active_connections[user_b] = ws_b

    try:
        await lobby_module.get_lobby_users()

        db_cursor.execute(
            """
            SELECT COUNT(*) FROM matches
            WHERE (user1_id = %s AND user2_id = %s) OR (user1_id = %s AND user2_id = %s);
            """,
            (user_a, user_b, user_b, user_a),
        )
        assert db_cursor.fetchone()[0] == 1
        assert any(msg.get("matched") is True for msg in ws_a.sent)
        assert any(msg.get("matched") is True for msg in ws_b.sent)
    finally:
        lobby_module.active_connections.pop(user_a, None)
        lobby_module.active_connections.pop(user_b, None)
        db_cursor.execute(
            """
            DELETE FROM matches
            WHERE (user1_id = %s AND user2_id = %s) OR (user1_id = %s AND user2_id = %s);
            """,
            (user_a, user_b, user_b, user_a),
        )


@pytest.mark.asyncio
async def test_get_lobby_users_no_candidate_sends_not_matched(make_user):
    user_a = make_user(preferences={"interested_gender": "Male"})
    ws_a = FakeWebSocket()
    lobby_module.active_connections[user_a] = ws_a

    try:
        await lobby_module.get_lobby_users()
        assert any(msg.get("matched") is False for msg in ws_a.sent)
    finally:
        lobby_module.active_connections.pop(user_a, None)


@pytest.mark.asyncio
async def test_get_lobby_users_excludes_existing_match(make_user, db_cursor):
    user_a = make_user(preferences={"interested_gender": "Male"})
    user_b = make_user(preferences={"interested_gender": "Male"})
    db_cursor.execute(
        "INSERT INTO matches (user1_id, user2_id) VALUES (%s, %s);", (user_a, user_b)
    )
    ws_a, ws_b = FakeWebSocket(), FakeWebSocket()
    lobby_module.active_connections[user_a] = ws_a
    lobby_module.active_connections[user_b] = ws_b

    try:
        await lobby_module.get_lobby_users()

        assert any(msg.get("matched") is False for msg in ws_a.sent)
        assert any(msg.get("matched") is False for msg in ws_b.sent)
    finally:
        lobby_module.active_connections.pop(user_a, None)
        lobby_module.active_connections.pop(user_b, None)
        db_cursor.execute(
            "DELETE FROM matches WHERE user1_id = %s AND user2_id = %s;", (user_a, user_b)
        )
