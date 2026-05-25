"""
Simulation-only FastAPI backend for the Complaint & Feedback prototype.

No database is used: all data lives in Python dicts/lists in this process and
is lost on restart. Authentication is a plain Bearer token equal to the user's
email (simple, demo-only).
"""
from __future__ import annotations

import os
import shutil
import uuid
from datetime import datetime, timezone
from typing import Any, Optional

from fastapi import (
    Depends,
    FastAPI,
    File,
    Form,
    HTTPException,
    Request,
    UploadFile,
    status,
)
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel, EmailStr, Field

# ---------------------------------------------------------------------------
# In-memory "database"
# ---------------------------------------------------------------------------

UPLOADS_DIR = os.path.join(os.path.dirname(__file__), "uploads")
os.makedirs(UPLOADS_DIR, exist_ok=True)


def _now() -> str:
    return datetime.now(timezone.utc).isoformat()


# Each entry: id, full_name, email, phone, role, is_active, created_at, password
USERS: list[dict[str, Any]] = []
# id, name, description
CATEGORIES: list[dict[str, Any]] = []
# id, title, description, location, attachment, status, priority,
# admin_response, created_at, updated_at, user_id, category_id
COMPLAINTS: list[dict[str, Any]] = []
# id, complaint_id, author_id, message, created_at
COMMENTS: list[dict[str, Any]] = []
# id, user_id, title, body, is_read, complaint_id, created_at
NOTIFICATIONS: list[dict[str, Any]] = []

_ID = {"v": 1000}


def _next_id() -> int:
    _ID["v"] += 1
    return _ID["v"]


def _seed() -> None:
    USERS.extend(
        [
            {
                "id": 1,
                "full_name": "System Admin",
                "email": "admin@example.com",
                "phone": None,
                "role": "admin",
                "is_active": True,
                "created_at": _now(),
                "password": "admin123",
            },
            {
                "id": 2,
                "full_name": "Demo User",
                "email": "user@example.com",
                "phone": "+251900000000",
                "role": "user",
                "is_active": True,
                "created_at": _now(),
                "password": "user123",
            },
            {
                "id": 3,
                "full_name": "Alemu Bekele",
                "email": "alemu@example.com",
                "phone": "+251911111111",
                "role": "user",
                "is_active": True,
                "created_at": _now(),
                "password": "pass123",
            },
            {
                "id": 4,
                "full_name": "Sara Tesfaye",
                "email": "sara@example.com",
                "phone": "+251922222222",
                "role": "user",
                "is_active": True,
                "created_at": _now(),
                "password": "pass123",
            },
            {
                "id": 5,
                "full_name": "Daniel Mekonnen",
                "email": "daniel@example.com",
                "phone": None,
                "role": "staff",
                "is_active": True,
                "created_at": _now(),
                "password": "staff123",
            },
        ]
    )
    for i, (n, d) in enumerate(
        [
            ("Infrastructure", "Roads, buildings, utilities"),
            ("Sanitation", "Garbage, cleanliness, hygiene"),
            ("Academic", "Class, exam, faculty related"),
            ("IT Services", "Network, accounts, systems"),
            ("Security", "Safety and security concerns"),
            ("Other", "Anything else"),
        ],
        start=1,
    ):
        CATEGORIES.append({"id": i, "name": n, "description": d})

    # No pre-seeded complaints or notifications: those are only ever created
    # when users submit them through the app.


_seed()


# ---------------------------------------------------------------------------
# Auth (token = email)
# ---------------------------------------------------------------------------

bearer = HTTPBearer(auto_error=False)


def _find_user_by_email(email: str) -> Optional[dict[str, Any]]:
    email = email.strip().lower()
    for u in USERS:
        if u["email"].lower() == email:
            return u
    return None


def current_user(
    creds: Optional[HTTPAuthorizationCredentials] = Depends(bearer),
) -> dict[str, Any]:
    if creds is None or not creds.credentials:
        raise HTTPException(status_code=401, detail="Unauthorized")
    user = _find_user_by_email(creds.credentials)
    if not user or not user.get("is_active", True):
        raise HTTPException(status_code=401, detail="Invalid or expired token")
    return user


