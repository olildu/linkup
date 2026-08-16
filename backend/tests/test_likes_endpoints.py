"""Covers /likes/received, /likes/count, /likes/{id}/like-back, /likes/{id}/pass.
"""
import pytest

from app.features.likes.likes_utilities import get_unseen_likes_count, mark_likes_seen

RECEIVED = "/api/v1/likes/received"
COUNT = "/api/v1/likes/count"
LIKE_BACK = "/api/v1/likes/{}/like-back"
PASS = "/api/v1/likes/{}/pass"

PFP = {"file_key": "sw/profile_pictures/1/pfp.webp"}


def _like(db_cursor, liker_id: int, liked_id: int, created_at: str):
    db_cursor.execute(
        "INSERT INTO likes (liker_id, liked_id, liked, created_at) VALUES (%s, %s, TRUE, %s);",
        (liker_id, liked_id, created_at),
    )


def test_received_first_entry_revealed_others_teaser(client, make_user, auth_header, db_cursor):
    target_id = make_user()
    liker_0 = make_user(profile_picture=PFP)
    liker_1 = make_user()
    _like(db_cursor, liker_0, target_id, "2024-01-01 00:00:00")
    _like(db_cursor, liker_1, target_id, "2024-01-02 00:00:00")

    resp = client.get(RECEIVED, headers=auth_header(target_id))

    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["total_count"] == 2
    entries = body["entries"]
    assert entries[0]["id"] == liker_0
    assert entries[0]["revealed"] is True
    assert entries[0]["profile"] is not None
    assert entries[1]["id"] == liker_1
    assert entries[1]["revealed"] is False
    assert entries[1]["profile"] is None


def test_received_marks_seen_and_updates_unseen_count(client, make_user, auth_header, db_cursor):
    # The old dedicated /likes/unseen-count endpoint was removed in favor of
    # unseen_count living in /received's own response - and /received marks
    # likes seen as part of the same request that reports the count, so an
    # HTTP-level "before/after" observation isn't possible anymore. Exercise
    # the underlying mark_likes_seen/get_unseen_likes_count functions
    # directly instead, same as /received does internally.
    target_id = make_user()
    liker_id = make_user(profile_picture=PFP)
    _like(db_cursor, liker_id, target_id, "2024-01-01 00:00:00")

    assert get_unseen_likes_count(target_id, db_cursor) == 1

    mark_likes_seen(target_id, [liker_id], db_cursor)
    db_cursor.connection.commit()

    assert get_unseen_likes_count(target_id, db_cursor) == 0

    # /received still reports the now-0 count in its response body.
    resp = client.get(RECEIVED, headers=auth_header(target_id))
    assert resp.json()["unseen_count"] == 0


def test_received_no_token_401(client):
    resp = client.get(RECEIVED)
    assert resp.status_code == 401


def test_received_empty_when_no_likes(client, make_user, auth_header):
    target_id = make_user()
    resp = client.get(RECEIVED, headers=auth_header(target_id))

    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["entries"] == []
    assert body["total_count"] == 0
    assert body["unseen_count"] == 0


def test_count_no_token_401(client):
    resp = client.get(COUNT)
    assert resp.status_code == 401


def test_count_empty_when_no_likes(client, make_user, auth_header):
    target_id = make_user()
    resp = client.get(COUNT, headers=auth_header(target_id))

    assert resp.status_code == 200, resp.text
    assert resp.json() == {"total_count": 0}


def test_count_reflects_pending_likes(client, make_user, auth_header, db_cursor):
    target_id = make_user()
    liker_0 = make_user()
    liker_1 = make_user()
    _like(db_cursor, liker_0, target_id, "2024-01-01 00:00:00")
    _like(db_cursor, liker_1, target_id, "2024-01-02 00:00:00")

    resp = client.get(COUNT, headers=auth_header(target_id))

    assert resp.status_code == 200, resp.text
    assert resp.json() == {"total_count": 2}


