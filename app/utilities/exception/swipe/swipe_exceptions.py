from fastapi import HTTPException
import psycopg2
from functools import wraps

from app.controllers.logger_controller import logger_controller

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