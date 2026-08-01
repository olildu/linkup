from fastapi import Depends, HTTPException
from app.models.user_model import build_user_model
from app.utilities.password.password_utilities import verify_password
from app.utilities.user.user_db_utilities import get_user_from_db
from app.constants.global_constants import DAILY_LIKE_LIMIT

from app.controllers.db_controller import db_pool

def authenticate_user(email: str, password: str):
    user = get_user_from_db(email=email)
    if user and verify_password(password, user["hashed_password"]):
        return user
    return None

def get_user_details(user_id: int):
    conn = db_pool.getconn()
    try:
        cursor = conn.cursor()

        # Fetch user from users table
        cursor.execute("""
            SELECT id, email, username, gender, university_id, profile_picture::text, password_hash
            FROM users
            WHERE id = %s;
        """, (user_id,))
        user_row = cursor.fetchone()

        if not user_row:
            raise HTTPException(status_code=404, detail="User not found")

        # Fetch user_metadata
        cursor.execute("""
            SELECT *
            FROM user_metadata
            WHERE user_id = %s;
        """, (user_id,))
        user_meta_row = cursor.fetchall()

        # Fetch user_metadata
        cursor.execute("""
            SELECT *
            FROM user_preferences
            WHERE user_id = %s;
        """, (user_id,))

        user_preferences = cursor.fetchall()

        cursor.execute("""
            SELECT COUNT(*) FROM likes
            WHERE liker_id = %s AND liked = TRUE
              AND created_at >= NOW() - INTERVAL '24 hours';
        """, (user_id,))
        likes_used_today = cursor.fetchone()[0]

        user = build_user_model(
            user_metadata=user_meta_row,
            core_data=user_row,
            hashed_password=user_row[6],
            user_preferences=user_preferences
        )

        return {
            **user.model_dump(exclude={"hashed_password", "email"}),
            "swipes_remaining": max(0, DAILY_LIKE_LIMIT - likes_used_today),
        }
    finally:
        if 'cursor' in locals():
            cursor.close()
        db_pool.putconn(conn)