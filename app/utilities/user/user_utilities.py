from fastapi import Depends, HTTPException
from app.models.user_model import build_user_model
from app.utilities.exception.swipe.swipe_exceptions import get_swipes_remaining

from app.controllers.db_controller import db_pool

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

        swipes_remaining = get_swipes_remaining(user_id, cursor)

        user = build_user_model(
            user_metadata=user_meta_row,
            core_data=user_row,
            hashed_password=user_row[6],
            user_preferences=user_preferences
        )

        return {
            **user.model_dump(exclude={"hashed_password", "email"}),
            "swipes_remaining": swipes_remaining,
        }
    finally:
        if 'cursor' in locals():
            cursor.close()
        db_pool.putconn(conn)