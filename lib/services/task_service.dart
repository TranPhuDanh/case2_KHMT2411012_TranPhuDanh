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
    final data = response is List ? response : (response['tasks'] ?? response['data'] ?? []);
    return (data as List).map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
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
    final taskData = response['task'] ?? response;
    return Task.fromJson(taskData as Map<String, dynamic>);
  }

  Future<Task> getTaskById(String id) async {
    final response = await _client.get('/tasks/$id');
    final taskData = response['task'] ?? response;
    return Task.fromJson(taskData as Map<String, dynamic>);
  }

  Future<Task> updateTask(String id, Map<String, dynamic> data) async {
    final response = await _client.put('/tasks/$id', body: data);
    final taskData = response['task'] ?? response;
    return Task.fromJson(taskData as Map<String, dynamic>);
  }

  Future<void> deleteTask(String id) async {
    await _client.delete('/tasks/$id');
  }

  Future<Task> updateStatus(String id, String status) async {
    final response = await _client.patch('/tasks/$id/status', body: {'status': status});
    final taskData = response['task'] ?? response;
    return Task.fromJson(taskData as Map<String, dynamic>);
  }

  Future<List<TaskActivity>> getActivities(String id) async {
    final response = await _client.get('/tasks/$id/activities');
    final data = response is List ? response : (response['activities'] ?? response['data'] ?? []);
    return (data as List)
        .map((e) => TaskActivity.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<dynamic> getEmailLogs(String id) async {
    final response = await _client.get('/tasks/$id/email-logs');
    return response;
  }
}
