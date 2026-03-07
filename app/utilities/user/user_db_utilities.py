from typing import Optional
from fastapi import HTTPException
import psycopg2
from app.models.user_model import UserModel
from app.controllers.db_controller import db_pool
from psycopg2.extras import Json

def add_user_to_db(user: UserModel):
    # Fetch a connection from the pool
    conn = db_pool.getconn()
    cursor = None
    user_id = user.id
    print(user_id)
    try:
        cursor = conn.cursor()

        # Insert into users table
        update_user_query = """
            UPDATE users
            SET
                gender = %s,
                username = %s,
                university_id = %s,
                profile_picture = %s,
                is_profile_complete = %s
            WHERE id = %s;
        """
        cursor.execute(
            update_user_query,
            (
                user.gender,
                user.username,
                user.university_id,
                Json(user.profile_picture),
                True,
                user.id,
            ),
        )

        # Insert into user_preferences table
        insert_preference_query = """
            INSERT INTO user_preferences (user_id, key, value)
            VALUES (%s, %s, %s)
            RETURNING id;
        """
        cursor.execute(
            insert_preference_query,
            (user_id, "interested_gender", user.interested_gender),
        )

        # Insert into user_metadata table
        insert_metadata_query = """
            INSERT INTO user_metadata (user_id, key, value)
            VALUES (%s, %s, %s);
        """
        metadata = user.model_dump()
        for key, value in metadata.items():
            if key not in ["email", "hashed_password", "gender", "id", "profile_picture", "username", "university_id", "interested_gender"]:
                if isinstance(value, (dict, list)):
                    value = Json(value)
                else:
                    value = str(value)
                cursor.execute(insert_metadata_query, (user_id, key, value))

        conn.commit()  
        return user_id

    except psycopg2.Error as e:
        print(f"Database error during user creation: {e}")
        if conn:
            conn.rollback() 
        raise HTTPException(status_code=500, detail=f"Database error: {e}")
 
    finally:
        if cursor:
            cursor.close()
        # Always return the connection to the pool
        db_pool.putconn(conn)

def get_user_from_db(email: Optional[str] = None, id: Optional[int] = None):
    if not email and not id:
        raise HTTPException(status_code=400, detail="Either 'email' or 'id' must be provided.")

    # Fetch a connection from the pool
    conn = db_pool.getconn()
    cursor = None
    try:
        cursor = conn.cursor()

        if id is not None and isinstance(id, int):
            select_user_query = """
                SELECT password_hash, email, id
                FROM users
                WHERE id = %s;
            """
            cursor.execute(select_user_query, (id,))
        else:
            select_user_query = """
                SELECT password_hash, email, id
                FROM users
                WHERE email = %s;
            """
            cursor.execute(select_user_query, (email,))
        

        row = cursor.fetchone()
        if not row:
            return None
        
        password_hash, email, id = row
        return {
            "hashed_password": password_hash,
            "email": email,
            "id": id
        }

    except psycopg2.Error as e:
        print(f"Database error during user retrieval: {e}")
        if conn:
            conn.rollback()
        raise HTTPException(status_code=500, detail=f"Database error: {e}")

    finally:
        if cursor:
            cursor.close()
        # Always return the connection to the pool
        db_pool.putconn(conn)