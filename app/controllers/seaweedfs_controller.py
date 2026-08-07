import boto3
from botocore.exceptions import ClientError

from app.constants.global_constants import (
    SEAWEEDFS_S3_ENDPOINT,
    SEAWEEDFS_ACCESS_KEY,
    SEAWEEDFS_SECRET_KEY,
    SEAWEEDFS_BUCKET,
)

s3_client = boto3.client(
    "s3",
    endpoint_url=SEAWEEDFS_S3_ENDPOINT,
    aws_access_key_id=SEAWEEDFS_ACCESS_KEY,
    aws_secret_access_key=SEAWEEDFS_SECRET_KEY,
)

_bucket_ready = False


def _ensure_bucket():
    global _bucket_ready
    if _bucket_ready:
        return
    try:
        s3_client.head_bucket(Bucket=SEAWEEDFS_BUCKET)
    except ClientError:
        s3_client.create_bucket(Bucket=SEAWEEDFS_BUCKET)
    _bucket_ready = True


def upload_bytes(content: bytes, file_key: str):
    _ensure_bucket()
    s3_client.put_object(Bucket=SEAWEEDFS_BUCKET, Key=file_key, Body=content)


def upload_file(file_path: str, file_key: str):
    _ensure_bucket()
    s3_client.upload_file(file_path, SEAWEEDFS_BUCKET, file_key)
