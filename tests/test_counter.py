import boto3, os

def test_env_set():
    assert "TABLE_NAME" in os.environ
