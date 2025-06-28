import json
import os
import importlib
from unittest.mock import MagicMock
import pytest


def _fake_table():
    store = {"count": 0}

    class _T:
        def get_item(self, Key):
            return {"Item": {"count": store["count"]}}

        def update_item(self, **kwargs):
            store["count"] += 1
            return {"Attributes": {"count": store["count"]}}

    return _T()



def _load_handler(monkeypatch):
    fake_boto3 = MagicMock()
    fake_boto3.resource.return_value.Table.return_value = _fake_table()

    
    monkeypatch.setitem(importlib.import_module("sys").modules, "boto3", fake_boto3)

    mod = importlib.import_module("lambda_function")
    importlib.reload(mod)                 
    return mod.lambda_handler



def _extract_count(resp: dict) -> int:
    if "visitors" in resp:                # old shape
        return resp["visitors"]
    return json.loads(resp["body"])["visitors"]



def test_env_set(monkeypatch):
    monkeypatch.setenv("TABLE_NAME", "dummy_table")
    assert "TABLE_NAME" in os.environ


def test_counter_get(monkeypatch):
    monkeypatch.setenv("TABLE_NAME", "dummy_table")
    handler = _load_handler(monkeypatch)

    event = {"requestContext": {"http": {"method": "GET"}}}
    res = handler(event, None)

    assert isinstance(res, dict)
    assert _extract_count(res) == 0


def test_counter_post(monkeypatch):
    monkeypatch.setenv("TABLE_NAME", "dummy_table")
    handler = _load_handler(monkeypatch)

    event = {"requestContext": {"http": {"method": "POST"}}}
    res = handler(event, None)

    assert _extract_count(res) == 1        # first increment
