import '../models/task.dart';
import '../models/task_activity.dart';
import 'api_client.dart';

class TaskService {
  final ApiClient _client = ApiClient();

  Future<List<Task>> getTasks({
    String? scope,
    String? status,
    String? priority,
    String? q,
    String? sortBy,
    String? order,
  }) async {
    final params = <String, String>{};
    if (scope != null) params['scope'] = scope;
    if (status != null) params['status'] = status;
    if (priority != null) params['priority'] = priority;
    if (q != null && q.isNotEmpty) params['q'] = q;
    if (sortBy != null) params['sortBy'] = sortBy;
    if (order != null) params['order'] = order;

    final response = await _client.get('/tasks', queryParams: params.isNotEmpty ? params : null);
    dynamic listData;
    if (response is List) {
      listData = response;
    } else if (response is Map) {
      if (response['tasks'] is List) {
        listData = response['tasks'];
      } else if (response['data'] is Map && response['data']['tasks'] is List) {
        listData = response['data']['tasks'];
      } else if (response['data'] is List) {
        listData = response['data'];
      } else {
        listData = [];
      }
    } else {
      listData = [];
    }

    return (listData as List).map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Task> createTask({
    required String title,
    String? description,
    DateTime? startDate,
    DateTime? dueDate,
    String priority = 'medium',
    String status = 'todo',
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'priority': priority,
      'status': status,
    };
    if (description != null && description.isNotEmpty) body['description'] = description;
    if (startDate != null) body['startDate'] = startDate.toIso8601String();
    if (dueDate != null) body['dueDate'] = dueDate.toIso8601String();

    final response = await _client.post('/tasks', body: body);
    Map<String, dynamic> taskData;
    if (response is Map<String, dynamic>) {
      if (response['task'] is Map<String, dynamic>) {
        taskData = response['task'] as Map<String, dynamic>;
      } else if (response['data'] is Map<String, dynamic> && response['data']['task'] is Map<String, dynamic>) {
        taskData = response['data']['task'] as Map<String, dynamic>;
      } else if (response['data'] is Map<String, dynamic>) {
        taskData = response['data'] as Map<String, dynamic>;
      } else {
        taskData = response;
      }
    } else {
      throw ApiException(500, 'Invalid task response format');
    }
    return Task.fromJson(taskData);
  }

  Future<Task> getTaskById(String id) async {
    final response = await _client.get('/tasks/$id');
    Map<String, dynamic> taskData;
    String? permission;
    if (response is Map<String, dynamic>) {
      permission = response['permission']?.toString() ?? response['data']?['permission']?.toString();
      if (response['task'] is Map<String, dynamic>) {
        taskData = response['task'] as Map<String, dynamic>;
      } else if (response['data'] is Map<String, dynamic> && response['data']['task'] is Map<String, dynamic>) {
        taskData = response['data']['task'] as Map<String, dynamic>;
      } else if (response['data'] is Map<String, dynamic>) {
        taskData = response['data'] as Map<String, dynamic>;
      } else {
        taskData = response;
      }
    } else {
      throw ApiException(500, 'Invalid task response format');
    }
    if (permission != null && !taskData.containsKey('permission')) {
      taskData = Map<String, dynamic>.from(taskData);
      taskData['permission'] = permission;
    }
    return Task.fromJson(taskData);
  }

  Future<Task> updateTask(String id, Map<String, dynamic> data) async {
    final response = await _client.put('/tasks/$id', body: data);
    Map<String, dynamic> taskData;
    if (response is Map<String, dynamic>) {
      if (response['task'] is Map<String, dynamic>) {
        taskData = response['task'] as Map<String, dynamic>;
      } else if (response['data'] is Map<String, dynamic> && response['data']['task'] is Map<String, dynamic>) {
        taskData = response['data']['task'] as Map<String, dynamic>;
      } else if (response['data'] is Map<String, dynamic>) {
        taskData = response['data'] as Map<String, dynamic>;
      } else {
        taskData = response;
      }
    } else {
      throw ApiException(500, 'Invalid task response format');
    }
    return Task.fromJson(taskData);
  }

  Future<void> deleteTask(String id) async {
    await _client.delete('/tasks/$id');
  }

  Future<Task> updateStatus(String id, String status) async {
    final response = await _client.patch('/tasks/$id/status', body: {'status': status});
    Map<String, dynamic> taskData;
    if (response is Map<String, dynamic>) {
      if (response['task'] is Map<String, dynamic>) {
        taskData = response['task'] as Map<String, dynamic>;
      } else if (response['data'] is Map<String, dynamic> && response['data']['task'] is Map<String, dynamic>) {
        taskData = response['data']['task'] as Map<String, dynamic>;
      } else if (response['data'] is Map<String, dynamic>) {
        taskData = response['data'] as Map<String, dynamic>;
      } else {
        taskData = response;
      }
    } else {
      throw ApiException(500, 'Invalid task response format');
    }
    return Task.fromJson(taskData);
  }

  Future<List<TaskActivity>> getActivities(String id) async {
    try {
      final response = await _client.get('/tasks/$id/activities');
      dynamic listData;
      if (response is List) {
        listData = response;
      } else if (response is Map) {
        if (response['activities'] is List) {
          listData = response['activities'];
        } else if (response['data'] is Map && response['data']['activities'] is List) {
          listData = response['data']['activities'];
        } else if (response['data'] is List) {
          listData = response['data'];
        } else {
          listData = [];
        }
      } else {
        listData = [];
      }
      return (listData as List)
          .map((e) => TaskActivity.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<dynamic> getEmailLogs(String id) async {
    try {
      final response = await _client.get('/tasks/$id/email-logs');
      return response;
    } catch (_) {
      return [];
    }
  }
}
