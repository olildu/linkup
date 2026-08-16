from pydantic import BaseModel

class SwipeRequest(BaseModel):
    liked_id: int