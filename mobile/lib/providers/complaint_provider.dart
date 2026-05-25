import 'dart:io';
import 'package:flutter/foundation.dart' hide Category;

import '../core/api_client.dart';
import '../models/models.dart';

class ComplaintProvider extends ChangeNotifier {
  List<Complaint> items = [];
  List<Category> categories = [];
  bool loading = false;
  String? error;

  Future<void> loadCategories() async {
    final list = (await ApiClient.instance.get('/categories/')) as List;
    categories = list.map((e) => Category.fromJson(e)).toList();
    notifyListeners();
  }

  Future<void> refresh({String? status, int? categoryId, String? search}) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final q = <String, dynamic>{};
      if (status != null) q['status'] = status;
      if (categoryId != null) q['category_id'] = categoryId;
      if (search != null && search.isNotEmpty) q['search'] = search;
      final list = (await ApiClient.instance.get('/complaints/', query: q)) as List;
      items = list.map((e) => Complaint.fromJson(e)).toList();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<Complaint> submit({
    required String title,
    required String description,
    String? location,
    int? categoryId,
    String priority = 'medium',
    File? attachment,
  }) async {
    final fields = <String, String>{
      'title': title,
      'description': description,
      'priority': priority,
    };
    if (location != null && location.isNotEmpty) fields['location'] = location;
    if (categoryId != null) fields['category_id'] = categoryId.toString();
    final j = await ApiClient.instance.postMultipart('/complaints/', fields, file: attachment);
    final c = Complaint.fromJson(j);
    items.insert(0, c);
    notifyListeners();
    return c;
  }

  Future<Map<String, dynamic>> detail(int id) async {
    return await ApiClient.instance.get('/complaints/$id') as Map<String, dynamic>;
  }

  Future<CommentModel> addComment(int id, String message) async {
    final j = await ApiClient.instance.post('/complaints/$id/comments', {'message': message});
    return CommentModel.fromJson(j);
  }

  Future<void> delete(int id) async {
    await ApiClient.instance.delete('/complaints/$id');
    items.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
