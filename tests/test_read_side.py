"""Read-side coverage: every place that turns a stored file_key into a
display URL - profile display, candidate-feed building, likes, swipe/match,
the connections list endpoint, and chat message rendering - exercised for
both new (sw/) and legacy keys.
"""
import json
import uuid

import pytest
from psycopg2.extras import Json

from app.models.match_canidate_model import build_candidate_model
from app.models.messages.message_model import ChatMessage, MediaMessageData
from app.models.user_model import build_user_model
from app.utilities.chat import chat_utilities
from app.utilities.likes.likes_utilities import build_first_photo, build_full_profile
from app.utilities.swipe.swipe_utilities import process_like

SW_PROFILE_PICTURE = {"file_key": "sw/profile_pictures/1/pfp.webp"}
LEGACY_PROFILE_PICTURE = {"file_key": "profile_pictures/1/pfp.webp"}
SW_PHOTOS = [{"file_key": "sw/media/1/a.webp"}, {"file_key": "sw/media/1/b.webp"}]


# ---------------------------------------------------------------------------
# build_user_model (own-profile display)
# ---------------------------------------------------------------------------

def test_build_user_model_signs_sw_profile_picture_and_photos():
    core_data = [1, "a@example.com", "alice", "Female", 1, json.dumps(SW_PROFILE_PICTURE)]
    user_metadata = [
        (None, 1, "dob", "2000-01-01"),
        (None, 1, "photos", repr(SW_PHOTOS)),
    ]
    user_preferences = [(None, 1, "interested_gender", "Male")]

    model = build_user_model(user_metadata, core_data, hashed_password="x", user_preferences=user_preferences)

    assert model.profile_picture["url"].startswith("http")
    assert all(p["url"].startswith("http") for p in model.photos)


def test_build_user_model_signs_legacy_profile_picture(monkeypatch):
    from app.utilities.common import common_utilites

    monkeypatch.setattr(common_utilites.imagekit, "url", lambda opts: "https://imagekit/legacy")

    core_data = [1, "a@example.com", "alice", "Female", 1, json.dumps(LEGACY_PROFILE_PICTURE)]
    model = build_user_model([], core_data, hashed_password="x", user_preferences=[])

    assert model.profile_picture["url"] == "https://imagekit/legacy"


def test_build_user_model_tolerates_missing_profile_picture():
    core_data = [1, "a@example.com", "alice", "Female", 1, None]
    model = build_user_model([], core_data, hashed_password="x", user_preferences=[])
    assert model.profile_picture is None


# ---------------------------------------------------------------------------
# build_candidate_model / build_full_profile (candidate feed + likes list)
# ---------------------------------------------------------------------------

def test_build_candidate_model_signs_sw_urls():
    user_metadata = {
        "dob": "2000-01-01",
        "university_major": "CS",
        "university_year": "2",
        "about": "hi",
        "currently_staying": "Campus Hostel",
        "hometown": "Testville",
        "photos": repr(SW_PHOTOS),
    }
    core_data = (1, "alice", "Female", 1, json.dumps(SW_PROFILE_PICTURE))

    model = build_candidate_model(user_metadata, core_data)

    assert model.profile_picture["url"].startswith("http")
    assert all(p["url"].startswith("http") for p in model.photos)


def test_build_full_profile_end_to_end_via_real_db_row(db_cursor, make_user):
    user_id = make_user(profile_picture=SW_PROFILE_PICTURE, photos=SW_PHOTOS)

    profile = build_full_profile(user_id, db_cursor)

    assert profile["profile_picture"]["url"].startswith("http")
    assert all(p["url"].startswith("http") for p in profile["photos"])


def test_build_first_photo_sw(db_cursor, make_user):
    user_id = make_user(profile_picture=SW_PROFILE_PICTURE)
    photo = build_first_photo(user_id, db_cursor)
    assert photo["url"].startswith("http")


def test_build_first_photo_raises_on_null_profile_picture(db_cursor, make_user):
    """Documented current behavior: no null-guard, so this raises rather
    than returning None. Not fixed here - just pinned so a future change is
    deliberate."""
    user_id = make_user()  # no profile_picture -> NULL column
    with pytest.raises(Exception):
        build_first_photo(user_id, db_cursor)


# ---------------------------------------------------------------------------
# swipe_utilities.process_like (match flow -> matched_user.profile_picture)
# ---------------------------------------------------------------------------

