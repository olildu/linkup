import json
import uuid
from datetime import timedelta

import boto3
import psycopg2
import pytest
from fastapi.testclient import TestClient
from psycopg2.extras import Json

from app.core.constants.db_constants import DB_HOST, DB_NAME, DB_PASSWORD, DB_PORT, DB_USER
from app.core.constants.global_constants import (
    SEAWEEDFS_ACCESS_KEY,
    SEAWEEDFS_BUCKET,
    SEAWEEDFS_S3_ENDPOINT,
    SEAWEEDFS_SECRET_KEY,
)
from app.main import app
from app.core.token_utilities import create_access_token


@pytest.fixture(scope="session")
def db_conn():
    conn = psycopg2.connect(
        host=DB_HOST, dbname=DB_NAME, user=DB_USER, password=DB_PASSWORD, port=DB_PORT
    )
    conn.autocommit = True
    yield conn
    conn.close()


@pytest.fixture
def db_cursor(db_conn):
    cur = db_conn.cursor()
    yield cur
    cur.close()


@pytest.fixture
def make_user(db_cursor):
    """Factory fixture: creates a minimal, valid user row (+ optional
    metadata/preferences/photos/profile_picture) and tears it down after the
    test. Returns the new user_id.
    """
    created_ids = []

    def _make_user(
        profile_picture: dict | None = None,
        photos: list[dict] | None = None,
        metadata: dict | None = None,
        preferences: dict | None = None,
    ) -> int:
        email = f"pytest_{uuid.uuid4().hex}@example.com"
        db_cursor.execute(
            """
            INSERT INTO users (email, username, password_hash, university_id, gender, profile_picture, is_profile_complete)
            VALUES (%s, %s, 'x', 1, 'Male', %s, TRUE)
            RETURNING id;
            """,
            (email, f"user_{uuid.uuid4().hex[:8]}", Json(profile_picture) if profile_picture else None),
        )
        user_id = db_cursor.fetchone()[0]
        created_ids.append(user_id)

        full_metadata = {
            "dob": "2000-01-01",
            "university_major": "CS",
            "university_year": "2",
            "about": "test bio",
            "currently_staying": "Campus Hostel",
            "hometown": "Testville",
            **(metadata or {}),
        }
        if photos is not None:
            full_metadata["photos"] = repr(photos)

        for key, value in full_metadata.items():
            db_cursor.execute(
                "INSERT INTO user_metadata (user_id, key, value) VALUES (%s, %s, %s);",
                (user_id, key, value),
            )

        for key, value in (preferences or {"interested_gender": "Female"}).items():
            db_cursor.execute(
                "INSERT INTO user_preferences (user_id, key, value) VALUES (%s, %s, %s);",
                (user_id, key, value),
            )

        return user_id

    yield _make_user

    for user_id in created_ids:
        db_cursor.execute("DELETE FROM users WHERE id = %s;", (user_id,))


@pytest.fixture
def auth_header():
    def _auth_header(user_id: int) -> dict:
        token = create_access_token(data={"id": user_id, "email": "x@example.com"}, expires_delta=timedelta(minutes=30))
        return {"Authorization": f"Bearer {token}"}

    return _auth_header


@pytest.fixture
def client():
    return TestClient(app)


@pytest.fixture(scope="session")
def s3_client():
    return boto3.client(
        "s3",
        endpoint_url=SEAWEEDFS_S3_ENDPOINT,
        aws_access_key_id=SEAWEEDFS_ACCESS_KEY,
        aws_secret_access_key=SEAWEEDFS_SECRET_KEY,
    )


@pytest.fixture
def seaweed_object(s3_client):
    """Cleans up any sw/ objects created by a test, tracked by key."""
    created_keys = []

    def _track(key: str):
        created_keys.append(key)
        return key

    yield _track

    for key in created_keys:
        s3_client.delete_object(Bucket=SEAWEEDFS_BUCKET, Key=key)
