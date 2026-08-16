import base64
import hashlib
import hmac
import time

from app.core.constants.global_constants import (
    IMGPROXY_PUBLIC_URL,
    IMGPROXY_KEY,
    IMGPROXY_SALT,
    SEAWEEDFS_BUCKET,
)


def _sign(path: str) -> str:
    key_bytes = bytes.fromhex(IMGPROXY_KEY)
    salt_bytes = bytes.fromhex(IMGPROXY_SALT)
    digest = hmac.new(key_bytes, salt_bytes + path.encode(), hashlib.sha256).digest()
    return base64.urlsafe_b64encode(digest).rstrip(b"=").decode()


def build_signed_url(file_key: str, expire_seconds: int = 1200) -> str:
    source_url = f"s3://{SEAWEEDFS_BUCKET}/{file_key}"
    encoded_source = base64.urlsafe_b64encode(source_url.encode()).rstrip(b"=").decode()

    expires_at = int(time.time()) + expire_seconds
    path = f"/exp:{expires_at}/{encoded_source}"

    signature = _sign(path)
    return f"{IMGPROXY_PUBLIC_URL}/{signature}{path}"
