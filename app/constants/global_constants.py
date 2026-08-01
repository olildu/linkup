# In-memory user store
import os
from dotenv import load_dotenv
from fastapi.security import OAuth2PasswordBearer

load_dotenv() 

SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM = os.getenv("ALGORITHM", "HS256") 
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", 60))
EMAIL_TOKEN_EXPIRE_MINUTES = int(os.getenv("EMAIL_TOKEN_EXPIRE_MINUTES", 60))
REFRESH_TOKEN_EXPIRE_DAYS = int(os.getenv("REFRESH_TOKEN_EXPIRE_DAYS", 7))
DAILY_LIKE_LIMIT = int(os.getenv("DAILY_LIKE_LIMIT", 10))
STATUS_PAGE_TOKEN = os.getenv("STATUS_PAGE_TOKEN")

APPLICATION_KEY_ID = os.environ.get("APPLICATION_KEY_ID")
APPLICATION_KEY = os.environ.get("APPLICATION_KEY")
BUCKET_NAME = os.environ.get("BUCKET_NAME")
B2_ENDPOINT = os.environ.get("B2_ENDPOINT")

IMAGEKIT_PUBLIC_KEY = os.environ.get("IMAGEKIT_PUBLIC_KEY")
IMAGEKIT_PRIVATE_KEY = os.environ.get("IMAGEKIT_PRIVATE_KEY")
IMAGEKIT_ENDPOINT_URL = os.environ.get("IMAGEKIT_ENDPOINT_URL")

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")