import '../models/task_share.dart';
import '../models/user.dart';
import 'api_client.dart';

class TaskShareService {
  final ApiClient _client = ApiClient();

  Future<List<TaskShare>> getShares(String taskId) async {
    final response = await _client.get('/tasks/$taskId/shares');
    dynamic listData;
    if (response is List) {
      listData = response;
    } else if (response is Map) {
      if (response['shares'] is List) {
        listData = response['shares'];
      } else if (response['data'] is Map && response['data']['shares'] is List) {
        listData = response['data']['shares'];
      } else if (response['data'] is List) {
        listData = response['data'];
      } else {
        listData = [];
      }
    } else {
      listData = [];
    }
    return (listData as List).map((e) => TaskShare.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TaskShare> addShare(String taskId, String userId, String permission) async {
    final response = await _client.post('/tasks/$taskId/shares', body: {
      'userId': userId,
      'permission': permission,
    });
    Map<String, dynamic> shareData;
    if (response is Map<String, dynamic>) {
      if (response['share'] is Map<String, dynamic>) {
        shareData = response['share'] as Map<String, dynamic>;
      } else if (response['data'] is Map<String, dynamic> && response['data']['share'] is Map<String, dynamic>) {
        shareData = response['data']['share'] as Map<String, dynamic>;
      } else if (response['data'] is Map<String, dynamic>) {
        shareData = response['data'] as Map<String, dynamic>;
      } else {
        shareData = response;
      }
    } else {
      throw ApiException(500, 'Invalid share response format');
    }
    return TaskShare.fromJson(shareData);
  }

  Future<TaskShare> updateShare(String taskId, String shareId, String permission) async {
    final response = await _client.patch('/tasks/$taskId/shares/$shareId', body: {
      'permission': permission,
    });
    Map<String, dynamic> shareData;
    if (response is Map<String, dynamic>) {
      if (response['share'] is Map<String, dynamic>) {
        shareData = response['share'] as Map<String, dynamic>;
      } else if (response['data'] is Map<String, dynamic> && response['data']['share'] is Map<String, dynamic>) {
        shareData = response['data']['share'] as Map<String, dynamic>;
      } else if (response['data'] is Map<String, dynamic>) {
        shareData = response['data'] as Map<String, dynamic>;
      } else {
        shareData = response;
      }
    } else {
      throw ApiException(500, 'Invalid share response format');
    }
    return TaskShare.fromJson(shareData);
  }

  Future<void> deleteShare(String taskId, String shareId) async {
    await _client.delete('/tasks/$taskId/shares/$shareId');
  }

  Future<List<User>> getAssignees(String taskId) async {
    final response = await _client.get('/tasks/$taskId/assignees');
    dynamic listData;
    if (response is List) {
      listData = response;
    } else if (response is Map) {
      if (response['assignees'] is List) {
        listData = response['assignees'];
      } else if (response['data'] is Map && response['data']['assignees'] is List) {
        listData = response['data']['assignees'];
      } else if (response['data'] is List) {
        listData = response['data'];
      } else {
        listData = [];
      }
    } else {
      listData = [];
    }
    return (listData as List).map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> addAssignees(String taskId, List<String> userIds, {String? primaryAssigneeId}) async {
    await _client.post('/tasks/$taskId/assignees', body: {
      'userIds': userIds,
      if (primaryAssigneeId != null) 'primaryAssigneeId': primaryAssigneeId,
    });
  }

  Future<void> updateAssignee(String taskId, String userId, {required bool isPrimary}) async {
    await _client.patch('/tasks/$taskId/assignees/$userId', body: {
      'isPrimary': isPrimary,
    });
  }

  Future<void> removeAssignee(String taskId, String userId) async {
    await _client.delete('/tasks/$taskId/assignees/$userId');
  }
}
