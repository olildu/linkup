from datetime import datetime
from typing import Dict, Literal, Optional
from pydantic import BaseModel

class MediaMessageData(BaseModel):
    mediaType: Literal["text", "voice", "image"]
    file_key: str
    blurhashText: str
    metadata : Dict

class ChatMessage(BaseModel):
    message_id: str
    message: str
    reply_id : Optional[str] = None

    to: int
    from_: int

    chat_room_id: int
    is_seen: Optional[bool] = False

    timestamp: Optional[datetime] = datetime.now()

    type: Literal["chats"]
    chats_type: Literal["message"]

    media: Optional[MediaMessageData] = None
