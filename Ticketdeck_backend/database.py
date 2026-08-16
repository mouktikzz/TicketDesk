import os
import psycopg2
from psycopg2.extras import RealDictCursor
from pathlib import Path

UPLOADS_DIR = Path(__file__).parent / "uploads"

DATABASE_HOST = os.getenv("DATABASE_HOST", "localhost")
DATABASE_PORT = os.getenv("DATABASE_PORT", "5432")
DATABASE_NAME = os.getenv("DATABASE_NAME", "ticketdesk")
DATABASE_USER = os.getenv("DATABASE_USER", "ticketdesk")
DATABASE_PASSWORD = os.getenv("DATABASE_PASSWORD", "ticketdesk_dev_password")


def get_connection():
    return psycopg2.connect(
        host=DATABASE_HOST,
        port=DATABASE_PORT,
        database=DATABASE_NAME,
        user=DATABASE_USER,
        password=DATABASE_PASSWORD,
        sslmode="require",
        cursor_factory=RealDictCursor,
    )

def init_db() -> None:
    UPLOADS_DIR.mkdir(exist_ok=True)

    with get_connection() as conn:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS tickets (
                    id SERIAL PRIMARY KEY,
                    title TEXT NOT NULL,
                    description TEXT NOT NULL,
                    category TEXT NOT NULL DEFAULT 'Other',
                    priority TEXT NOT NULL DEFAULT 'MEDIUM',
                    status TEXT NOT NULL DEFAULT 'OPEN',
                    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
                );

                CREATE TABLE IF NOT EXISTS comments (
                    id SERIAL PRIMARY KEY,
                    ticket_id INTEGER NOT NULL
                        REFERENCES tickets(id) ON DELETE CASCADE,
                    author TEXT NOT NULL DEFAULT 'Support Agent',
                    body TEXT NOT NULL,
                    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
                );

                CREATE TABLE IF NOT EXISTS attachments (
                    id SERIAL PRIMARY KEY,
                    ticket_id INTEGER NOT NULL
                        REFERENCES tickets(id) ON DELETE CASCADE,
                    filename TEXT NOT NULL,
                    stored_name TEXT NOT NULL,
                    uploaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
                );
                """
            )


# ── Ticket helpers ──────────────────────────────────────────────────────────────

def db_list_tickets(status=None, priority=None, category=None, search=None):
    with get_connection() as conn:
        with conn.cursor() as cursor:

            query = "SELECT * FROM tickets WHERE 1=1"
            params = []

            if status:
                query += " AND status = %s"
                params.append(status)

            if priority:
                query += " AND priority = %s"
                params.append(priority)

            if category:
                query += " AND category = %s"
                params.append(category)

            if search:
                query += " AND (title ILIKE %s OR description ILIKE %s)"
                params.extend([
                    f"%{search}%",
                    f"%{search}%"
                ])

            query += " ORDER BY created_at DESC"

            cursor.execute(query, params)

            return cursor.fetchall()


def db_get_ticket(ticket_id: int):
    with get_connection() as conn:
        with conn.cursor() as cursor:

            cursor.execute(
                "SELECT * FROM tickets WHERE id = %s",
                (ticket_id,)
            )

            ticket = cursor.fetchone()

            if not ticket:
                return None

            ticket = dict(ticket)

            cursor.execute(
                """
                SELECT *
                FROM comments
                WHERE ticket_id = %s
                ORDER BY created_at ASC
                """,
                (ticket_id,)
            )

            ticket["comments"] = cursor.fetchall()

            cursor.execute(
                """
                SELECT *
                FROM attachments
                WHERE ticket_id = %s
                ORDER BY uploaded_at ASC
                """,
                (ticket_id,)
            )

            ticket["attachments"] = cursor.fetchall()

            return ticket


def db_create_ticket(title, description, category, priority) -> dict:
    with get_connection() as conn:
        with conn.cursor() as cursor:

            cursor.execute(
                """
                INSERT INTO tickets
                    (title, description, category, priority)
                VALUES
                    (%s, %s, %s, %s)
                RETURNING id
                """,
                (title, description, category, priority)
            )

            ticket_id = cursor.fetchone()["id"]

            cursor.execute(
                "SELECT * FROM tickets WHERE id = %s",
                (ticket_id,)
            )

            ticket = dict(cursor.fetchone())

            cursor.execute(
                """
                SELECT *
                FROM comments
                WHERE ticket_id = %s
                ORDER BY created_at ASC
                """,
                (ticket_id,)
            )

            ticket["comments"] = cursor.fetchall()

            cursor.execute(
                """
                SELECT *
                FROM attachments
                WHERE ticket_id = %s
                ORDER BY uploaded_at ASC
                """,
                (ticket_id,)
            )

            ticket["attachments"] = cursor.fetchall()

            return ticket


def db_update_status(ticket_id: int, new_status: str):
    with get_connection() as conn:
        with conn.cursor() as cursor:

            cursor.execute(
                """
                UPDATE tickets
                SET status = %s,
                    updated_at = CURRENT_TIMESTAMP
                WHERE id = %s
                """,
                (new_status, ticket_id)
            )

            cursor.execute(
                "SELECT * FROM tickets WHERE id = %s",
                (ticket_id,)
            )

            ticket = cursor.fetchone()

            if not ticket:
                return None

            ticket = dict(ticket)

            cursor.execute(
                """
                SELECT *
                FROM comments
                WHERE ticket_id = %s
                ORDER BY created_at ASC
                """,
                (ticket_id,)
            )

            ticket["comments"] = cursor.fetchall()

            cursor.execute(
                """
                SELECT *
                FROM attachments
                WHERE ticket_id = %s
                ORDER BY uploaded_at ASC
                """,
                (ticket_id,)
            )

            ticket["attachments"] = cursor.fetchall()

            return ticket


# ── Comment helpers ──────────────────────────────────────────────────────────────

def db_add_comment(ticket_id: int, author: str, body: str) -> dict:
    with get_connection() as conn:
        with conn.cursor() as cursor:

            cursor.execute(
                """
                INSERT INTO comments
                    (ticket_id, author, body)
                VALUES
                    (%s, %s, %s)
                RETURNING id
                """,
                (ticket_id, author, body)
            )

            comment_id = cursor.fetchone()["id"]

            cursor.execute(
                "SELECT * FROM comments WHERE id = %s",
                (comment_id,)
            )

            return cursor.fetchone()


# ── Attachment helpers ──────────────────────────────────────────────────────────

def db_add_attachment(
    ticket_id: int,
    filename: str,
    stored_name: str
) -> dict:

    with get_connection() as conn:
        with conn.cursor() as cursor:

            cursor.execute(
                """
                INSERT INTO attachments
                    (ticket_id, filename, stored_name)
                VALUES
                    (%s, %s, %s)
                RETURNING id
                """,
                (ticket_id, filename, stored_name)
            )

            attachment_id = cursor.fetchone()["id"]

            cursor.execute(
                "SELECT * FROM attachments WHERE id = %s",
                (attachment_id,)
            )

            return cursor.fetchone()


# ── Dashboard helpers ──────────────────────────────────────────────────────────────

def db_dashboard_stats() -> dict:
    with get_connection() as conn:
        with conn.cursor() as cursor:

            cursor.execute(
                """
                SELECT status, COUNT(*) AS count
                FROM tickets
                GROUP BY status
                """
            )

            status_rows = cursor.fetchall()

            cursor.execute(
                """
                SELECT priority, COUNT(*) AS count
                FROM tickets
                GROUP BY priority
                """
            )

            priority_rows = cursor.fetchall()

            cursor.execute(
                "SELECT COUNT(*) AS c FROM tickets"
            )

            total = cursor.fetchone()["c"]

            cursor.execute(
                """
                SELECT id, title, status, priority, created_at
                FROM tickets
                ORDER BY created_at DESC
                LIMIT 5
                """
            )

            recent = cursor.fetchall()

            return {
                "total": total,
                "by_status": {
                    r["status"]: r["count"]
                    for r in status_rows
                },
                "by_priority": {
                    r["priority"]: r["count"]
                    for r in priority_rows
                },
                "recent_tickets": recent,
            }