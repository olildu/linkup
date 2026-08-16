import asyncio
import json
from app.features.chat.models.message_model import ChatMessage, MediaMessageData
from app.core.controllers.db_controller import db_pool
from psycopg2.extras import Json

from app.features.media.media_utilities import generate_signed_url

def add_to_unseen_and_last_message(
        receiver_id: int, 
        chat_room_id: int,
        message_id: str, 
    ):
    cp_query = """
        UPDATE chat_participants
        SET 
            unseen_count = unseen_count + 1
        WHERE user_id = %s AND chat_id = %s
    """

    media_query = """
        SELECT media_type FROM media_files WHERE message_id = %s LIMIT 1
    """

    media_type = None

    conn = db_pool.getconn()
    try:
        with conn.cursor() as cursor:
            cursor.execute(cp_query, (
                receiver_id,
                chat_room_id
            ))

            cursor.execute(media_query, (message_id,))
            result = cursor.fetchone()
            if result:
                media_type = result[0]

            c_query = """
                UPDATE chats
                SET 
                    last_message_id = %s,
                    last_message_media_type = %s
                WHERE id = %s
            """

            cursor.execute(c_query, (
                message_id,
                media_type,
                chat_room_id
            ))

        conn.commit()
    except Exception as e:
        print(f"Failed to update unseen count or last message media info: {e}")
        conn.rollback()
    finally:
        db_pool.putconn(conn)

def insert_message_to_db(message: ChatMessage):
    conn = db_pool.getconn()
    try:
        with conn.cursor() as cur:
            # Insert the message first
            cur.execute(
                """
                INSERT INTO messages (id, chat_id, sender_id, message, reply_id, timestamp)
                VALUES (%s, %s, %s, %s, %s, NOW())
                RETURNING id
                """,
                (message.message_id, message.chat_room_id, message.from_, message.message, message.reply_id)
            )
            inserted_id = cur.fetchone()[0]

            # If media exists, insert it too
            if message.media:
                cur.execute(
                    """
                    INSERT INTO media_files (message_id, file_key, media_type, size_bytes, metadata, uploaded_at, user_id)
                    VALUES (%s, %s, %s, %s, %s, NOW(), %s)
                    """,
                    (
                        inserted_id,
                        message.media.file_key,
                        message.media.mediaType.value if hasattr(message.media.mediaType, 'value') else message.media.mediaType,
                        message.media.metadata.get("size_bytes"),
                        Json(message.media.metadata),
                        message.from_
                    )
                )

            conn.commit()
            return inserted_id
    finally:
        db_pool.putconn(conn)

async def generate_signed_url_async(file_key: str) -> str:
    loop = asyncio.get_running_loop()
    return await loop.run_in_executor(None, generate_signed_url, file_key)

async def process_msg(msg):
    metadata = json.loads(msg['metadata']) if msg['metadata'] else {}
    media_data = None
    if msg['file_key'] and msg['media_type']:
        signed_url = await generate_signed_url_async(msg['file_key'])
        metadata["file_url"] = signed_url
        media_data = MediaMessageData(
            file_key=msg['file_key'],
            mediaType=msg['media_type'],
            metadata=metadata,
            blurhashText=""
        )
    return ChatMessage(
        chats_type="message",
        type="chats",
        message_id=str(msg['id']),
        to=-1,
        reply_id=str(msg["reply_id"]) if msg.get("reply_id") is not None else None,
        from_=msg['sender_id'],
        chat_room_id=msg['chat_id'],
        message=msg['message'],
        timestamp=msg['timestamp'],
        is_seen=msg['is_seen'],
        media=media_data,
    )