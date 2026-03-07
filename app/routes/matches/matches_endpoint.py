from datetime import datetime
from functools import partial
import json
import traceback
from fastapi import APIRouter, Depends, HTTPException

from app.controllers.db_controller import db_pool
from app.controllers.logger_controller import logger_controller
from app.constants.global_constants import oauth2_scheme

from app.models.connection_user_model import ConnectionChatModel, ConnectionMatchModel
from app.utilities.common.common_utilites import get_signed_imagekit
from app.utilities.exception.swipe.swipe_exceptions import handle_db_errors
from app.utilities.matches.matches_utilities import get_last_message_timestamp, get_matches
from app.utilities.token.token_utilities import decode_token

matches_router = APIRouter(prefix="/matches")

@matches_router.get("/get-matches")
@handle_db_errors
async def return_matches(token: str = Depends(oauth2_scheme)):
    """
    Get matches for the user.
    """

    id = decode_token(token)
    
    try:
        return get_matches(user_id=id)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@matches_router.get("/get-connections")
@handle_db_errors
async def return_connections(token: str = Depends(oauth2_scheme)):
    """
    Get connections (matches and chats) for the current user,
    including last message media type info.
    """
    user_id = decode_token(token)
    conn = db_pool.getconn()
    try:
        cursor = conn.cursor()
        # Fetch matches (all users matched with current user)
        cursor.execute("""
            SELECT user1_id, user2_id
            FROM matches
            WHERE user1_id = %s OR user2_id = %s;
        """, (user_id, user_id))
        matches_rows = cursor.fetchall()

        matches = {
            user2 if user1 == user_id else user1
            for user1, user2 in matches_rows
        }

        # Fetch chat_participants rows for current user to get chat_ids
        cursor.execute("""
            SELECT chat_id, unseen_count
            FROM chat_participants
            WHERE user_id = %s;
        """, (user_id,))
        chat_participants_rows = cursor.fetchall()
        chat_ids = [row[0] for row in chat_participants_rows]

        # Map chat_id to unseen_count for the current user
        chat_unseen_count = {row[0]: row[1] for row in chat_participants_rows}

        if not chat_ids and not matches:
            return {"matches": [], "chats": []}

        # Fetch last message and media type of the chats available
        cursor.execute('''
            SELECT chats.id, messages.message, chats.last_message_media_type, messages.timestamp
            FROM chats
            JOIN messages ON chats.last_message_id = messages.id
            WHERE chats.id = ANY(%s);
        ''', (chat_ids,))
        
        last_messages_rows = cursor.fetchall()
        # Map chat_id -> {message: ..., media_type: ...}
        chat_last_message = {
            chat_id: {"message": message, "media_type": media_type, "timestamp" : last_message_timestamp}
            for chat_id, message, media_type, last_message_timestamp in last_messages_rows
        }

        # Fetch all participants of these chats to find other users
        cursor.execute("""
            SELECT chat_id, user_id
            FROM chat_participants
            WHERE chat_id = ANY(%s);
        """, (chat_ids,))

        participants_rows = cursor.fetchall()

        # Map chat_id -> list of users
        chat_to_users = {}
        for chat_id, participant_user_id in participants_rows:
            chat_to_users.setdefault(chat_id, []).append(participant_user_id)

        # Build dictionary: other_user_id -> chat_id
        chats = {}
        for chat_id, users in chat_to_users.items():
            for uid in users:
                if uid != user_id:
                    chats[uid] = chat_id
                    break  # assuming 2-person chats

        # Combine user IDs from matches and chats
        user_ids = list(set(matches) | set(chats.keys()))

        if not user_ids:
            return {"matches": [], "chats": []}

        # Fetch user details for all connected users
        cursor.execute("""
            SELECT id, username, profile_picture::text, gender, university_id, is_deleted
            FROM users
            WHERE id = ANY(%s);
        """, (user_ids,))

        user_rows = cursor.fetchall()

        matches_users = []
        chats_users = []

        for user_row in user_rows:
            # CHANGE: Unpack 6 values instead of 5
            id, username, profile_picture, gender, university_id, is_deleted = user_row
            
            # Handle potentially NULL profile picture for deleted users
            profile_picture_dict = json.loads(profile_picture) if profile_picture else None
            if profile_picture_dict:
                profile_picture_dict = get_signed_imagekit(profile_picture_dict)

            if id in matches:
                matches_users.append(
                    ConnectionMatchModel(
                        id=id,
                        username=username,
                        profile_picture=profile_picture_dict,
                        is_deleted=is_deleted # Pass flag
                    )
                )

            elif id in chats:
                last_msg_info = chat_last_message.get(chats[id], {"message": None, "media_type": None})
                chats_users.append(
                    ConnectionChatModel(
                        id=id,
                        username=username,
                        profile_picture=profile_picture_dict,
                        chat_room_id=chats[id],
                        unseen_counter=chat_unseen_count.get(chats[id], 0),
                        last_message=last_msg_info["message"],
                        last_message_media_type=last_msg_info["media_type"],
                        is_deleted=is_deleted # Pass flag
                    )
                )

        # Pass parameter required
        sort_key = partial(get_last_message_timestamp, chat_last_message=chat_last_message)
        # Sort on the basis of last message timestamp
        chats_users.sort(reverse=True, key=sort_key) # Inject here

        return {
            "matches": matches_users,
            "chats": chats_users
        }

    except Exception as e:
        logger_controller.critical("Failed to fetch connections:\n%s", traceback.format_exc())
        raise HTTPException(status_code=500, detail=str(e))

    finally:
        if 'cursor' in locals():
            cursor.close()
        db_pool.putconn(conn)