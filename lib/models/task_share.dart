import 'user.dart';

class TaskShare {
  final String id;
  final String taskId;
  final String userId;
  final String permission; // viewer, editor
  final String sharedBy;
  final DateTime createdAt;
  final User? user; // populated

  TaskShare({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.permission,
    required this.sharedBy,
    required this.createdAt,
    this.user,
  });

  factory TaskShare.fromJson(Map<String, dynamic> json) {
    String parseId(dynamic raw) {
      if (raw == null) return '';
      if (raw is Map) return raw['_id']?.toString() ?? raw['id']?.toString() ?? '';
      return raw.toString();
    }

    return TaskShare(
      id: json['_id'] ?? json['id'] ?? '',
      taskId: parseId(json['task'] ?? json['taskId']),
      userId: parseId(json['user'] ?? json['userId']),
      permission: json['permission'] ?? 'viewer',
      sharedBy: parseId(json['sharedBy']),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      user: json['user'] is Map
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}
