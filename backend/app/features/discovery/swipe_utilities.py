import asyncio

from app.core.controllers.logger_controller import logger_controller
from app.core.common_utilites import get_signed_imagekit


def exists_in_queue(liker_id, liked_id, cursor):
    cursor.execute("""
        SELECT EXISTS (
            SELECT 1
            FROM user_discovery_pool
            WHERE user_id = %s
            AND %s = ANY(match_queue)
        ) AS exists_in_queue;
    """,  (liker_id, liked_id))

    result = cursor.fetchone()

    logger_controller.info(f"User {liker_id} exists in match queue for user {liked_id}")

    return result[0]

def handle_post_action(user_id: int, val: int, conn):
    """
    Remove `val` from match_queue array, and add `val` to already_interacted array
    for the user identified by user_id.
    """
    cursor = conn.cursor()
    try:
        cursor.execute("""
            UPDATE user_discovery_pool
            SET 
                match_queue = array_remove(match_queue, %s),
                already_interacted = array_append(COALESCE(already_interacted, '{}'), %s)
            WHERE user_id = %s
            RETURNING match_queue, already_interacted;
        """, (val, val, user_id))

        updated = cursor.fetchone()
        conn.commit()
        cursor.close()

        return updated

    except Exception as e:
        conn.rollback()
        cursor.close()
        logger_controller.error(f"Error handling post action for user {user_id}: {e}")
        raise e

def update_discovery_and_post_action(liker_id: int, liked_id: int, conn):
    with conn.cursor() as cursor:
        cursor.execute("""
            UPDATE user_discovery_pool
            SET match_queue = array_remove(match_queue, %s)
            WHERE user_id = %s;
        """, (liked_id, liker_id))
        conn.commit()
    handle_post_action(liker_id, liked_id, conn)


def get_unseen_likes_count(user_id: int, cursor) -> int:
    cursor.execute("""
        SELECT COUNT(*) FROM likes
        WHERE liked_id = %s AND liked = TRUE AND seen_at IS NULL;
    """, (user_id,))
    return cursor.fetchone()[0]


async def process_like(liker_id: int, liked_id: int, conn) -> dict:
    """
    Records a right-swipe/like-back from `liker_id` onto `liked_id`, resolving
    a match if `liked_id` had already liked `liker_id` back. Shared by
    POST /swipe/right and POST /likes/{liker_id}/like-back — assertions
    (match-queue membership, daily limit, has-liked-me) are the caller's
    responsibility since they differ between the two entry points.
    """
    # Import here to avoid a module-level circular import with the websocket router.
    from app.features.connections.connections_websocket_endpoints import DataModel, send_event_to_user_connection

    with conn.cursor() as cursor:
        cursor.execute("""
            INSERT INTO likes (liker_id, liked_id, liked)
            VALUES (%s, %s, %s)
            ON CONFLICT (liker_id, liked_id) DO NOTHING;
        """, (liker_id, liked_id, True))

        cursor.execute("""
            SELECT COUNT(*) FROM likes
            WHERE liker_id = %s AND liked = TRUE
              AND created_at >= NOW() - INTERVAL '24 hours';
        """, (liker_id,))
        from app.core.constants.global_constants import DAILY_LIKE_LIMIT
        swipes_remaining = max(0, DAILY_LIKE_LIMIT - cursor.fetchone()[0])

        cursor.execute("""
            SELECT users.id, users.username, users.profile_picture
            FROM likes
            JOIN users ON users.id = likes.liker_id
            WHERE likes.liker_id = %s AND likes.liked_id = %s AND likes.liked = TRUE;
        """, (liked_id, liker_id))
        match_user = cursor.fetchone()

        if match_user:
            cursor.execute("""
                DELETE FROM likes
                WHERE liker_id = %s AND liked_id = %s AND liked = TRUE;
            """, (liked_id, liker_id))

            cursor.execute("""
                INSERT INTO matches (user1_id, user2_id)
                VALUES (%s, %s);
            """, (liker_id, liked_id))

            conn.commit()
            logger_controller.info(f"Match found between {liker_id} and {liked_id}, deleted reciprocal like record")

            handle_post_action(liker_id, liked_id, conn)
            handle_post_action(liked_id, liker_id, conn)

            pairs = [
                (liked_id, liker_id),
                (liker_id, liked_id),
            ]

            await asyncio.gather(*[
                send_event_to_user_connection(
                    DataModel(
                        to=to,
                        from_=from_,
                        type="connections-reload",
                        sub_type="match",
                    )
                )
                for from_, to in pairs
            ])

            return {
                "match": True,
                "message": "It's a match!",
                "matched_user": {
                    "id": match_user[0],
                    "username": match_user[1],
                    "profile_picture": get_signed_imagekit(match_user[2])
                },
                "swipes_remaining": swipes_remaining
            }

        conn.commit()

        unseen_count = get_unseen_likes_count(liked_id, cursor)
        conn.commit()

    await send_event_to_user_connection(
        DataModel(
            to=liked_id,
            from_=liker_id,
            type="connections-reload",
            sub_type="like",
            data={"unseen_count": unseen_count},
        )
    )

    logger_controller.info(f"User {liker_id} liked user {liked_id}")

    return {
        "match": False,
        "message": "Like recorded",
        "swipes_remaining": swipes_remaining
    }