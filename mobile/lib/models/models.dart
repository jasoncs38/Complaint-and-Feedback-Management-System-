class UserModel {
  final int id;
  final String fullName;
  final String email;
  final String? phone;
  final String role;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id: j['id'],
        fullName: j['full_name'],
        email: j['email'],
        phone: j['phone'],
        role: j['role'],
      );
}

class Category {
  final int id;
  final String name;
  final String? description;
  Category({required this.id, required this.name, this.description});
  factory Category.fromJson(Map<String, dynamic> j) =>
      Category(id: j['id'], name: j['name'], description: j['description']);
}

class Complaint {
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
  final Category? category;

  Complaint({
    required this.id,
    required this.title,
    required this.description,
    this.location,
    this.attachment,
    required this.status,
    required this.priority,
    this.adminResponse,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    this.userName,
    this.category,
  });

  factory Complaint.fromJson(Map<String, dynamic> j) => Complaint(
        id: j['id'],
        title: j['title'],
        description: j['description'],
        location: j['location'],
        attachment: j['attachment'],
        status: j['status'],
        priority: j['priority'],
        adminResponse: j['admin_response'],
        createdAt: DateTime.parse(j['created_at']),
        updatedAt: DateTime.parse(j['updated_at']),
        userId: j['user_id'],
        userName: j['user_name'],
        category: j['category'] != null ? Category.fromJson(j['category']) : null,
      );
}

class CommentModel {
  final int id;
  final String message;
  final int authorId;
  final String? authorName;
  final DateTime createdAt;
  CommentModel({
    required this.id,
    required this.message,
    required this.authorId,
    this.authorName,
    required this.createdAt,
  });
  factory CommentModel.fromJson(Map<String, dynamic> j) => CommentModel(
        id: j['id'],
        message: j['message'],
        authorId: j['author_id'],
        authorName: j['author_name'],
        createdAt: DateTime.parse(j['created_at']),
      );
}

class NotificationModel {
  final int id;
  final String title;
  final String? body;
  final bool isRead;
  final int? complaintId;
  final DateTime createdAt;
  NotificationModel({
    required this.id,
    required this.title,
    this.body,
    required this.isRead,
    this.complaintId,
    required this.createdAt,
  });
  factory NotificationModel.fromJson(Map<String, dynamic> j) => NotificationModel(
        id: j['id'],
        title: j['title'],
        body: j['body'],
        isRead: j['is_read'] ?? false,
        complaintId: j['complaint_id'],
        createdAt: DateTime.parse(j['created_at']),
      );
}
