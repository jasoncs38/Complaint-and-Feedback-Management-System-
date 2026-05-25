import 'package:flutter/foundation.dart';

import '../core/api_client.dart';
import '../models/models.dart';

class AdminProvider extends ChangeNotifier {
  List<AdminComplaint> complaints = [];
  List<AdminCategory> categories = [];
  List<AdminUser> users = [];
  AdminStats? stats;
  bool loading = false;
  String? error;

  Future<void> loadStats() async {
    final j = await ApiClient.instance.get('/admin/stats');
    stats = AdminStats.fromJson(j);
    notifyListeners();
  }

  Future<void> loadComplaints({String? status, int? categoryId, String? search}) async {
    loading = true; error = null; notifyListeners();
    try {
      final q = <String, dynamic>{};
      if (status != null) q['status'] = status;
      if (categoryId != null) q['category_id'] = categoryId;
      if (search != null && search.isNotEmpty) q['search'] = search;
      final list = (await ApiClient.instance.get('/complaints/', query: q)) as List;
      complaints = list.map((e) => AdminComplaint.fromJson(e)).toList();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false; notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    final list = (await ApiClient.instance.get('/categories/')) as List;
    categories = list.map((e) => AdminCategory.fromJson(e)).toList();
    notifyListeners();
  }

  Future<void> createCategory(String name, String? description) async {
    await ApiClient.instance.post('/categories/', {'name': name, 'description': description});
    await loadCategories();
  }

  Future<void> deleteCategory(int id) async {
    await ApiClient.instance.delete('/categories/$id');
    await loadCategories();
  }

  Future<void> loadUsers() async {
    final list = (await ApiClient.instance.get('/users/')) as List;
    users = list.map((e) => AdminUser.fromJson(e)).toList();
    notifyListeners();
  }

  Future<AdminComplaint> updateStatus(int id, {required String status, String? response, String? priority}) async {
    final j = await ApiClient.instance.patch('/complaints/$id/status', {
      'status': status,
      if (response != null) 'admin_response': response,
      if (priority != null) 'priority': priority,
    });
    final c = AdminComplaint.fromJson(j);
    final i = complaints.indexWhere((x) => x.id == id);
    if (i >= 0) complaints[i] = c;
    notifyListeners();
    return c;
  }

  Future<Map<String, dynamic>> detail(int id) async {
    return await ApiClient.instance.get('/complaints/$id') as Map<String, dynamic>;
  }

  Future<void> addComment(int id, String message) async {
    await ApiClient.instance.post('/complaints/$id/comments', {'message': message});
  }
}
