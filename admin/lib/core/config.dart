import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  /// Base URL of the FastAPI backend. Loaded from the bundled `.env` file.
  static String get apiBaseUrl {
    final v = dotenv.maybeGet('API_BASE_URL');
    if (v == null || v.isEmpty) return 'http://127.0.0.1:8000';
    return v.endsWith('/') ? v.substring(0, v.length - 1) : v;
  }
}
