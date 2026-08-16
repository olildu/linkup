import ast
import json
import re
from typing import Literal, Optional
from matplotlib.dates import relativedelta
from pydantic import BaseModel, EmailStr, field_validator, model_validator
from datetime import date, datetime

from app.utilities.common.common_utilites import get_signed_imagekit

class MatchCandidateModel(BaseModel):
    #Core
    id: int
    username: str
    gender: Literal["Male", "Female"]
    university_id: int
    profile_picture: dict
    
    #Metadata
    dob: date

    university_major: str
    university_year: int
 
    photos: list[dict]
    about: str

    currently_staying: Literal["Campus Hostel", "PG", "Home", "Flat", "Other"]
    hometown: str

    #Interests
    height: Optional[int] = None
    weight: Optional[int] = None

    religion: Optional[Literal["Islam", "Sikhism", "Jainism", "Christianity", "Hinduism", "Buddhism", "Others"]]

    smoking_info: Optional[Literal["Yes","Trying to quit","Occasionally","No","No, prefer non-smokers"]]
    drinking_info: Optional[Literal["Yes","Trying to quit","Occasionally","No","No, prefer non-drinkers"]]

    looking_for: Optional[Literal["Casual", "Open to anything", "Serious", "Friends", "Not sure yet"]]

    model_config = {
        "extra": "ignore",
    }

def build_candidate_model(user_metadata: dict, core_data: tuple) -> MatchCandidateModel:
    """
    user_metadata: dict mapping metadata key -> value for a single user
    core_data: tuple(username, gender, university_id, profile_picture)
    """

    def sanitize(value):
        if value is None:
            return None
        value = str(value).strip()
        return None if value.lower() == "none" or value == "" else value

    typed_data = {
        "id": core_data[0],
        "username": core_data[1],
        "gender": core_data[2],
        "university_id": int(core_data[3]),
        "profile_picture": get_signed_imagekit(json.loads(core_data[4])),

        "dob": datetime.strptime(user_metadata["dob"], "%Y-%m-%d").date(),

        "university_major": sanitize(user_metadata["university_major"]),
        "university_year": int(user_metadata["university_year"]),

        "photos": [get_signed_imagekit(image_metadata=img) for img in ast.literal_eval(user_metadata.get("photos", "[]"))],
        "about": sanitize(user_metadata["about"]),
        "currently_staying": sanitize(user_metadata["currently_staying"]),
        "hometown": sanitize(user_metadata["hometown"]),

        "height": int(user_metadata["height"]) if sanitize(user_metadata.get("height")) else None,
        "weight": int(user_metadata["weight"]) if sanitize(user_metadata.get("weight")) else None,

        "religion": sanitize(user_metadata.get("religion")),
        "smoking_info": sanitize(user_metadata.get("smoking_info")),
        "drinking_info": sanitize(user_metadata.get("drinking_info")),
        "looking_for": sanitize(user_metadata.get("looking_for")),
    }

    return MatchCandidateModel(**typed_data)