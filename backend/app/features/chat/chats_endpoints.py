import asyncio
from datetime import datetime
from sqlite3 import Connection
from typing import Optional
from pydantic import BaseModel
from app.core.constants.global_constants import oauth2_scheme
from fastapi import APIRouter, Depends, HTTPException, Request
from asyncpg.pool import PoolConnectionProxy

from app.features.chat.models.event_models import SeenEvent
from app.features.chat.chat_websocket_endpoints import send_event_to_user_chat
from app.features.connections.connections_websocket_endpoints import DataModel, send_event_to_user_connection

from app.features.chat.chat_utilities import process_msg
from app.core.swipe_exceptions import handle_db_errors
from app.core.token_utilities import decode_token
from app.core.controllers.db_controller import db_pool
from app.core.controllers.logger_controller import logger_controller


chats_router = APIRouter(prefix="/chats")

class ChatRequest(BaseModel):
    id: int

@chats_router.post("/start-chat")
@handle_db_errors
async def start_chat(body: ChatRequest, token: str = Depends(oauth2_scheme)):
    id = decode_token(token)
    conn = db_pool.getconn()
    try:
        cursor = conn.cursor()

        query = """
            SELECT EXISTS (
                SELECT 1
                FROM matches
                WHERE (user1_id = %s AND user2_id = %s)
                OR (user1_id = %s AND user2_id = %s)
            );
        """
        cursor.execute(query, (id, body.id, body.id, id))
        match_exists = cursor.fetchone()[0] 

        if match_exists:
            cursor.execute('''
                INSERT INTO chats 
                DEFAULT VALUES 
                returning id;
            ''')
            chat_id : int = cursor.fetchone()[0]

            cursor.execute('''
                INSERT INTO chat_participants (chat_id, user_id)
                VALUES(%s, %s) 
            ''', (chat_id, id))

            cursor.execute(''' 
                INSERT INTO chat_participants (chat_id, user_id)
                VALUES(%s, %s) 
            ''', (chat_id, body.id))

            cursor.execute('''
                DELETE FROM matches
                WHERE (user1_id = %s AND user2_id = %s)
                    OR (user1_id = %s AND user2_id = %s)
            ''', (id, body.id, body.id, id))
    
            conn.commit()

            pairs = [
                (id, body.id),
                (body.id, id)
            ]

            await asyncio.gather(*[
                send_event_to_user_connection(
                    DataModel(
                        from_=from_,
                        to=to,
                        type="connections-reload",
                        sub_type="chat",
                    )
                )
                for from_, to in pairs
            ])

            return {
                "success" : True,
                "message": "Chat started successfully",
                "chat_room_id" : chat_id,
                "user1_id": id, 
                "user2_id": body.id
            }

        else:
            raise HTTPException(status_code=400, detail="Match does not exist, cannot start chat")
    finally:
        if 'cursor' in locals():
            cursor.close()
        db_pool.putconn(conn)

class ChatRoomRequest(BaseModel):
    chat_room_id: int 
    last_message_id: Optional[str] = None
    last_message_timestamp: Optional[datetime] = None
    
