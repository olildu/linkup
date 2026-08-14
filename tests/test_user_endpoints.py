"""Covers /user/report, /user/delete, /user/block, /user/get/detail/{id},
/user/get/preferences, /user/update/metadata, /user/update/preferences.
"""
import pytest

REPORT = "/api/v1/user/report"
DELETE = "/api/v1/user/delete"
BLOCK = "/api/v1/user/block"
GET_DETAIL = "/api/v1/user/get/detail/{}"
GET_PREFERENCES = "/api/v1/user/get/preferences"
UPDATE_METADATA = "/api/v1/user/update/metadata"
UPDATE_PREFERENCES = "/api/v1/user/update/preferences"


# ---------------------------------------------------------------------------
# /user/report
# ---------------------------------------------------------------------------

def test_report_user_success(client, make_user, auth_header, db_cursor):
    reporter_id = make_user()
    reported_id = make_user()

    resp = client.post(
        REPORT,
        json={"reported_user_id": reported_id, "reason": "spam"},
        headers=auth_header(reporter_id),
    )

    assert resp.status_code == 200, resp.text
    db_cursor.execute(
        "SELECT reason FROM reported_users WHERE reporter_id = %s AND reported_id = %s;",
        (reporter_id, reported_id),
    )
    assert db_cursor.fetchone()[0] == "spam"

    # reported_users has no ON DELETE CASCADE on its user FKs, so it must be
    # cleared before make_user's teardown deletes the users rows.
    db_cursor.execute("DELETE FROM reported_users WHERE reporter_id = %s;", (reporter_id,))


def test_report_user_no_token_401(client):
    resp = client.post(REPORT, json={"reported_user_id": 1, "reason": "spam"})
    assert resp.status_code == 401


# ---------------------------------------------------------------------------
# /user/delete
# ---------------------------------------------------------------------------

def test_delete_account_success(client, make_user, auth_header, db_cursor):
    user_id = make_user()

    resp = client.delete(DELETE, headers=auth_header(user_id))

    assert resp.status_code == 200, resp.text
    db_cursor.execute(
        "SELECT username, password_hash, is_deleted FROM users WHERE id = %s;", (user_id,)
    )
    username, password_hash, is_deleted = db_cursor.fetchone()
    assert username == "Deleted Account"
    assert password_hash == "deleted"
    assert is_deleted is True

    db_cursor.execute("SELECT COUNT(*) FROM user_metadata WHERE user_id = %s;", (user_id,))
    assert db_cursor.fetchone()[0] == 0
    db_cursor.execute("SELECT COUNT(*) FROM user_preferences WHERE user_id = %s;", (user_id,))
    assert db_cursor.fetchone()[0] == 0


# ---------------------------------------------------------------------------
# /user/block
# ---------------------------------------------------------------------------

def test_block_user_removes_match_and_chat(client, make_user, auth_header, db_cursor):
    blocker_id = make_user()
    blocked_id = make_user()

    db_cursor.execute(
        "INSERT INTO matches (user1_id, user2_id) VALUES (%s, %s);", (blocker_id, blocked_id)
    )
    db_cursor.execute("INSERT INTO chats DEFAULT VALUES RETURNING id;")
    chat_id = db_cursor.fetchone()[0]
    db_cursor.execute(
        "INSERT INTO chat_participants (chat_id, user_id) VALUES (%s, %s), (%s, %s);",
        (chat_id, blocker_id, chat_id, blocked_id),
    )

    resp = client.post(BLOCK, json={"blocked_user_id": blocked_id}, headers=auth_header(blocker_id))

    assert resp.status_code == 200, resp.text

    db_cursor.execute(
        "SELECT COUNT(*) FROM matches WHERE user1_id = %s AND user2_id = %s;",
        (blocker_id, blocked_id),
    )
    assert db_cursor.fetchone()[0] == 0

    db_cursor.execute("SELECT COUNT(*) FROM chats WHERE id = %s;", (chat_id,))
    assert db_cursor.fetchone()[0] == 0

    db_cursor.execute(
        "SELECT COUNT(*) FROM blocked_users WHERE blocker_id = %s AND blocked_id = %s;",
        (blocker_id, blocked_id),
    )
    assert db_cursor.fetchone()[0] == 1

    # blocked_users has no ON DELETE CASCADE on its user FKs, so it must be
    # cleared before make_user's teardown deletes the users rows.
    db_cursor.execute("DELETE FROM blocked_users WHERE blocker_id = %s;", (blocker_id,))