def require_admin(user: dict[str, Any] = Depends(current_user)) -> dict[str, Any]:
    if user["role"] not in ("admin", "staff"):
        raise HTTPException(status_code=403, detail="Admin access required")
    return user


def public_user(u: dict[str, Any]) -> dict[str, Any]:
    return {k: v for k, v in u.items() if k != "password"}


def category_of(cid: Optional[int]) -> Optional[dict[str, Any]]:
    if cid is None:
        return None
    for c in CATEGORIES:
        if c["id"] == cid:
            return c
    return None


def serialize_complaint(c: dict[str, Any]) -> dict[str, Any]:
    user = next((u for u in USERS if u["id"] == c["user_id"]), None)
    return {
        "id": c["id"],
        "title": c["title"],
        "description": c["description"],
        "location": c["location"],
        "attachment": c["attachment"],
        "status": c["status"],
        "priority": c["priority"],
        "admin_response": c["admin_response"],
        "created_at": c["created_at"],
        "updated_at": c["updated_at"],
        "user_id": c["user_id"],
        "user_name": user["full_name"] if user else None,
        "category": category_of(c["category_id"]),
    }


# ---------------------------------------------------------------------------
# Schemas
# ---------------------------------------------------------------------------

class LoginIn(BaseModel):
    email: EmailStr
    password: str


class RegisterIn(BaseModel):
    full_name: str = Field(min_length=1)
    email: EmailStr
    password: str = Field(min_length=4)
    phone: Optional[str] = None


class CommentIn(BaseModel):
    message: str = Field(min_length=1)


class StatusIn(BaseModel):
    status: Optional[str] = None
    admin_response: Optional[str] = None
    priority: Optional[str] = None


class CategoryIn(BaseModel):
    name: str = Field(min_length=1)
    description: Optional[str] = None


# ---------------------------------------------------------------------------
# App
# ---------------------------------------------------------------------------

