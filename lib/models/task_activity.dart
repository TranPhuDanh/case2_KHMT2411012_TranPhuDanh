import 'user.dart';

class TaskActivity {
  final String id;
  final String taskId;
  final String userId;
  final String action;
  final Map<String, dynamic>? details;
  final DateTime createdAt;
  final User? user; // populated

  TaskActivity({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.action,
    this.details,
    required this.createdAt,
    this.user,
  });

  factory TaskActivity.fromJson(Map<String, dynamic> json) {
    String parseId(dynamic raw) {
      if (raw == null) return '';
      if (raw is Map) return raw['_id']?.toString() ?? raw['id']?.toString() ?? '';
      return raw.toString();
    }

    return TaskActivity(
      id: json['_id'] ?? json['id'] ?? '',
      taskId: parseId(json['task'] ?? json['taskId']),
      userId: parseId(json['user'] ?? json['userId']),
      action: json['action'] ?? '',
      details: json['details'] is Map
          ? Map<String, dynamic>.from(json['details'])
          : null,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      user: json['user'] is Map
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}
