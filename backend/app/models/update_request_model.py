from typing import Optional, Literal
from pydantic import BaseModel, model_validator

class UpdateRequestModel(BaseModel):
    # Core
    photos: Optional[list[dict]] = None
    profile_picture: Optional[dict] = None

    about: Optional[str] = None

    currently_staying: Optional[Literal["Campus Hostel", "PG", "Home", "Flat", "Other"]] = None
    hometown: Optional[str] = None

    # Interests
    height: Optional[int] = None
    weight: Optional[int] = None

    religion: Optional[Literal["Islam", "Sikhism", "Jainism", "Christianity", "Hinduism", "Buddhism", "Others"]] = None

    smoking_info: Optional[Literal["Yes", "Trying to quit", "Occasionally", "No", "No, prefer non-smokers"]] = None
    drinking_info: Optional[Literal["Yes", "Trying to quit", "Occasionally", "No", "No, prefer non-drinkers"]] = None

    drinking_status: Optional[bool] = None
    smoking_status: Optional[bool] = None

    looking_for: Optional[Literal["Casual", "Open to anything", "Serious", "Friends", "Not sure yet"]] = None

    model_config = {
        "extra": "ignore",
    }

    @model_validator(mode='before')
    def derive_smoking_status(cls, values):
        smoking_info = values.get('smoking_info')
        values['smoking_status'] = smoking_info != "No"
        return values

    @model_validator(mode='before')
    def derive_drinking_status(cls, values):
        drinking_info = values.get('drinking_info')
        values['drinking_status'] = drinking_info != "No"
        return values