app = FastAPI(title="Complaint & Feedback (Simulated)", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.mount("/uploads", StaticFiles(directory=UPLOADS_DIR), name="uploads")


@app.exception_handler(HTTPException)
async def http_exc(_: Request, exc: HTTPException) -> JSONResponse:
    return JSONResponse(
        status_code=exc.status_code, content={"detail": str(exc.detail)}
    )


@app.get("/")
def root() -> dict[str, Any]:
    return {
        "name": "Complaint & Feedback (Simulated)",
        "users": len(USERS),
        "complaints": len(COMPLAINTS),
        "note": "All data is in-memory. Restart wipes everything.",
    }


# ----- Auth -----

@app.post("/auth/login")
def login(body: LoginIn) -> dict[str, Any]:
    u = _find_user_by_email(body.email)
    if not u or u["password"] != body.password:
        raise HTTPException(401, "Invalid credentials")
    return {
        "access_token": u["email"],
        "token_type": "bearer",
        "user": public_user(u),
    }


@app.post("/auth/register")
def register(body: RegisterIn) -> dict[str, Any]:
    if _find_user_by_email(body.email):
        raise HTTPException(400, "Email already registered")
    u = {
        "id": _next_id(),
        "full_name": body.full_name,
        "email": body.email.lower(),
        "phone": body.phone,
        "role": "user",
        "is_active": True,
        "created_at": _now(),
        "password": body.password,
    }
    USERS.append(u)
    return {
        "access_token": u["email"],
        "token_type": "bearer",
        "user": public_user(u),
    }


@app.get("/auth/me")
def me(user: dict[str, Any] = Depends(current_user)) -> dict[str, Any]:
    return public_user(user)


# ----- Categories -----

@app.get("/categories/")
def list_categories() -> list[dict[str, Any]]:
    return list(CATEGORIES)


@app.post("/categories/", status_code=201)
def create_category(
    body: CategoryIn, _: dict[str, Any] = Depends(require_admin)
) -> dict[str, Any]:
    if any(c["name"].lower() == body.name.lower() for c in CATEGORIES):
        raise HTTPException(400, "Category exists")
    c = {"id": _next_id(), "name": body.name, "description": body.description}
    CATEGORIES.append(c)
    return c


@app.delete("/categories/{cid}")
def delete_category(
    cid: int, _: dict[str, Any] = Depends(require_admin)
) -> dict[str, Any]:
    for i, c in enumerate(CATEGORIES):
        if c["id"] == cid:
            CATEGORIES.pop(i)
            return {"ok": True}
    raise HTTPException(404, "Not found")


# ----- Complaints -----

@app.get("/complaints/")
def list_complaints(
    status: Optional[str] = None,
    category_id: Optional[int] = None,
    search: Optional[str] = None,
    user: dict[str, Any] = Depends(current_user),
) -> list[dict[str, Any]]:
    rows = COMPLAINTS
    if user["role"] == "user":
        rows = [c for c in rows if c["user_id"] == user["id"]]
    if status:
        rows = [c for c in rows if c["status"] == status]
    if category_id is not None:
        rows = [c for c in rows if c["category_id"] == category_id]
    if search:
        s = search.lower()
        rows = [
            c for c in rows
            if s in c["title"].lower() or s in c["description"].lower()
        ]
    out = [serialize_complaint(c) for c in rows]
    out.sort(key=lambda x: x["created_at"], reverse=True)
    return out


@app.post("/complaints/", status_code=201)
async def create_complaint(
    title: str = Form(...),
    description: str = Form(...),
    priority: str = Form("medium"),
    location: Optional[str] = Form(None),
    category_id: Optional[int] = Form(None),
    attachment: Optional[UploadFile] = File(None),
    user: dict[str, Any] = Depends(current_user),
) -> dict[str, Any]:
    saved_name: Optional[str] = None
    if attachment is not None and attachment.filename:
        ext = os.path.splitext(attachment.filename)[1]
        saved_name = f"{uuid.uuid4().hex}{ext}"
        dest = os.path.join(UPLOADS_DIR, saved_name)
        with open(dest, "wb") as f:
            shutil.copyfileobj(attachment.file, f)
    now = _now()
    row = {
        "id": _next_id(),
        "title": title,
        "description": description,
        "location": location,
        "attachment": saved_name,
        "status": "pending",
        "priority": priority,
        "admin_response": None,
        "created_at": now,
        "updated_at": now,
        "user_id": user["id"],
        "category_id": category_id,
    }
    COMPLAINTS.append(row)
    admin = next((u for u in USERS if u["role"] == "admin"), None)
    if admin:
        NOTIFICATIONS.append({
            "id": _next_id(),
            "user_id": admin["id"],
            "title": f"New complaint #{row['id']}",
            "body": row["title"],
            "is_read": False,
            "complaint_id": row["id"],
            "created_at": now,
        })
    return serialize_complaint(row)


def _find_complaint(cid: int) -> dict[str, Any]:
    for c in COMPLAINTS:
        if c["id"] == cid:
            return c
    raise HTTPException(404, "Not found")


@app.get("/complaints/{cid}")
def get_complaint(
    cid: int, user: dict[str, Any] = Depends(current_user)
) -> dict[str, Any]:
    c = _find_complaint(cid)
    if user["role"] == "user" and c["user_id"] != user["id"]:
        raise HTTPException(403, "Forbidden")
    base = serialize_complaint(c)
    cs = sorted(
        (cm for cm in COMMENTS if cm["complaint_id"] == cid),
        key=lambda x: x["created_at"],
    )
    base["comments"] = [
        {
            "id": cm["id"],
            "message": cm["message"],
            "author_id": cm["author_id"],
            "author_name": next(
                (u["full_name"] for u in USERS if u["id"] == cm["author_id"]), None
            ),
            "created_at": cm["created_at"],
        }
        for cm in cs
    ]
    return base


@app.delete("/complaints/{cid}")
def delete_complaint(
    cid: int, user: dict[str, Any] = Depends(current_user)
) -> dict[str, Any]:
    c = _find_complaint(cid)
    if user["role"] == "user" and c["user_id"] != user["id"]:
        raise HTTPException(403, "Forbidden")
    COMPLAINTS.remove(c)
    COMMENTS[:] = [cm for cm in COMMENTS if cm["complaint_id"] != cid]
    return {"ok": True}


@app.post("/complaints/{cid}/comments", status_code=201)
def add_comment(
    cid: int, body: CommentIn, user: dict[str, Any] = Depends(current_user)
) -> dict[str, Any]:
    c = _find_complaint(cid)
    if user["role"] == "user" and c["user_id"] != user["id"]:
        raise HTTPException(403, "Forbidden")
    now = _now()
    cm = {
        "id": _next_id(),
        "complaint_id": cid,
        "author_id": user["id"],
        "message": body.message,
        "created_at": now,
    }
    COMMENTS.append(cm)
    if user["role"] == "user":
        admin = next((u for u in USERS if u["role"] == "admin"), None)
        target_id = admin["id"] if admin else None
    else:
        target_id = c["user_id"]
    if target_id is not None:
        NOTIFICATIONS.append({
            "id": _next_id(),
            "user_id": target_id,
            "title": (
                f"New comment on #{cid}" if user["role"] == "user"
                else f"Admin replied on #{cid}"
            ),
            "body": body.message[:120],
            "is_read": False,
            "complaint_id": cid,
            "created_at": now,
        })
    return {
        "id": cm["id"],
        "message": cm["message"],
        "author_id": cm["author_id"],
        "author_name": user["full_name"],
        "created_at": cm["created_at"],
    }


@app.patch("/complaints/{cid}/status")
def update_status(
    cid: int, body: StatusIn, user: dict[str, Any] = Depends(require_admin)
) -> dict[str, Any]:
    c = _find_complaint(cid)
    if body.status is not None:
        c["status"] = body.status
    if body.admin_response is not None:
        c["admin_response"] = body.admin_response
    if body.priority is not None:
        c["priority"] = body.priority
    c["updated_at"] = _now()
    NOTIFICATIONS.append({
        "id": _next_id(),
        "user_id": c["user_id"],
        "title": f"Complaint #{c['id']} updated",
        "body": f"Status: {c['status']}",
        "is_read": False,
        "complaint_id": c["id"],
        "created_at": c["updated_at"],
    })
    return serialize_complaint(c)


# ----- Notifications -----

@app.get("/notifications/")
def list_notifications(
    user: dict[str, Any] = Depends(current_user),
) -> list[dict[str, Any]]:
    mine = [n for n in NOTIFICATIONS if n["user_id"] == user["id"]]
    mine.sort(key=lambda x: x["created_at"], reverse=True)
    return mine


@app.post("/notifications/read-all")
def read_all(user: dict[str, Any] = Depends(current_user)) -> dict[str, Any]:
    for n in NOTIFICATIONS:
        if n["user_id"] == user["id"]:
            n["is_read"] = True
    return {"ok": True}


# ----- Users / Admin -----

@app.get("/users/")
def list_users(
    _: dict[str, Any] = Depends(require_admin),
) -> list[dict[str, Any]]:
    return [public_user(u) for u in USERS]


@app.get("/admin/stats")
def admin_stats(_: dict[str, Any] = Depends(require_admin)) -> dict[str, Any]:
    counts = {"pending": 0, "in_progress": 0, "resolved": 0, "rejected": 0}
    by_category: dict[str, int] = {}
    for c in COMPLAINTS:
        if c["status"] in counts:
            counts[c["status"]] += 1
        cat = category_of(c["category_id"])
        key = cat["name"] if cat else "Uncategorized"
        by_category[key] = by_category.get(key, 0) + 1
    return {
        "total": len(COMPLAINTS),
        **counts,
        "users": len(USERS),
        "by_category": by_category,
    }
