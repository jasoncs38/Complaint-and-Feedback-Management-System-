# Mobile App — Complaint & Feedback (User)

Flutter end-user app: register/login, file complaints (with attachment), track status, get notifications, comment.

## Run
```bash
flutter create . --project-name complaint_mobile --platforms=android,ios
flutter pub get
flutter run
```
The first command scaffolds platform folders (Android/iOS). Existing `lib/` and `pubspec.yaml` are preserved.

Set backend URL in `lib/core/config.dart`:
- Android emulator -> `http://10.0.2.2:8000`
- iOS simulator -> `http://localhost:8000`
- Physical device -> `http://<your-LAN-ip>:8000`
