import os
import pytest
from lambda_function import lambda_handler


def test_env_set(monkeypatch):
    monkeypatch.setenv("TABLE_NAME", "dummy_table")
    assert "TABLE_NAME" in os.environ


def test_counter_returns_dict(monkeypatch):
    monkeypatch.setenv("TABLE_NAME", "dummy_table")
    event = {"requestContext": {"http": {"method": "GET"}}}
    result = lambda_handler(event, None)
    assert isinstance(result, dict)
    assert "visitors" in result
    
def test_counter_post(monkeypatch):
    monkeypatch.setenv("TABLE_NAME", "dummy_table")
    event = {"requestContext": {"http": {"method": "POST"}}}
    res = lambda_handler(event, None)
    assert res["visitors"] >= 1
