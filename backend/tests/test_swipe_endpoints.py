"""Covers /swipe/right and /swipe/left."""
import pytest

from app.core.constants.global_constants import DAILY_LIKE_LIMIT

SWIPE_RIGHT = "/api/v1/swipe/right"
SWIPE_LEFT = "/api/v1/swipe/left"


def _put_in_queue(db_cursor, user_id: int, target_id: int):
    db_cursor.execute(
        """
        INSERT INTO user_discovery_pool (user_id, match_queue)
        VALUES (%s, %s)
        ON CONFLICT (user_id) DO UPDATE SET match_queue = EXCLUDED.match_queue;
        """,
        (user_id, [target_id]),
    )


def test_swipe_right_records_like_no_match(client, make_user, auth_header, db_cursor):
    liker_id = make_user()
    liked_id = make_user()
    _put_in_queue(db_cursor, liker_id, liked_id)

    resp = client.post(SWIPE_RIGHT, json={"liked_id": liked_id}, headers=auth_header(liker_id))

    assert resp.status_code == 200, resp.text
    assert resp.json()["match"] is False

    db_cursor.execute(
        "SELECT liked FROM likes WHERE liker_id = %s AND liked_id = %s;", (liker_id, liked_id)
    )
    assert db_cursor.fetchone()[0] is True


def test_swipe_right_not_in_queue_400(client, make_user, auth_header):
    liker_id = make_user()
    liked_id = make_user()

    resp = client.post(SWIPE_RIGHT, json={"liked_id": liked_id}, headers=auth_header(liker_id))

    assert resp.status_code == 400


def test_swipe_right_daily_limit_429(client, make_user, auth_header, db_cursor):
    liker_id = make_user()
    liked_id = make_user()
    _put_in_queue(db_cursor, liker_id, liked_id)

    for _ in range(DAILY_LIKE_LIMIT):
        other_id = make_user()
        db_cursor.execute(
            "INSERT INTO likes (liker_id, liked_id, liked) VALUES (%s, %s, TRUE);",
            (liker_id, other_id),
        )

    resp = client.post(SWIPE_RIGHT, json={"liked_id": liked_id}, headers=auth_header(liker_id))

    assert resp.status_code == 429


def test_swipe_right_mutual_creates_match(client, make_user, auth_header, db_cursor):
    # process_like's match branch calls get_signed_imagekit(match_user_profile_picture)
    # unconditionally, which crashes on a NULL profile_picture (see
    # test_swipe_right_mutual_match_crashes_without_profile_picture below) -
    # user_a needs one set for this happy-path test to actually reach 200.
    user_a = make_user(profile_picture={"file_key": "sw/profile_pictures/1/pfp.webp"})
    user_b = make_user()
    _put_in_queue(db_cursor, user_a, user_b)
    _put_in_queue(db_cursor, user_b, user_a)

    resp_a = client.post(SWIPE_RIGHT, json={"liked_id": user_b}, headers=auth_header(user_a))
    assert resp_a.status_code == 200, resp_a.text
    assert resp_a.json()["match"] is False

    resp_b = client.post(SWIPE_RIGHT, json={"liked_id": user_a}, headers=auth_header(user_b))
    assert resp_b.status_code == 200, resp_b.text
    assert resp_b.json()["match"] is True

    db_cursor.execute(
        """
        SELECT COUNT(*) FROM matches
        WHERE (user1_id = %s AND user2_id = %s) OR (user1_id = %s AND user2_id = %s);
        """,
        (user_a, user_b, user_b, user_a),
    )
    assert db_cursor.fetchone()[0] == 1


def test_swipe_right_mutual_match_crashes_without_profile_picture(
    client, make_user, auth_header, db_cursor
):
    # Documents an existing bug: process_like() builds the "matched_user"
    # payload via get_signed_imagekit(profile_picture) with no null check.
    # Any user without a profile_picture set (the default for a freshly
    # created account) causes a 500 instead of a successful match response
    # for whichever side of the swipe completes the match.
    user_a = make_user()
    user_b = make_user()
    _put_in_queue(db_cursor, user_a, user_b)
    _put_in_queue(db_cursor, user_b, user_a)

    client.post(SWIPE_RIGHT, json={"liked_id": user_b}, headers=auth_header(user_a))
    resp_b = client.post(SWIPE_RIGHT, json={"liked_id": user_a}, headers=auth_header(user_b))

    assert resp_b.status_code == 500


def test_swipe_right_no_token_401(client):
    resp = client.post(SWIPE_RIGHT, json={"liked_id": 1})
    assert resp.status_code == 401


def test_swipe_left_records_dislike(client, make_user, auth_header, db_cursor):
    liker_id = make_user()
    liked_id = make_user()
    _put_in_queue(db_cursor, liker_id, liked_id)

    resp = client.post(SWIPE_LEFT, json={"liked_id": liked_id}, headers=auth_header(liker_id))

    assert resp.status_code == 200, resp.text
    db_cursor.execute(
        "SELECT liked FROM likes WHERE liker_id = %s AND liked_id = %s;", (liker_id, liked_id)
    )
    assert db_cursor.fetchone()[0] is False


def test_swipe_left_not_in_queue_400(client, make_user, auth_header):
    liker_id = make_user()
    liked_id = make_user()

    resp = client.post(SWIPE_LEFT, json={"liked_id": liked_id}, headers=auth_header(liker_id))

    assert resp.status_code == 400
