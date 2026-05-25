class AdminUser {
  final int id;
  final String fullName;
  final String email;
  final String role;
  final bool isActive;
  AdminUser({required this.id, required this.fullName, required this.email, required this.role, required this.isActive});
  factory AdminUser.fromJson(Map<String, dynamic> j) => AdminUser(
        id: j['id'], fullName: j['full_name'], email: j['email'],
        role: j['role'], isActive: j['is_active'] ?? true);
}

class AdminCategory {
  final int id;
  final String name;
  final String? description;
  AdminCategory({required this.id, required this.name, this.description});
  factory AdminCategory.fromJson(Map<String, dynamic> j) =>
      AdminCategory(id: j['id'], name: j['name'], description: j['description']);
}

class AdminComplaint {
  final int id;
  final String title;
  final String description;
  final String? location;
  final String? attachment;
  final String status;
  final String priority;
  final String? adminResponse;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int userId;
  final String? userName;
  final AdminCategory? category;

  AdminComplaint({
    required this.id, required this.title, required this.description,
    this.location, this.attachment, required this.status, required this.priority,
    this.adminResponse, required this.createdAt, required this.updatedAt,
    required this.userId, this.userName, this.category,
  });

  factory AdminComplaint.fromJson(Map<String, dynamic> j) => AdminComplaint(
        id: j['id'], title: j['title'], description: j['description'],
        location: j['location'], attachment: j['attachment'],
        status: j['status'], priority: j['priority'],
        adminResponse: j['admin_response'],
        createdAt: DateTime.parse(j['created_at']),
        updatedAt: DateTime.parse(j['updated_at']),
        userId: j['user_id'], userName: j['user_name'],
        category: j['category'] != null ? AdminCategory.fromJson(j['category']) : null,
      );
}

class AdminStats {
  final int total, pending, inProgress, resolved, rejected, users;
  final Map<String, dynamic> byCategory;
  AdminStats({
    required this.total, required this.pending, required this.inProgress,
    required this.resolved, required this.rejected, required this.users,
    required this.byCategory,
  });
  factory AdminStats.fromJson(Map<String, dynamic> j) => AdminStats(
        total: j['total'] ?? 0,
        pending: j['pending'] ?? 0,
        inProgress: j['in_progress'] ?? 0,
        resolved: j['resolved'] ?? 0,
        rejected: j['rejected'] ?? 0,
        users: j['users'] ?? 0,
        byCategory: Map<String, dynamic>.from(j['by_category'] ?? {}),
      );
}
