from typing import Literal, Optional
from pydantic import BaseModel

class ConnectionMatchModel(BaseModel):
    id: int
    username: str
    profile_picture: Optional[dict] = None
    is_deleted: bool = False # Added

class ConnectionChatModel(BaseModel):
    id: int
    username: str
    profile_picture: Optional[dict] = None
    chat_room_id: int
    unseen_counter : int
    is_deleted: bool = False # Added

    last_message: Optional[str] = None
    last_message_media_type: str | None