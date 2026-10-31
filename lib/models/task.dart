import 'user.dart';

class Task {
  final String id;
  final String title;
  final String? description;
  final String createdBy;
  final List<String> assigneeIds;
  final String? primaryAssigneeId;
  final DateTime? startDate;
  final DateTime? dueDate;
  final String priority; // low, medium, high
  final String status; // todo, in_progress, completed
  final DateTime createdAt;
  final DateTime updatedAt;

  // optional populated fields
  final User? createdByUser;
  final List<User>? assignees;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.createdBy,
    required this.assigneeIds,
    this.primaryAssigneeId,
    this.startDate,
    this.dueDate,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.createdByUser,
    this.assignees,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    List<String> parseAssigneeIds(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) {
        return raw.map((e) {
          if (e is Map) return e['_id']?.toString() ?? e['id']?.toString() ?? '';
          return e.toString();
        }).where((s) => s.isNotEmpty).toList();
      }
      return [];
    }

    String? parsePrimaryAssignee(dynamic raw) {
      if (raw == null) return null;
      if (raw is Map) return raw['_id']?.toString() ?? raw['id']?.toString();
      return raw.toString();
    }

    List<User>? parseAssignees(dynamic raw) {
      if (raw == null) return null;
      if (raw is List) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map((e) => User.fromJson(e))
            .toList();
      }
      return null;
    }

    String parseCreatedBy(dynamic raw) {
      if (raw == null) return '';
      if (raw is Map) return raw['_id']?.toString() ?? raw['id']?.toString() ?? '';
      return raw.toString();
    }

    return Task(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      createdBy: parseCreatedBy(json['createdBy']),
      assigneeIds: parseAssigneeIds(json['assigneeIds'] ?? json['assignees']),
      primaryAssigneeId: parsePrimaryAssignee(json['primaryAssigneeId'] ?? json['primaryAssignee']),
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'])
          : null,
      dueDate:
          json['dueDate'] != null ? DateTime.tryParse(json['dueDate']) : null,
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'todo',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      createdByUser: json['createdBy'] is Map
          ? User.fromJson(json['createdBy'] as Map<String, dynamic>)
          : null,
      assignees: parseAssignees(json['assigneeIds'] ?? json['assignees']),
    );
  }

  Task copyWith({
    String? title,
    String? description,
    String? priority,
    String? status,
    DateTime? startDate,
    DateTime? dueDate,
    List<String>? assigneeIds,
    String? primaryAssigneeId,
    List<User>? assignees,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdBy: createdBy,
      assigneeIds: assigneeIds ?? this.assigneeIds,
      primaryAssigneeId: primaryAssigneeId ?? this.primaryAssigneeId,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      createdByUser: createdByUser,
      assignees: assignees ?? this.assignees,
    );
  }
}
