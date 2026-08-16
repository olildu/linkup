"""Unit test for the create-bucket-if-missing branch in
app/controllers/seaweedfs_controller.py, which only runs once per process
(cached via the `_bucket_ready` flag) and is otherwise never exercised since
the test bucket already exists by the time the suite runs."""
from botocore.exceptions import ClientError

import app.core.controllers.seaweedfs_controller as seaweedfs_module


def test_ensure_bucket_creates_when_missing(monkeypatch):
    created = {}
    monkeypatch.setattr(seaweedfs_module, "_bucket_ready", False)
    monkeypatch.setattr(
        seaweedfs_module.s3_client,
        "head_bucket",
        lambda **kw: (_ for _ in ()).throw(
            ClientError({"Error": {"Code": "404", "Message": "Not Found"}}, "HeadBucket")
        ),
    )
    monkeypatch.setattr(
        seaweedfs_module.s3_client, "create_bucket", lambda **kw: created.setdefault("bucket", kw)
    )

    seaweedfs_module._ensure_bucket()

    assert created["bucket"]["Bucket"] == seaweedfs_module.SEAWEEDFS_BUCKET
    assert seaweedfs_module._bucket_ready is True
