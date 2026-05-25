# Simulated Backend (FastAPI, no database)

A demo-only FastAPI server for the Complaint & Feedback prototype. **All data lives in Python variables** (`USERS`, `COMPLAINTS`, `CATEGORIES`, `COMMENTS`, `NOTIFICATIONS`) inside `main.py` and is wiped when the process restarts.

Auth is intentionally trivial: after `/auth/login` or `/auth/register` the server returns `access_token = <user email>`. Clients send `Authorization: Bearer <email>` to identify themselves.

## Run

```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Open http://localhost:8000/docs for the interactive Swagger UI.

## Seeded accounts

| Email                | Password  | Role  |
|----------------------|-----------|-------|
| admin@example.com    | admin123  | admin |
| user@example.com     | user123   | user  |
| alemu@example.com    | pass123   | user  |
| sara@example.com     | pass123   | user  |
| daniel@example.com   | staff123  | staff |

`POST /auth/register` adds a new user to the in-memory `USERS` list — that list IS the "database".

## Endpoints

- `POST /auth/login`, `POST /auth/register`, `GET /auth/me`
- `GET/POST /categories/`, `DELETE /categories/{id}` (admin)
- `GET/POST /complaints/` (multipart for attachment), `GET/DELETE /complaints/{id}`
- `POST /complaints/{id}/comments`, `PATCH /complaints/{id}/status` (admin)
- `GET /notifications/`, `POST /notifications/read-all`
- `GET /users/` (admin), `GET /admin/stats` (admin)
- `GET /uploads/{file}` — served static for complaint photos

## Using with the Flutter apps

The Flutter apps currently ship with a built-in mock `ApiClient`. To point them at this backend instead, replace `lib/core/api_client.dart` with a thin HTTP wrapper that sends `Authorization: Bearer <token>` to `http://localhost:8000` (or whatever host) and keeps the same method signatures. The route paths in this backend exactly match the routes the existing providers already call.
