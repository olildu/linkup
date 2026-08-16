from pydantic import BaseModel

class BlockUserRequest(BaseModel):
    blocked_user_id: int