def test_count_unaffected_by_received_seen_state(client, make_user, auth_header, db_cursor):
    # /count is deliberately independent of the seen/unseen tracking that
    # /received mutates - a like stays "pending" (not yet responded to)
    # regardless of whether it's been viewed.
    target_id = make_user()
    liker_id = make_user()
    _like(db_cursor, liker_id, target_id, "2024-01-01 00:00:00")

    client.get(RECEIVED, headers=auth_header(target_id))  # marks it seen

    resp = client.get(COUNT, headers=auth_header(target_id))
    assert resp.json() == {"total_count": 1}


def test_count_excludes_already_reciprocated_like(client, make_user, auth_header, db_cursor):
    target_id = make_user()
    liker_id = make_user()
    _like(db_cursor, liker_id, target_id, "2024-01-01 00:00:00")
    # target_id already liked liker_id back - no longer "pending".
    _like(db_cursor, target_id, liker_id, "2024-01-01 00:00:01")

    resp = client.get(COUNT, headers=auth_header(target_id))
    assert resp.json() == {"total_count": 0}


def test_count_excludes_already_matched_user(client, make_user, auth_header, db_cursor):
    target_id = make_user()
    liker_id = make_user()
    _like(db_cursor, liker_id, target_id, "2024-01-01 00:00:00")
    db_cursor.execute(
        "INSERT INTO matches (user1_id, user2_id) VALUES (%s, %s);", (target_id, liker_id)
    )

    resp = client.get(COUNT, headers=auth_header(target_id))
    assert resp.json() == {"total_count": 0}

    db_cursor.execute(
        "DELETE FROM matches WHERE user1_id = %s AND user2_id = %s;", (target_id, liker_id)
    )


def test_count_excludes_blocked_user(client, make_user, auth_header, db_cursor):
    target_id = make_user()
    liker_id = make_user()
    _like(db_cursor, liker_id, target_id, "2024-01-01 00:00:00")
    db_cursor.execute(
        "INSERT INTO blocked_users (blocker_id, blocked_id) VALUES (%s, %s);", (target_id, liker_id)
    )

    resp = client.get(COUNT, headers=auth_header(target_id))
    assert resp.json() == {"total_count": 0}

    db_cursor.execute(
        "DELETE FROM blocked_users WHERE blocker_id = %s AND blocked_id = %s;", (target_id, liker_id)
    )


def test_like_back_success_creates_match(client, make_user, auth_header, db_cursor):
    liker_id = make_user(profile_picture=PFP)
    current_id = make_user(profile_picture=PFP)
    _like(db_cursor, liker_id, current_id, "2024-01-01 00:00:00")

    resp = client.post(LIKE_BACK.format(liker_id), headers=auth_header(current_id))

    assert resp.status_code == 200, resp.text
    assert resp.json()["match"] is True

    db_cursor.execute(
        """
        SELECT COUNT(*) FROM matches
        WHERE (user1_id = %s AND user2_id = %s) OR (user1_id = %s AND user2_id = %s);
        """,
        (liker_id, current_id, current_id, liker_id),
    )
    assert db_cursor.fetchone()[0] == 1


def test_like_back_not_actually_liked_400(client, make_user, auth_header):
    liker_id = make_user()
    current_id = make_user()

    resp = client.post(LIKE_BACK.format(liker_id), headers=auth_header(current_id))

    assert resp.status_code == 400


def test_pass_records_dislike(client, make_user, auth_header, db_cursor):
    liker_id = make_user()
    current_id = make_user()
    _like(db_cursor, liker_id, current_id, "2024-01-01 00:00:00")

    resp = client.post(PASS.format(liker_id), headers=auth_header(current_id))

    assert resp.status_code == 200, resp.text
    db_cursor.execute(
        "SELECT liked FROM likes WHERE liker_id = %s AND liked_id = %s;", (current_id, liker_id)
    )
    assert db_cursor.fetchone()[0] is False


def test_pass_not_actually_liked_400(client, make_user, auth_header):
    liker_id = make_user()
    current_id = make_user()

    resp = client.post(PASS.format(liker_id), headers=auth_header(current_id))

    assert resp.status_code == 400