@chats_router.post("/get/chat")
@handle_db_errors
async def fetch_chats(request: Request, body: ChatRoomRequest, token: str = Depends(oauth2_scheme)):
    requesting_user_id = decode_token(token)
    # try:
    async with request.app.state.db_pool.acquire() as async_conn:
        # Validate participation
        is_participant = await async_conn.fetchval("""
            SELECT 1 FROM chat_participants
            WHERE user_id = $1 AND chat_id = $2
            LIMIT 1;
        """, requesting_user_id, body.chat_room_id)


        print(f"Is participant : {is_participant}")

        if not is_participant:
            raise HTTPException(status_code=403, detail="User is not a participant of this chat")

        # Last message lookup
        row = await async_conn.fetchrow("""
            SELECT id, sender_id FROM messages
            WHERE chat_id = $1
            ORDER BY timestamp DESC
            LIMIT 1;
        """, body.chat_room_id)

        last_message_id = row['id'] if row else None
        last_message_sender = row['sender_id'] if row else None

        if last_message_id and last_message_sender != requesting_user_id:
            await async_conn.execute("""
                UPDATE chat_participants
                SET last_seen_message_id = $1, unseen_count = 0, last_seen_at = NOW()
                WHERE user_id = $2 AND chat_id = $3;
            """, last_message_id, requesting_user_id, body.chat_room_id)

            await send_event_to_user_chat(
                SeenEvent(
                    type="chats",
                    chats_type="seen",
                    to=last_message_sender,
                    from_=requesting_user_id,
                    message_id=str(last_message_id)
                )
            )

        # Fetch messages with media
        messages_rows = await async_conn.fetch("""
            SELECT
                m.id,
                m.chat_id,
                m.sender_id,
                m.message,
                m.reply_id,
                m.timestamp,
                (m.id = cp.last_seen_message_id OR m.timestamp <= cp.last_seen_at) AS is_seen,
                mf.file_key,
                mf.media_type,
                mf.size_bytes,
                mf.metadata
            FROM messages m
            LEFT JOIN chat_participants cp ON m.chat_id = cp.chat_id AND cp.user_id = $1
            LEFT JOIN media_files mf ON m.id = mf.message_id
            WHERE m.chat_id = $2
            ORDER BY m.timestamp DESC
            LIMIT 20;
        """, requesting_user_id, body.chat_room_id)

        messages_rows.reverse()

        # Construct ChatMessage list
        messages = await asyncio.gather(*(process_msg(msg) for msg in messages_rows))

    return {
        "user_id": requesting_user_id,
        "messages": messages
    }


@chats_router.post("/get/chat-paginated")
@handle_db_errors
async def fetch_paginated_chats(request: Request, body: ChatRoomRequest, token: str = Depends(oauth2_scheme)):
    requesting_user_id = decode_token(token)
    try:
        async with request.app.state.db_pool.acquire() as async_conn:
            # Validate participation
            is_participant = await async_conn.fetchval("""
                SELECT 1 FROM chat_participants
                WHERE user_id = $1 AND chat_id = $2
                LIMIT 1;
            """, requesting_user_id, body.chat_room_id)

            if not is_participant:
                raise HTTPException(status_code=403, detail="User is not a participant of this chat")

            # Use a very large number as default pagination ID if none provided (means fetch latest)
            pagination_message_id : str = body.last_message_id
            pagination_timestamp : datetime = body.last_message_timestamp

            logger_controller.info(f"Pagination message ID received: {pagination_message_id}")

            # Fetch messages older than pagination_message_id (strictly less)
            messages_rows = await async_conn.fetch("""
                SELECT
                    m.id,
                    m.chat_id,
                    m.sender_id,
                    m.message,
                    m.timestamp,
                    (m.id = cp.last_seen_message_id OR m.timestamp <= cp.last_seen_at) AS is_seen,
                    mf.file_key,
                    mf.media_type,
                    mf.size_bytes,
                    mf.metadata
                FROM messages m
                LEFT JOIN chat_participants cp ON m.chat_id = cp.chat_id AND cp.user_id = $1
                LEFT JOIN media_files mf ON m.id = mf.message_id
                WHERE m.chat_id = $2
                AND (m.timestamp, m.id) < ($3::timestamp, $4::uuid)
                ORDER BY m.timestamp DESC, m.id DESC
                LIMIT 20;
            """, requesting_user_id, body.chat_room_id, pagination_timestamp, pagination_message_id)

            # Reverse to get ascending order (oldest first) for UI display
            messages_rows.reverse()
            logger_controller.info(f"Fetched message IDs: {[msg['id'] for msg in messages_rows]}")
            
            # Process messages concurrently
            messages = await asyncio.gather(*(process_msg(msg) for msg in messages_rows))

            # Determine if more messages exist before the oldest fetched message
            has_more = False
            next_page_cursor = None
            if messages_rows:
                oldest_id = messages_rows[0]['id']
                has_more = await async_conn.fetchval("""
                    SELECT EXISTS (
                        SELECT 1 FROM messages
                        WHERE chat_id = $1 AND id < $2
                    );
                """, body.chat_room_id, oldest_id)
                next_page_cursor = oldest_id

        return {
            "user_id": requesting_user_id,
            "messages": messages,
            "has_more": has_more,
            "next_page_cursor": next_page_cursor
        }

    except Exception as e:
        logger_controller.error(f"Error fetching chats: {e}")
        raise HTTPException(status_code=500, detail="Failed to fetch chat messages")