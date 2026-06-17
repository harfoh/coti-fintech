import pytest
from fastapi.testclient import TestClient
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from main import app

client = TestClient(app)


def test_root():
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert "message" in data
    assert data["status"] == "running"


def test_health_endpoint():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert "version" in data
    assert "environment" in data


def test_status_endpoint():
    response = client.get("/api/v1/status")
    assert response.status_code == 200
    data = response.json()
    assert data["service"] == "payment-api"
    assert "version" in data
    assert data["uptime"] == "ok"


def test_metrics_endpoint():
    response = client.get("/metrics")
    assert response.status_code == 200
    assert b"http_requests_total" in response.content


def test_health_returns_json():
    response = client.get("/health")
    assert response.headers["content-type"] == "application/json"


def test_invalid_route():
    response = client.get("/nonexistent")
    assert response.status_code == 404
