# Complaint & Feedback Management System — Prototype

Demo/prototype implementation of **Problem 5** (Complaint & Feedback Management System) built with Flutter. Both apps run **fully offline** with seeded in-memory data — no backend or network required.

## Apps

- `mobile/` — Flutter user app (submit complaints, comment, track status, notifications)
- `admin/` — Flutter admin app (dashboard, triage, status updates, categories, users)

## Demo credentials

Mobile app:
- `user@example.com` / `user123`
- `admin@example.com` / `admin123`

Admin app:
- `admin@example.com` / `admin123`
- `daniel@example.com` / `staff123` (staff role)

Anyone can register a new user inside the mobile app; the new account lives only in memory for the current run.

## Seeded data

- 6 categories (Infrastructure, Sanitation, Academic, IT Services, Security, Other)
- Several complaints across statuses (`pending`, `in_progress`, `resolved`, `rejected`) for the admin dashboard
- Notifications

Each app is independent — data is **not shared** between the mobile and admin builds; each holds its own simulated store.

## Run

Both apps share the same commands:

```bash
cd mobile   # or: cd admin
flutter pub get
flutter run
```

Requires Flutter ≥ 3.19, Dart ≥ 3.3.

## Features implemented

User (mobile):
- Login / register / logout
- Submit complaint (title, description, category, location, priority, optional photo attachment)
- View my complaints, filter by status
- Complaint detail, comment thread, delete
- Notifications

Admin:
- Login (admin / staff)
- Dashboard with totals, status breakdown, by-category pie chart
- Complaint list with search & filters
- Update status, priority and admin response
- Comment on complaints
- Manage categories
- View users

## Notes

This is a UI/UX prototype. The original FastAPI backend has been removed; both apps now use a mock `ApiClient` (see `lib/core/api_client.dart` in each app) that mimics the previous REST surface so the rest of the code (providers, screens, models) is unchanged from a real client/server build.
