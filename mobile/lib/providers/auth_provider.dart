import 'package:flutter/foundation.dart';

import '../core/api_client.dart';
import '../models/models.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? user;
  bool loading = false;

  bool get isAuthenticated => user != null;

  Future<void> bootstrap() async {
    await ApiClient.instance.loadToken();
    if (ApiClient.instance.token != null) {
      try {
        final j = await ApiClient.instance.get('/auth/me');
        user = UserModel.fromJson(j);
      } catch (_) {
        await logout();
      }
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    loading = true;
    notifyListeners();
    try {
      final j = await ApiClient.instance.post('/auth/login', {
        'email': email,
        'password': password,
      });
      await ApiClient.instance.setToken(j['access_token']);
      user = UserModel.fromJson(j['user']);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    loading = true;
    notifyListeners();
    try {
      final j = await ApiClient.instance.post('/auth/register', {
        'full_name': fullName,
        'email': email,
        'password': password,
        'phone': phone,
      });
      await ApiClient.instance.setToken(j['access_token']);
      user = UserModel.fromJson(j['user']);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await ApiClient.instance.setToken(null);
    user = null;
    notifyListeners();
  }
}
