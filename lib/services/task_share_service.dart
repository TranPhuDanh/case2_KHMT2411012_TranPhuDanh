import '../models/task_share.dart';
import '../models/user.dart';
import 'api_client.dart';

class TaskShareService {
  final ApiClient _client = ApiClient();

  Future<List<TaskShare>> getShares(String taskId) async {
    final response = await _client.get('/tasks/$taskId/shares');
    final data = response is List ? response : (response['shares'] ?? response['data'] ?? []);
    return (data as List).map((e) => TaskShare.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TaskShare> addShare(String taskId, String userId, String permission) async {
    final response = await _client.post('/tasks/$taskId/shares', body: {
      'userId': userId,
      'permission': permission,
    });
    final shareData = response['share'] ?? response;
    return TaskShare.fromJson(shareData as Map<String, dynamic>);
  }

  Future<TaskShare> updateShare(String taskId, String shareId, String permission) async {
    final response = await _client.put('/tasks/$taskId/shares/$shareId', body: {
      'permission': permission,
    });
    final shareData = response['share'] ?? response;
    return TaskShare.fromJson(shareData as Map<String, dynamic>);
  }

  Future<void> deleteShare(String taskId, String shareId) async {
    await _client.delete('/tasks/$taskId/shares/$shareId');
  }

  Future<List<User>> getAssignees(String taskId) async {
    final response = await _client.get('/tasks/$taskId/assignees');
    final data = response is List ? response : (response['assignees'] ?? response['data'] ?? []);
    return (data as List).map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> addAssignees(String taskId, List<String> userIds, {String? primaryAssigneeId}) async {
    await _client.post('/tasks/$taskId/assignees', body: {
      'userIds': userIds,
      if (primaryAssigneeId != null) 'primaryAssigneeId': primaryAssigneeId,
    });
  }

  Future<void> updateAssignee(String taskId, String userId, {required bool isPrimary}) async {
    await _client.put('/tasks/$taskId/assignees/$userId', body: {
      'isPrimary': isPrimary,
    });
  }

  Future<void> removeAssignee(String taskId, String userId) async {
    await _client.delete('/tasks/$taskId/assignees/$userId');
  }
}
