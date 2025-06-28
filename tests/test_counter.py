# tests/test_counter.py
import os
from unittest.mock import MagicMock, patch
from lambda_src.lambda_function import lambda_handler


def dummy_table():
    """Returns an object that pretends to be a DynamoDB table."""
    store = {"id": "counter", "count": 0}

    class _Table:
        def get_item(self, Key):
            return {"Item": store}

        def update_item(self, **kwargs):
            store["count"] += 1
            return {"Attributes": store}

    return _Table()


def test_env_set(monkeypatch):
    monkeypatch.setenv("TABLE_NAME", "dummy_table")
    assert "TABLE_NAME" in os.environ


@patch("lambda_src.lambda_function.boto3")
def test_counter_returns_dict(mock_boto3, monkeypatch):
    monkeypatch.setenv("TABLE_NAME", "dummy_table")
    # stub boto3.resource("dynamodb").Table(...)
    mock_boto3.resource.return_value.Table.return_value = dummy_table()

    event = {"requestContext": {"http": {"method": "GET"}}}
    result = lambda_handler(event, None)

    assert isinstance(result, dict)
    assert "visitors" in result


@patch("lambda_src.lambda_function.boto3")
def test_counter_post(mock_boto3, monkeypatch):
    monkeypatch.setenv("TABLE_NAME", "dummy_table")
    mock_boto3.resource.return_value.Table.return_value = dummy_table()

    event = {"requestContext": {"http": {"method": "POST"}}}
    res = lambda_handler(event, None)

    assert res["visitors"] >= 1
