"""Unit tests for app/utilities/swipe/swipe_utilities.py branches not
reachable through the /swipe or /likes HTTP routes."""
import psycopg2
import pytest

from app.features.discovery.swipe_utilities import exists_in_queue, handle_post_action


def test_exists_in_queue_true(db_cursor, make_user):
    liker_id = make_user()
    liked_id = make_user()
    db_cursor.execute(
        "INSERT INTO user_discovery_pool (user_id, match_queue) VALUES (%s, %s);",
        (liker_id, [liked_id]),
    )
    assert exists_in_queue(liker_id, liked_id, db_cursor) is True


def test_exists_in_queue_false(db_cursor, make_user):
    liker_id = make_user()
    liked_id = make_user()
    assert exists_in_queue(liker_id, liked_id, db_cursor) is False


def test_handle_post_action_rolls_back_on_db_error(make_user):
    user_id = make_user()

    class FailingCursor:
        def execute(self, *a, **kw):
            raise psycopg2.Error("simulated failure")

        def close(self):
            pass

    class FailingConn:
        def cursor(self):
            return FailingCursor()

        def rollback(self):
            self.rolled_back = True

    conn = FailingConn()
    with pytest.raises(psycopg2.Error):
        handle_post_action(user_id, 1, conn)
    assert conn.rolled_back is True
