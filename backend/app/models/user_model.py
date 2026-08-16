import ast
import json
from typing import Literal, Optional
from matplotlib.dates import relativedelta
from pydantic import BaseModel, EmailStr, field_validator, model_validator
from datetime import date, datetime

from app.utilities.common.common_utilites import get_signed_imagekit


class UserModel(BaseModel):
    id: Optional[int] = None

    email: Optional[EmailStr] = None
    hashed_password: Optional[str] = None
    username: Optional[str] = None
    gender: Optional[Literal["Male", "Female"]] = None
    university_id: int
    profile_picture: Optional[dict] = None

    dob: Optional[date] = None
    interested_gender: Optional[Literal["Male", "Female"]] = None

    university_major: Optional[str] = None
    university_year: Optional[int] = None

    photos: list[dict] = []
    about: Optional[str] = None

    currently_staying: Optional[Literal["Campus Hostel", "PG", "Home", "Flat", "Other"]] = None
    hometown: Optional[str] = None

    height: Optional[int] = None
    weight: Optional[int] = None

    religion: Optional[Literal["Islam", "Sikhism", "Jainism", "Christianity", "Hinduism", "Buddhism", "Others"]] = None

    smoking_info: Optional[Literal["Yes", "Trying to quit", "Occasionally", "No", "No, prefer non-smokers"]] = None
    smoking_status: Optional[bool] = None

    drinking_info: Optional[Literal["Yes", "Trying to quit", "Occasionally", "No", "No, prefer non-drinkers"]] = None
    drinking_status: Optional[bool] = None

    looking_for: Optional[Literal["Casual", "Open to anything", "Serious", "Friends", "Not sure yet"]] = None

    model_config = {
        "extra": "ignore",
    }


def build_user_model(user_metadata: list, core_data: list, hashed_password: str, user_preferences: list):
    metadata_dict = {item[2]: item[3] for item in user_metadata}
    user_preferences_dict = {item[2]: item[3] for item in user_preferences}

    def parse_optional_int(value):
        return int(value) if value and str(value).isdigit() else None

    def parse_optional_bool(value):
        return value.lower() == "true" if value else None

    def parse_optional_str(value):
        return value.strip() if value and value.strip().lower() != "none" else None

    def parse_date(value):
        try:
            return datetime.strptime(value, "%Y-%m-%d").date() if value else None
        except:
            return None

    def validate_literal(value, allowed):
        v = parse_optional_str(value)
        return v if v in allowed else None

    id = int(core_data[0])
    email = core_data[1]

    username = core_data[2] if len(core_data) > 2 else None
    gender = validate_literal(core_data[3] if len(core_data) > 3 else None, ["Male", "Female"])
    university_id = int(core_data[4]) if len(core_data) > 4 and str(core_data[4]).isdigit() else -1
    
    try:
        profile_picture = get_signed_imagekit(json.loads(core_data[5])) if len(core_data) > 5 and core_data[5] else None
    except Exception:
        profile_picture = None

    typed_data = {
        "id": id,
        "email": email,
        "hashed_password": hashed_password,
        "username": username,
        "dob": parse_date(metadata_dict.get("dob")),
        "gender": gender,
        "interested_gender": validate_literal(user_preferences_dict.get("interested_gender"), ["Male", "Female"]),
        "university_major": parse_optional_str(metadata_dict.get("university_major")),
        "university_year": parse_optional_int(metadata_dict.get("university_year")),
        "university_id": university_id,
        "profile_picture": profile_picture,
        "photos": [get_signed_imagekit(image_metadata=img) for img in ast.literal_eval(metadata_dict.get("photos", "[]"))],
        "about": parse_optional_str(metadata_dict.get("about")),
        "currently_staying": validate_literal(metadata_dict.get("currently_staying"), ["Campus Hostel", "PG", "Home", "Flat", "Other"]),
        "hometown": parse_optional_str(metadata_dict.get("hometown")),
        "height": parse_optional_int(metadata_dict.get("height")),
        "weight": parse_optional_int(metadata_dict.get("weight")),
        "religion": validate_literal(metadata_dict.get("religion"), ["Islam", "Sikhism", "Jainism", "Christianity", "Hinduism", "Buddhism", "Others"]),
        "smoking_info": validate_literal(metadata_dict.get("smoking_info"), ["Yes", "Trying to quit", "Occasionally", "No", "No, prefer non-smokers"]),
        "smoking_status": parse_optional_bool(metadata_dict.get("smoking_status")),
        "drinking_info": validate_literal(metadata_dict.get("drinking_info"), ["Yes", "Trying to quit", "Occasionally", "No", "No, prefer non-drinkers"]),
        "drinking_status": parse_optional_bool(metadata_dict.get("drinking_status")),
        "looking_for": validate_literal(metadata_dict.get("looking_for"), ["Casual", "Open to anything", "Serious", "Friends", "Not sure yet"]),
    }

    return UserModel(**typed_data)
