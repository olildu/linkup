from pydantic import BaseModel, field_validator

class RefreshRequest(BaseModel):
    refresh_token: str

    @field_validator('refresh_token')
    def validate_refresh_token(cls, v):
        if not v:
            raise ValueError('Refresh token cannot be empty')
        return v