import os
from dotenv import load_dotenv

load_dotenv() 

DB_HOST = os.environ.get("DATABASE_HOST")
DB_NAME = os.environ.get("DATABASE_NAME")
DB_USER = os.environ.get("DATABASE_USER")
DB_PASSWORD = os.environ.get("DATABASE_PASSWORD")
DB_PORT = os.environ.get("DATABASE_PORT")