async def test_process_like_match_signs_matched_user_profile_picture(db_conn, db_cursor, make_user):
    # matched_user in the response is always the *original* liker (user_b
    # here), fetched via `likes.liker_id = liked_id, likes.liked_id = liker_id`
    # - so the profile picture under test belongs to user_b, not user_a.
    user_a = make_user()
    user_b = make_user(profile_picture=SW_PROFILE_PICTURE)

    # user_b already liked user_a - user_a liking back should produce a match.
    db_cursor.execute(
        "INSERT INTO likes (liker_id, liked_id, liked) VALUES (%s, %s, TRUE);",
        (user_b, user_a),
    )

    result = await process_like(liker_id=user_a, liked_id=user_b, conn=db_conn)

    assert result["match"] is True
    assert result["matched_user"]["profile_picture"]["url"].startswith("http")

    db_cursor.execute("DELETE FROM matches WHERE user1_id = %s OR user2_id = %s;", (user_a, user_a))


async def test_process_like_no_match(db_conn, db_cursor, make_user):
    user_a = make_user()
    user_b = make_user()

    result = await process_like(liker_id=user_a, liked_id=user_b, conn=db_conn)

    assert result["match"] is False
    db_cursor.execute("DELETE FROM likes WHERE liker_id = %s AND liked_id = %s;", (user_a, user_b))


# ---------------------------------------------------------------------------
# /matches/get-connections (the one call site with an explicit null-guard)
# ---------------------------------------------------------------------------

def test_get_connections_signs_match_profile_picture(client, db_cursor, make_user, auth_header):
    user_a = make_user()
    user_b = make_user(profile_picture=SW_PROFILE_PICTURE)
    db_cursor.execute(
        "INSERT INTO matches (user1_id, user2_id) VALUES (%s, %s);", (user_a, user_b)
    )

    resp = client.get("/api/v1/matches/get-connections", headers=auth_header(user_a))

    assert resp.status_code == 200, resp.text
    body = resp.json()
    matched = next(m for m in body["matches"] if m["id"] == user_b)
    assert matched["profile_picture"]["url"].startswith("http")

    db_cursor.execute("DELETE FROM matches WHERE user1_id = %s AND user2_id = %s;", (user_a, user_b))


def test_get_connections_handles_null_profile_picture(client, db_cursor, make_user, auth_header):
    user_a = make_user()
    user_b = make_user()  # no profile picture -> NULL
    db_cursor.execute(
        "INSERT INTO matches (user1_id, user2_id) VALUES (%s, %s);", (user_a, user_b)
    )

    resp = client.get("/api/v1/matches/get-connections", headers=auth_header(user_a))

    assert resp.status_code == 200, resp.text
    matched = next(m for m in resp.json()["matches"] if m["id"] == user_b)
    assert matched["profile_picture"] is None

    db_cursor.execute("DELETE FROM matches WHERE user1_id = %s AND user2_id = %s;", (user_a, user_b))


# ---------------------------------------------------------------------------
# Chat media: DB persistence + signed-URL dispatch on read
# ---------------------------------------------------------------------------

def test_insert_message_with_sw_media_persists_file_key(db_cursor, make_user):
    sender = make_user()
    db_cursor.execute("INSERT INTO chats DEFAULT VALUES RETURNING id;")
    chat_id = db_cursor.fetchone()[0]

    message = ChatMessage(
        message_id=str(uuid.uuid4()),
        message="",
        to=-1,
        from_=sender,
        chat_room_id=chat_id,
        type="chats",
        chats_type="message",
        media=MediaMessageData(
            mediaType="image",
            file_key="sw/media/1/chat.webp",
            blurhashText="",
            metadata={"size_bytes": 123},
        ),
    )

    inserted_id = chat_utilities.insert_message_to_db(message)

    db_cursor.execute("SELECT file_key FROM media_files WHERE message_id = %s;", (inserted_id,))
    assert db_cursor.fetchone()[0] == "sw/media/1/chat.webp"

    db_cursor.execute("DELETE FROM messages WHERE id = %s;", (inserted_id,))
    db_cursor.execute("DELETE FROM chats WHERE id = %s;", (chat_id,))


async def test_process_msg_signs_sw_media_url():
    msg = {
        "id": uuid.uuid4(),
        "reply_id": None,
        "sender_id": 1,
        "chat_id": 1,
        "message": "",
        "timestamp": None,
        "is_seen": False,
        "metadata": None,
        "file_key": "sw/media/1/chat.webp",
        "media_type": "image",
    }

    result = await chat_utilities.process_msg(msg)

    assert result.media.metadata["file_url"].startswith("http")


async def test_process_msg_dispatches_legacy_media_url(monkeypatch):
    monkeypatch.setattr(
        chat_utilities, "generate_signed_url", lambda file_key, valid_duration=3600: "https://b2/legacy-chat"
    )
    msg = {
        "id": uuid.uuid4(),
        "reply_id": None,
        "sender_id": 1,
        "chat_id": 1,
        "message": "",
        "timestamp": None,
        "is_seen": False,
        "metadata": None,
        "file_key": "media/1/chat.webp",
        "media_type": "image",
    }

    result = await chat_utilities.process_msg(msg)

    assert result.media.metadata["file_url"] == "https://b2/legacy-chat"
