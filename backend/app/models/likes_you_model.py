from typing import Optional
from pydantic import BaseModel

from app.models.match_canidate_model import MatchCandidateModel


class LikesYouEntryModel(BaseModel):
    id: int
    revealed: bool
    profile: Optional[MatchCandidateModel] = None
    first_photo: Optional[dict] = None


class LikesYouResponseModel(BaseModel):
    entries: list[LikesYouEntryModel]
    total_count: int
    unseen_count: int
