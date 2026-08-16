from fastapi import HTTPException
import psycopg2
from functools import wraps

from app.controllers.logger_controller import logger_controller
from app.constants.global_constants import DAILY_LIKE_LIMIT

def handle_db_errors(func):
    @wraps(func)
    async def wrapper(*args, **kwargs):
        try:
            return await func(*args, **kwargs)
        except psycopg2.Error as e:
            logger_controller.error(f"Database error in {func.__name__}: {e}")
            raise HTTPException(status_code=500, detail="A database error occurred")
        except HTTPException:
            # We want to re-raise existing HTTP exceptions so we don't accidentally swallow a 400 or 401 
            # and turn it into a 500 error
            raise
        except Exception as e:
            logger_controller.error(f"Unexpected error in {func.__name__}: {e}")
            raise HTTPException(status_code=500, detail=str(e))
    return wrapper

def assert_in_match_queue(liker_id: int, liked_id: int, cursor):
    """
    Check if user `liked_id` is in the `match_queue` array of `liker_id`.
    Raises an HTTP 400 if not found.
    """
    cursor.execute("""
        SELECT EXISTS (
            SELECT 1
            FROM user_discovery_pool
            WHERE user_id = %s
            AND %s = ANY(match_queue)
        );
    """, (liker_id, liked_id))
    
    result = cursor.fetchone()
    
    if not result or not result[0]:
        raise HTTPException(status_code=400, detail="User not in match queue")

def assert_has_liked_me(liker_id: int, current_user_id: int, cursor):
    """
    Check that `liker_id` has an active (undeleted) like on `current_user_id`.
    Raises HTTP 400 if not found — prevents like-back/pass from being spoofed
    for a user who never liked the caller.
    """
    cursor.execute("""
        SELECT EXISTS (
            SELECT 1 FROM likes
            WHERE liker_id = %s AND liked_id = %s AND liked = TRUE
        );
    """, (liker_id, current_user_id))

    result = cursor.fetchone()

    if not result or not result[0]:
        raise HTTPException(status_code=400, detail="This user has not liked you")

def assert_under_daily_like_limit(liker_id: int, cursor):
    """
    Raises HTTP 429 if `liker_id` has already reached DAILY_LIKE_LIMIT
    right-swipes within the last rolling 24 hours.
    """
    if get_swipes_remaining(liker_id, cursor) <= 0:
        raise HTTPException(status_code=429, detail="Daily like limit reached. Try again later.")

def get_swipes_remaining(user_id: int, cursor) -> int:
    """
    Number of right-swipes `user_id` has left in the rolling 24-hour window.
    """
    cursor.execute("""
        SELECT COUNT(*) FROM likes
        WHERE liker_id = %s AND liked = TRUE
          AND created_at >= NOW() - INTERVAL '24 hours';
    """, (user_id,))
    likes_used_today = cursor.fetchone()[0]
    return max(0, DAILY_LIKE_LIMIT - likes_used_today)