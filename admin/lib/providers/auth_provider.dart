import 'package:flutter/foundation.dart';

import '../core/api_client.dart';
import '../models/models.dart';

class AuthProvider extends ChangeNotifier {
  AdminUser? user;
  bool loading = false;
  bool get isAuthenticated => user != null && (user!.role == 'admin' || user!.role == 'staff');

  Future<void> bootstrap() async {
    await ApiClient.instance.loadToken();
    if (ApiClient.instance.token != null) {
      try {
        final j = await ApiClient.instance.get('/auth/me');
        user = AdminUser.fromJson(j);
      } catch (_) { await logout(); }
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    loading = true; notifyListeners();
    try {
      final j = await ApiClient.instance.post('/auth/login', {'email': email, 'password': password});
      await ApiClient.instance.setToken(j['access_token']);
      user = AdminUser.fromJson(j['user']);
      if (!isAuthenticated) {
        await logout();
        throw Exception('Not an admin account');
      }
    } finally {
      loading = false; notifyListeners();
    }
  }

  Future<void> logout() async {
    await ApiClient.instance.setToken(null);
    user = null;
    notifyListeners();
  }
}
