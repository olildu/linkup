from pydantic import BaseModel

class ReportUserRequest(BaseModel):
    reported_user_id: int
    reason: str