# ---------------------------------------------------------------------------
# /user/get/detail/{user_id}
# ---------------------------------------------------------------------------

def test_get_detail_self_allowed(client, make_user, auth_header):
    user_id = make_user()
    resp = client.get(GET_DETAIL.format(user_id), headers=auth_header(user_id))
    assert resp.status_code == 200, resp.text


def test_get_detail_unrelated_user_forbidden(client, make_user, auth_header):
    requester_id = make_user()
    target_id = make_user()

    resp = client.get(GET_DETAIL.format(target_id), headers=auth_header(requester_id))

    assert resp.status_code == 403


def test_get_detail_matched_user_allowed(client, make_user, auth_header, db_cursor):
    requester_id = make_user()
    target_id = make_user()
    db_cursor.execute(
        "INSERT INTO matches (user1_id, user2_id) VALUES (%s, %s);", (requester_id, target_id)
    )

    resp = client.get(GET_DETAIL.format(target_id), headers=auth_header(requester_id))

    assert resp.status_code == 200, resp.text
    assert resp.json()["id"] == target_id


def test_get_detail_nonexistent_user_404(client, auth_header):
    # requester_id == user_id (self-view) skips the authz relationship
    # check, so this hits get_user_details' own `if not user_row: raise 404`.
    resp = client.get(GET_DETAIL.format(999999999), headers=auth_header(999999999))
    assert resp.status_code == 404


def test_get_detail_malformed_metadata_falls_back_to_none(client, make_user, auth_header, db_cursor):
    # build_user_model's parse_date/profile_picture parsing both swallow
    # errors and fall back to None rather than raising - verified by
    # corrupting the stored dob and profile_picture directly.
    user_id = make_user(profile_picture={"file_key": "x"})
    db_cursor.execute(
        "UPDATE user_metadata SET value = 'not-a-date' WHERE user_id = %s AND key = 'dob';",
        (user_id,),
    )
    db_cursor.execute(
        "UPDATE users SET profile_picture = '\"not-a-json-object\"' WHERE id = %s;", (user_id,)
    )

    resp = client.get(GET_DETAIL.format(user_id), headers=auth_header(user_id))

    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["dob"] is None
    assert body["profile_picture"] is None


def test_get_detail_no_token_401(client, make_user):
    user_id = make_user()
    resp = client.get(GET_DETAIL.format(user_id))
    assert resp.status_code == 401


def test_get_detail_malformed_token_401(client, make_user):
    user_id = make_user()
    resp = client.get(
        GET_DETAIL.format(user_id), headers={"Authorization": "Bearer not-a-jwt-at-all"}
    )
    assert resp.status_code == 401


# ---------------------------------------------------------------------------
# /user/get/preferences
# ---------------------------------------------------------------------------

def test_get_preferences_populated(client, make_user, auth_header):
    user_id = make_user(preferences={"interested_gender": "Male"})
    resp = client.get(GET_PREFERENCES, headers=auth_header(user_id))

    assert resp.status_code == 200, resp.text
    assert resp.json()["interested_gender"] == "Male"


def test_get_preferences_empty(client, make_user, auth_header, db_cursor):
    # make_user's `preferences or {"interested_gender": "Female"}` default
    # treats an explicitly empty dict as falsy, so it still seeds a row -
    # delete it afterward to exercise the true no-preferences path.
    user_id = make_user()
    db_cursor.execute("DELETE FROM user_preferences WHERE user_id = %s;", (user_id,))

    resp = client.get(GET_PREFERENCES, headers=auth_header(user_id))

    assert resp.status_code == 200, resp.text
    assert "No preferences found" in resp.json()["message"]


