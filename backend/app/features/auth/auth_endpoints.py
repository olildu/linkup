import asyncio
from datetime import timedelta
from fastapi import Depends, HTTPException, APIRouter, status
from fastapi.security import OAuth2PasswordRequestForm
from jose import ExpiredSignatureError, JWTError
import jwt
from pydantic import EmailStr

from app.core.constants.global_constants import ACCESS_TOKEN_EXPIRE_MINUTES, ALGORITHM, SECRET_KEY

from app.features.auth.models.refresh_request_modal import RefreshRequest
from app.features.auth.models.register_request_model import RegisterRequest

from app.features.auth.models.signup_request_model import SignUpRequest
from app.features.auth.auth_utilities import EmailOTPData, add_partial_user_to_db, generate_otp, send_otp_email, store_otp, verify_otp_internal, reset_user_password
from app.features.auth.auth_exceptions import assert_under_login_attempt_limit, record_failed_login_attempt, reset_login_attempts
from app.features.auth.password_utilities import hash_password, verify_password
from app.core.token_utilities import create_access_token, create_refresh_token, decode_token
from app.features.user.user_db_utilities import add_user_to_db, get_user_from_db
from app.features.user.user_utilities import get_user_details

from app.core.constants.global_constants import oauth2_scheme

from app.core.controllers.route_controller import *

auth_router = APIRouter()

@auth_router.post("/signup")
async def signup(data: SignUpRequest):
    return add_partial_user_to_db(data)

@auth_router.post("/register")
async def register(data: RegisterRequest, token: str = Depends(oauth2_scheme)):
    user_id = decode_token(token=token)
    user = data.to_user_model(user_id=user_id)
 
    return {"msg": add_user_to_db(user)}

@auth_router.post("/reset-password")
async def reset_password(data: SignUpRequest):
    return reset_user_password(data)

@auth_router.post("/verify-otp")
async def verify_otp(data: EmailOTPData):
    return verify_otp_internal(data)

@auth_router.get("/verify-email")
def send_otp(email: EmailStr):
    otp = generate_otp()
    store_otp(email, otp)
    send_otp_email(email, otp)
    return {"message": "OTP sent",}

@auth_router.post("/token")
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    email = form_data.username
    assert_under_login_attempt_limit(email)

    user = get_user_from_db(email=email)
    if user is None:
        record_failed_login_attempt(email)
        raise HTTPException(status_code=404, detail="No account found with this email")

    if not verify_password(form_data.password, user["hashed_password"]):
        record_failed_login_attempt(email)
        raise HTTPException(status_code=400, detail="Invalid username or password")

    reset_login_attempts(email)

    access_token = create_access_token(
        data={"id": user['id'], "email" : user['email']},
        expires_delta=timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    )
    refresh_token = create_refresh_token(
        data={"id": user['id'], "email" : user['email']},
    )

    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "user_id": user['id']
    }

@auth_router.post("/refresh")
async def refresh_token(data: RefreshRequest):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Invalid refresh token",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        token = data.refresh_token
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        id = payload.get("id")
        email = payload.get("email")

        if id is None or get_user_from_db(id=id) is None:
            raise credentials_exception
        
        new_access_token = create_access_token(
            data={"id": id, "email" : email},
            expires_delta=timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
        )
        return {"access_token": new_access_token, "token_type": "bearer"}
    except ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Refresh token expired")

    except jwt.InvalidTokenError:
        raise credentials_exception

@auth_router.get("/me")
async def read_me(token: str = Depends(oauth2_scheme)):
    user_id = decode_token(token)
    return get_user_details(user_id)