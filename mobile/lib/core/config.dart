import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  /// Base URL of the FastAPI backend. Loaded from the bundled `.env` file.
  /// Falls back to the Android emulator host if missing.
  static String get apiBaseUrl {
    final v = dotenv.maybeGet('API_BASE_URL');
    if (v == null || v.isEmpty) return 'http://10.0.2.2:8000';
    return v.endsWith('/') ? v.substring(0, v.length - 1) : v;
  }
}