# ---------------------------------------------------------------------------
# /user/update/metadata
# ---------------------------------------------------------------------------

def test_update_metadata_upsert_overwrites_existing(client, make_user, auth_header, db_cursor):
    user_id = make_user(metadata={"about": "old bio"})

    resp = client.post(UPDATE_METADATA, json={"about": "new bio"}, headers=auth_header(user_id))

    assert resp.status_code == 200, resp.text
    db_cursor.execute(
        "SELECT value FROM user_metadata WHERE user_id = %s AND key = 'about';", (user_id,)
    )
    assert db_cursor.fetchone()[0] == "new bio"


def test_update_metadata_malformed_token_401(client):
    resp = client.post(
        UPDATE_METADATA, json={"about": "x"}, headers={"Authorization": "Bearer not-a-jwt-at-all"}
    )
    assert resp.status_code == 401


def test_update_metadata_inserts_new_key(client, make_user, auth_header, db_cursor):
    user_id = make_user()

    resp = client.post(UPDATE_METADATA, json={"height": 180}, headers=auth_header(user_id))

    assert resp.status_code == 200, resp.text
    db_cursor.execute(
        "SELECT value FROM user_metadata WHERE user_id = %s AND key = 'height';", (user_id,)
    )
    assert db_cursor.fetchone()[0] == "180"


def test_update_metadata_empty_body_200(client, make_user, auth_header):
    # UpdateRequestModel's before-validators unconditionally set
    # smoking_status/drinking_status (True unless the corresponding *_info
    # is exactly "No"), so `update_data` is never actually empty and the
    # documented "400 No fields to update" branch is unreachable via the API.
    user_id = make_user()
    resp = client.post(UPDATE_METADATA, json={}, headers=auth_header(user_id))
    assert resp.status_code == 200, resp.text


def test_update_metadata_pfp(client, make_user, auth_header, db_cursor):
    user_id = make_user()
    resp = client.post(
        UPDATE_METADATA,
        params={"update_pfp": True},
        json={"profile_picture": {"file_key": "sw/profile_pictures/1/pfp.webp"}},
        headers=auth_header(user_id),
    )

    assert resp.status_code == 200, resp.text
    db_cursor.execute("SELECT profile_picture::text FROM users WHERE id = %s;", (user_id,))
    assert "pfp.webp" in db_cursor.fetchone()[0]


# ---------------------------------------------------------------------------
# /user/update/preferences
# ---------------------------------------------------------------------------

def test_update_preferences_sets_value(client, make_user, auth_header, db_cursor):
    user_id = make_user(preferences={})
    resp = client.post(
        UPDATE_PREFERENCES, json={"interested_gender": "Male"}, headers=auth_header(user_id)
    )

    assert resp.status_code == 200, resp.text
    db_cursor.execute(
        "SELECT value FROM user_preferences WHERE user_id = %s AND key = 'interested_gender';",
        (user_id,),
    )
    assert db_cursor.fetchone()[0] == "Male"


def test_update_preferences_none_deletes_key(client, make_user, auth_header, db_cursor):
    user_id = make_user(preferences={"interested_gender": "Male"})

    resp = client.post(
        UPDATE_PREFERENCES, json={"interested_gender": None}, headers=auth_header(user_id)
    )

    assert resp.status_code == 200, resp.text
    db_cursor.execute(
        "SELECT COUNT(*) FROM user_preferences WHERE user_id = %s AND key = 'interested_gender';",
        (user_id,),
    )
    assert db_cursor.fetchone()[0] == 0


def test_update_preferences_dont_mind_literal_rejected_by_schema(client, make_user, auth_header):
    # The route deletes the key when value == "Don't mind" (update_metadata.py
    # equivalent logic), but PreferenceModel's Literal["Male", "Female"] type
    # rejects that string at the request-validation layer, so this branch is
    # actually unreachable through the API - only an explicit `null` reaches it.
    user_id = make_user(preferences={"interested_gender": "Male"})

    resp = client.post(
        UPDATE_PREFERENCES, json={"interested_gender": "Don't mind"}, headers=auth_header(user_id)
    )

    assert resp.status_code == 422
