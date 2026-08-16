import asyncpg
import psycopg2
from psycopg2 import pool
from app.core.constants.db_constants import DB_HOST, DB_NAME, DB_PASSWORD, DB_PORT, DB_USER

# Create a ThreadedConnectionPool instead of a single connection
try:
    db_pool = psycopg2.pool.ThreadedConnectionPool(
        1, 20,
        host=DB_HOST, 
        database=DB_NAME, 
        user=DB_USER, 
        password=DB_PASSWORD, 
        port=DB_PORT
    )
except Exception as error:
    print("Error while connecting to PostgreSQL", error)

async def create_pool():
    return await asyncpg.create_pool(
        host=DB_HOST,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        port=DB_PORT
    )