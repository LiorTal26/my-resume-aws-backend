# tests/test_counter.py
import os
from unittest.mock import patch, MagicMock
import importlib


def _fake_table():
    """Very small in-memory stub that looks like a DynamoDB table."""
    store = {"count": 0}

    class _T:
        def get_item(self, Key):
            return {"Item": {"count": store["count"]}}

        def update_item(self, **kwargs):
            store["count"] += 1
            return {"Attributes": {"count": store["count"]}}

    return _T()


def _load_handler(monkeypatch):
    """Patch boto3, then import the Lambda module and return its handler."""
    fake_boto3 = MagicMock()
    fake_boto3.resource.return_value.Table.return_value = _fake_table()

    monkeypatch.setitem(
        importlib.import_module("sys").modules,  # sys.modules
        "boto3",
        fake_boto3,
    )

    # Now import *after* the patch so the module sees our fake boto3
    mod = importlib.import_module("lambda_function")
    return mod.lambda_handler


def test_env_set(monkeypatch):
    monkeypatch.setenv("TABLE_NAME", "dummy_table")
    assert "TABLE_NAME" in os.environ


def test_counter_get(monkeypatch):
    monkeypatch.setenv("TABLE_NAME", "dummy_table")
    handler = _load_handler(monkeypatch)

    event = {"requestContext": {"http": {"method": "GET"}}}
    res = handler(event, None)

    assert isinstance(res, dict)
    assert res["visitors"] == 0


def test_counter_post(monkeypatch):
    monkeypatch.setenv("TABLE_NAME", "dummy_table")
    handler = _load_handler(monkeypatch)

    event = {"requestContext": {"http": {"method": "POST"}}}
    res = handler(event, None)

    assert res["visitors"] == 1        # first increment works
