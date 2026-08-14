import time
import jwt
import uuid
import psycopg2

from jwt import PyJWTError
from datetime import datetime
from fastapi import APIRouter, Body, Depends, HTTPException, status

from app.controllers.db_controller import db_pool
from app.models.block_user_request import BlockUserRequest
from app.models.preference_model import PreferenceModel
from app.models.report_user_request import ReportUserRequest
from app.models.update_request_model import UpdateRequestModel
from app.constants.global_constants import ALGORITHM, SECRET_KEY, oauth2_scheme
from app.utilities.token.token_utilities import decode_token
from app.utilities.user.user_utilities import get_user_details
from psycopg2.extras import Json

user_router = APIRouter(prefix="/user")

@user_router.post("/report")
async def report_user(body: ReportUserRequest, token: str = Depends(oauth2_scheme)):
    reporter_id = decode_token(token)
    conn = db_pool.getconn()
    try:
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO reported_users (reporter_id, reported_id, reason)
            VALUES (%s, %s, %s)
        """, (reporter_id, body.reported_user_id, body.reason))

        conn.commit()
        return {"message": "User reported successfully"}

    except Exception as e:
        conn.rollback()
        print(f"Error reporting user: {e}")
        raise HTTPException(status_code=500, detail="Failed to report user")
    finally:
        if 'cursor' in locals():
            cursor.close()
        db_pool.putconn(conn)

@user_router.delete("/delete")
async def delete_account(token: str = Depends(oauth2_scheme)):
    user_id = decode_token(token)
    conn = db_pool.getconn()
    try:
        cursor = conn.cursor()
        # 1. Anonymize user data
        # We append timestamp + uuid to email to keep it unique but anonymous
        anonymized_email = f"deleted_{int(datetime.now().timestamp())}_{uuid.uuid4()}@linkup.com"
        
        cursor.execute("""
            UPDATE users
            SET 
                username = 'Deleted Account',
                email = %s,
                profile_picture = NULL,
                password_hash = 'deleted',
                is_deleted = TRUE
            WHERE id = %s
        """, (anonymized_email, user_id))

        # 2. Clear sensitive metadata
        cursor.execute("DELETE FROM user_metadata WHERE user_id = %s", (user_id,))
        cursor.execute("DELETE FROM user_preferences WHERE user_id = %s", (user_id,))
        
        # 3. Remove from discovery pool so they stop appearing in cards
        cursor.execute("DELETE FROM user_discovery_pool WHERE user_id = %s", (user_id,))

        conn.commit()
        return {"message": "Account deleted successfully"}

    except Exception as e:
        conn.rollback()
        print(f"Error deleting account: {e}")
        raise HTTPException(status_code=500, detail="Failed to delete account")
    finally:
        if 'cursor' in locals():
            cursor.close()
        db_pool.putconn(conn)

@user_router.post("/block")
async def block_user(body: BlockUserRequest, token: str = Depends(oauth2_scheme)):
    blocker_id = decode_token(token)
    blocked_id = body.blocked_user_id
    conn = db_pool.getconn()
    try:
        cursor = conn.cursor()
        # 1. Insert into blocked_users
        cursor.execute("""
            INSERT INTO blocked_users (blocker_id, blocked_id)
            VALUES (%s, %s)
            ON CONFLICT (blocker_id, blocked_id) DO NOTHING
        """, (blocker_id, blocked_id))

        # 2. Delete any existing Match
        cursor.execute("""
            DELETE FROM matches 
            WHERE (user1_id = %s AND user2_id = %s) 
               OR (user1_id = %s AND user2_id = %s)
        """, (blocker_id, blocked_id, blocked_id, blocker_id))

        # 3. Delete active Chat (and participants via CASCADE usually, or explicit delete)
        # Find shared chat first
        cursor.execute("""
            SELECT c.id 
            FROM chats c
            JOIN chat_participants cp1 ON c.id = cp1.chat_id
            JOIN chat_participants cp2 ON c.id = cp2.chat_id
            WHERE cp1.user_id = %s AND cp2.user_id = %s
        """, (blocker_id, blocked_id))
        
        chat_rows = cursor.fetchall()
        for row in chat_rows:
            chat_id = row[0]
            # Assuming you want to delete the chat history entirely
            # If you want to keep history but hide it, you would add a 'status' column instead
            cursor.execute("DELETE FROM messages WHERE chat_id = %s", (chat_id,))
            cursor.execute("DELETE FROM chat_participants WHERE chat_id = %s", (chat_id,))
            cursor.execute("DELETE FROM chats WHERE id = %s", (chat_id,))

        # 4. Remove from discovery pool (optional but recommended)
        cursor.execute("""
            DELETE FROM user_discovery_pool 
            WHERE user_id = %s
        """, (blocked_id,)) # Logic depends on how your pool works, essentially prevent them seeing each other

        conn.commit()
        return {"message": "User blocked successfully"}

    except Exception as e:
        conn.rollback()
        print(f"Error blocking user: {e}")
        raise HTTPException(status_code=500, detail="Failed to block user")
    finally:
        if 'cursor' in locals():
            cursor.close()
        db_pool.putconn(conn)

@user_router.get("/get/detail/{user_id}")
async def get_user_data(user_id: int, token: str = Depends(oauth2_scheme)):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
    except PyJWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
            headers={"WWW-Authenticate": "Bearer"}
        )

    requesting_user_id = payload.get("id")

    if requesting_user_id != user_id:
        conn = db_pool.getconn()
        try:
            cursor = conn.cursor()
            cursor.execute("""
                SELECT EXISTS (
                    SELECT 1 FROM matches
                    WHERE (user1_id = %s AND user2_id = %s)
                       OR (user1_id = %s AND user2_id = %s)
                ) OR EXISTS (
                    SELECT 1
                    FROM chat_participants cp1
                    JOIN chat_participants cp2 ON cp1.chat_id = cp2.chat_id
                    WHERE cp1.user_id = %s AND cp2.user_id = %s
                );
            """, (requesting_user_id, user_id, user_id, requesting_user_id, requesting_user_id, user_id))
            is_connected = cursor.fetchone()[0]
        finally:
            if 'cursor' in locals():
                cursor.close()
            db_pool.putconn(conn)

        if not is_connected:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Not authorized to view this user's details"
            )

    try:
       return get_user_details(user_id)
    except psycopg2.Error as e:
        print(f"Database error during user retrieval: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error while retrieving user data"
        )

@user_router.get("/get/preferences")
async def get_user_preferences(token: str = Depends(oauth2_scheme)):
    user_id = decode_token(token)
    conn = db_pool.getconn()
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT key, value FROM user_preferences WHERE user_id = %s", (user_id,))
        preferences = cursor.fetchall()

        if not preferences:
            return {"message": "No preferences found for this user"}

        preference_dict = {key: value for key, value in preferences}
        user_preferences = PreferenceModel(**preference_dict)

        return user_preferences

    except psycopg2.Error as e:
        print(f"Database error during preference retrieval: {e}")
        conn.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error while retrieving user preferences"
        )
    finally:
        if 'cursor' in locals():
            cursor.close()
        db_pool.putconn(conn)

@user_router.post("/update/metadata")
async def update_user_metadata(
    update_pfp: bool = False,                      
    body: UpdateRequestModel = Body(...),          
    token: str = Depends(oauth2_scheme)            
):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id = payload.get("id")
        if not user_id:
            raise HTTPException(status_code=401, detail="Invalid token: user id missing")
    except PyJWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
            headers={"WWW-Authenticate": "Bearer"}
        )

    update_data = body.model_dump(exclude_none=True)
    if not update_data:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No fields to update")

    conn = db_pool.getconn()
    try:
        cursor = conn.cursor()

        # Handle 'profile_picture' separately
        if 'profile_picture' in update_data and update_pfp:
            profile_picture = update_data.get("profile_picture")
            if profile_picture and not isinstance(profile_picture, dict):
                raise HTTPException(status_code=400, detail="Invalid input: profile_picture")
            cursor.execute(
                "UPDATE users SET profile_picture = %s WHERE id = %s",
                (Json(profile_picture), user_id)
            )
            conn.commit()
            return {"message": "User metadata updated successfully"}

        # Update or insert other metadata
        for key, value in update_data.items():
            cursor.execute("""
                INSERT INTO user_metadata (user_id, key, value)
                VALUES (%s, %s, %s)
                ON CONFLICT (user_id, key) DO UPDATE
                SET value = EXCLUDED.value
            """, (user_id, key, str(value)))

        conn.commit()

    except psycopg2.Error as e:
        print(f"Database error: {e}")
        conn.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Database update failed")
    finally:
        if 'cursor' in locals():
            cursor.close()
        db_pool.putconn(conn)

    return {"message": "User metadata updated successfully"}

@user_router.post('/update/preferences')
async def update_user_preferences(body: PreferenceModel, token: str = Depends(oauth2_scheme)):

    id = decode_token(token)
    conn = db_pool.getconn()
    try:
        cursor = conn.cursor()
        for key, value in body.model_dump().items():
            # Delete if value is None (null)
            if value is None or value == "Don't mind":
                cursor.execute('''
                    DELETE FROM user_preferences
                    WHERE user_id = %s AND key = %s;
                ''', (id, key))
            else:
                cursor.execute('''
                    INSERT INTO user_preferences (user_id, key, value)
                    VALUES (%s, %s, %s)
                    ON CONFLICT (user_id, key) DO UPDATE
                    SET value = EXCLUDED.value;
                ''', (id, key, value))
            
        conn.commit()

        return {"message": "Preferences updated successfully"}
    
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if 'cursor' in locals():
            cursor.close()
        db_pool.putconn(conn)