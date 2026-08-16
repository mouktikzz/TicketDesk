import importlib
import sys
from pathlib import Path

from fastapi.testclient import TestClient


BACKEND_DIR = Path(__file__).resolve().parents[1]
if str(BACKEND_DIR) not in sys.path:
    sys.path.insert(0, str(BACKEND_DIR))


def _load_app(monkeypatch):
    sys.modules.pop("database", None)
    sys.modules.pop("main", None)

    uploads_dir = BACKEND_DIR / "uploads"
    uploads_dir.mkdir(exist_ok=True)

    import database

    monkeypatch.setattr(database, "init_db", lambda: None)
    main = importlib.import_module("main")
    return main


def test_health_endpoint_returns_ok(monkeypatch):
    main = _load_app(monkeypatch)
    client = TestClient(main.app)

    response = client.get("/api/health")

    assert response.status_code == 200
    assert response.json() == {"status": "ok", "service": "TicketDesk API"}


def test_create_ticket_endpoint_returns_created_ticket(monkeypatch):
    main = _load_app(monkeypatch)
    client = TestClient(main.app)

    fake_ticket = {
        "id": 42,
        "title": "Printer is offline",
        "description": "HP LaserJet in office 2 is not responding.",
        "category": "Hardware",
        "priority": "HIGH",
        "status": "OPEN",
        "created_at": "2024-01-01T00:00:00",
        "updated_at": "2024-01-01T00:00:00",
        "comments": [],
        "attachments": [],
    }

    monkeypatch.setattr(main, "db_create_ticket", lambda **kwargs: fake_ticket)

    response = client.post(
        "/api/tickets",
        json={
            "title": "Printer is offline",
            "description": "HP LaserJet in office 2 is not responding.",
            "category": "Hardware",
            "priority": "HIGH",
        },
    )

    assert response.status_code == 201
    assert response.json()["id"] == 42
    assert response.json()["title"] == "Printer is offline"
    assert response.json()["status"] == "OPEN"
