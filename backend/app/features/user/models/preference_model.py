from typing import Optional, Literal
from pydantic import BaseModel, model_validator

class PreferenceModel(BaseModel):
    interested_gender: Optional[Literal["Male", "Female"]] = None

    height: Optional[int] = None
    weight: Optional[int] = None

    religion: Optional[Literal["Islam", "Sikhism", "Jainism", "Christianity", "Hinduism", "Buddhism", "Others"]] = None

    drinking_status: Optional[bool] = None
    smoking_status: Optional[bool] = None 

    looking_for: Optional[Literal["Casual", "Open to anything", "Serious", "Friends"]] = None

    currently_staying: Optional[Literal["Campus Hostel", "PG", "Home", "Flat", "Other"]] = None

    model_config = {
        "extra": "ignore",
    }