from datetime import datetime
from typing import Literal, Optional
from pydantic import BaseModel


class TypingEvent(BaseModel):
    type: Literal["chats"]
    chats_type: Literal["typing"]

    to: int
    from_: int
    chat_room_id : int
    
    message: str = "Typing..."
    timestamp: Optional[datetime] = datetime.now()

class SeenEvent(BaseModel):
    type: Literal["chats"]
    chats_type: Literal["seen"]
    
    to: int
    from_ : int
    message_id: str

# {
#     "type": "chats",
#     "chats_type": "typing",
#     "to" : 17 
# }

# {
#     "type": "chats",  
#     "chats_type": "seen",
#     "to": 17
# }