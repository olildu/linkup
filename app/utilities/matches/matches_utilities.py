from datetime import datetime
import random
from typing import List, Optional
from fastapi import HTTPException
from pydantic import BaseModel
from psycopg2.extensions import cursor as Psycopg2Cursor

from app.controllers.db_controller import db_pool
from app.models.connection_user_model import ConnectionChatModel
from app.models.match_canidate_model import build_candidate_model

class MatchUserModel(BaseModel):
    id: int
    username: str
    university_id: int
    already_interacted: Optional[List[int]] = None
    preferences: Optional[dict] = None
    existing_matches: Optional[List[int]] = None


def get_last_message_timestamp(chat : ConnectionChatModel, chat_last_message : dict):
    chat_id = chat.chat_room_id
    message_info = chat_last_message.get(chat_id)
    if message_info and message_info["timestamp"]:
        return message_info["timestamp"]
    else:
        return datetime.min  


def get_matches(user_id: int) -> MatchUserModel:
    conn = db_pool.getconn()
    try:
        cursor = conn.cursor()
        # Query 1: user info 
        cursor.execute("SELECT id, username, university_id FROM users WHERE id = %s", (user_id,))
        user_row = cursor.fetchone()
        if not user_row:
            return None
    
        user_id, username, university_id = user_row
    
        # Query 2: preferences
        cursor.execute("SELECT key, value FROM user_preferences WHERE user_id = %s", (user_id,))
        preferences = {key: value for key, value in cursor.fetchall()}


        # Query 3: already_interacted and match_queue
        cursor.execute("""
            SELECT already_interacted, match_queue
            FROM user_discovery_pool
            WHERE user_id = %s
        """, (user_id,))
        row = cursor.fetchone()

        already_interacted = row[0] if row else []
        existing_matches = row[1] if row else []

        user = MatchUserModel(
            id=user_id,
            username=username,
            university_id=university_id,
            already_interacted=already_interacted,
            preferences=preferences,
            existing_matches=existing_matches
        )

        return {
            "matches" : get_matches_by_preference(
                user = user, 
                cursor = cursor,
                limit = 10 - len(user.existing_matches)
            ),
            "preferences_set": True if len(user.preferences.keys()) > 1 else False,
        }
    finally:
        if 'cursor' in locals():
            cursor.close()
        db_pool.putconn(conn)

def get_matches_by_preference(user: MatchUserModel, limit: int = 10, cursor: Psycopg2Cursor = None):
    university_id = user.university_id
    interested_gender = (user.preferences or {}).get("interested_gender")
    user_id = user.id
    already_interacted = user.already_interacted or []

    exclusion_list = already_interacted + [user_id] + user.existing_matches
    exclusion_tuple = tuple(exclusion_list) if exclusion_list else (-1,)

    user_existing_matches = user.existing_matches or []
    user_existing_matches_tuple = tuple(user_existing_matches) if user_existing_matches else (-1,)

    preferences = user.preferences.copy() if user.preferences else {}
    preferences.pop("interested_gender", None)

    matched_users = []

    query = f"""
    SELECT DISTINCT users.id, users.username, users.gender, users.university_id, users.profile_picture::text
    FROM users 
        where users.id IN %s
    """

    params = [user_existing_matches_tuple]
    cursor.execute(query, params)

    matched_users += cursor.fetchall()

    query = f"""
        SELECT DISTINCT users.id, users.username, users.gender, users.university_id, users.profile_picture::text
        FROM users
        JOIN user_metadata metadata ON users.id = metadata.user_id
        WHERE users.university_id = %s
          AND users.gender = %s
          AND users.id NOT IN %s
    """
    params = [university_id, interested_gender, exclusion_tuple]

    for i, (key, value) in enumerate(preferences.items()):
        query += f""" AND EXISTS (
            SELECT 1 FROM user_metadata m{i}
            WHERE m{i}.user_id = users.id
              AND m{i}.key = %s
              AND m{i}.value = %s
        )"""
        params.extend([key, value])

    query += f" LIMIT {limit};"


    cursor.execute(query, params)

    matched_users += cursor.fetchall()

    if not matched_users:
        print("No matches found")
        return []

    matched_user_ids = tuple([u[0] for u in matched_users])
    if len(matched_user_ids) == 1:
        matched_user_ids = (matched_user_ids[0], matched_user_ids[0])  

    metadata_query = """
        SELECT user_id, key, value
        FROM user_metadata
        WHERE user_id IN %s
    """
    cursor.execute(metadata_query, (matched_user_ids,))
    all_metadata = cursor.fetchall() 

    metadata_map = {}
    for user_id_, key, value in all_metadata:
        metadata_map.setdefault(user_id_, {})[key] = value

    results = []
    for user_data in matched_users:
        user_id_ = user_data[0]
        user_meta = metadata_map.get(user_id_, {})
        try:
            candidate = build_candidate_model(user_meta, user_data)
            results.append(candidate.model_dump())
        except Exception as e:
            print(f"Error building model for user {user_id_}: {e}")
            raise HTTPException(status_code=500, detail=f"Error building model for user {user_id_}: {e}")


        # 1. Fetch existing match_queue
        cursor.execute("SELECT match_queue FROM user_discovery_pool WHERE user_id = %s", (user_id,))
        row = cursor.fetchone()
        existing_queue = row[0] if row else []

        # 2. Merge and limit to 10 unique
        merged_queue = list(dict.fromkeys(existing_queue + list(matched_user_ids)))[:10]

        # 3. Upsert with simpler query
        upsert_query = """
            INSERT INTO user_discovery_pool (user_id, match_queue)
            VALUES (%s, %s)
            ON CONFLICT (user_id) DO UPDATE
            SET match_queue = EXCLUDED.match_queue
        """
        cursor.execute(upsert_query, (user_id, merged_queue))

    cursor.connection.commit()
    random.shuffle(results)
    
    return results