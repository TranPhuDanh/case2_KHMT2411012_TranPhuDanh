class NotificationModel {
  final String id;
  final String userId;
  final String? taskId;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    this.taskId,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    String parseId(dynamic raw) {
      if (raw == null) return '';
      if (raw is Map) return raw['_id']?.toString() ?? raw['id']?.toString() ?? '';
      return raw.toString();
    }

    String? parseTaskId(dynamic raw) {
      if (raw == null) return null;
      if (raw is Map) return raw['_id']?.toString() ?? raw['id']?.toString();
      return raw.toString();
    }

    return NotificationModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: parseId(json['user'] ?? json['userId']),
      taskId: parseTaskId(json['task'] ?? json['taskId']),
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      isRead: json['isRead'] ?? json['is_read'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      userId: userId,
      taskId: taskId,
      type: type,
      title: title,
      message: message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
