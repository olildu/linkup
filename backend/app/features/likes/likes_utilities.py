import ast

from app.features.discovery.models.match_canidate_model import build_candidate_model
from app.core.common_utilites import get_signed_imagekit


def get_pending_liker_ids(user_id: int, cursor) -> list[int]:
    """
    All users who have liked `user_id` and haven't been responded to yet
    (via a normal swipe or a like-back/pass), oldest-first, excluding
    deleted/blocked/already-matched users.
    """
    cursor.execute("""
        SELECT likes.liker_id
        FROM likes
        JOIN users ON users.id = likes.liker_id
        WHERE likes.liked_id = %(me)s
          AND likes.liked = TRUE
          AND users.is_deleted = FALSE
          AND NOT EXISTS (
              SELECT 1 FROM likes AS reverse
              WHERE reverse.liker_id = %(me)s AND reverse.liked_id = likes.liker_id
          )
          AND NOT EXISTS (
              SELECT 1 FROM blocked_users b
              WHERE (b.blocker_id = %(me)s AND b.blocked_id = likes.liker_id)
                 OR (b.blocker_id = likes.liker_id AND b.blocked_id = %(me)s)
          )
          AND NOT EXISTS (
              SELECT 1 FROM matches m
              WHERE (m.user1_id = %(me)s AND m.user2_id = likes.liker_id)
                 OR (m.user1_id = likes.liker_id AND m.user2_id = %(me)s)
          )
        ORDER BY likes.created_at ASC;
    """, {"me": user_id})

    return [row[0] for row in cursor.fetchall()]


def get_pending_likes_count(user_id: int, cursor) -> int:
    """
    Lightweight count-only version of get_pending_liker_ids — same
    eligibility filters, no row data, for cheap badge polling.
    """
    cursor.execute("""
        SELECT COUNT(*)
        FROM likes
        JOIN users ON users.id = likes.liker_id
        WHERE likes.liked_id = %(me)s
          AND likes.liked = TRUE
          AND users.is_deleted = FALSE
          AND NOT EXISTS (
              SELECT 1 FROM likes AS reverse
              WHERE reverse.liker_id = %(me)s AND reverse.liked_id = likes.liker_id
          )
          AND NOT EXISTS (
              SELECT 1 FROM blocked_users b
              WHERE (b.blocker_id = %(me)s AND b.blocked_id = likes.liker_id)
                 OR (b.blocker_id = likes.liker_id AND b.blocked_id = %(me)s)
          )
          AND NOT EXISTS (
              SELECT 1 FROM matches m
              WHERE (m.user1_id = %(me)s AND m.user2_id = likes.liker_id)
                 OR (m.user1_id = likes.liker_id AND m.user2_id = %(me)s)
          );
    """, {"me": user_id})
    return cursor.fetchone()[0]


def get_unseen_likes_count(user_id: int, cursor) -> int:
    cursor.execute("""
        SELECT COUNT(*) FROM likes
        WHERE liked_id = %s AND liked = TRUE AND seen_at IS NULL;
    """, (user_id,))
    return cursor.fetchone()[0]


def mark_likes_seen(user_id: int, liker_ids: list[int], cursor):
    if not liker_ids:
        return
    cursor.execute("""
        UPDATE likes
        SET seen_at = NOW()
        WHERE liked_id = %s AND liked = TRUE AND seen_at IS NULL
          AND liker_id = ANY(%s);
    """, (user_id, liker_ids))


def build_full_profile(user_id: int, cursor) -> dict:
    cursor.execute("""
        SELECT id, username, gender, university_id, profile_picture::text
        FROM users WHERE id = %s;
    """, (user_id,))
    core_data = cursor.fetchone()

    cursor.execute("SELECT key, value FROM user_metadata WHERE user_id = %s", (user_id,))
    user_metadata = {key: value for key, value in cursor.fetchall()}

    return build_candidate_model(user_metadata, core_data).model_dump()


def build_first_photo(user_id: int, cursor) -> dict | None:
    cursor.execute("SELECT value FROM user_metadata WHERE user_id = %s AND key = 'photos';", (user_id,))
    row = cursor.fetchone()
    photos = ast.literal_eval(row[0]) if row and row[0] else []
    return get_signed_imagekit(photos[0]) if photos else None
