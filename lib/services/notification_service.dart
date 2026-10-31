import '../models/notification_model.dart';
import 'api_client.dart';

class NotificationService {
  final ApiClient _client = ApiClient();

  Future<List<NotificationModel>> getNotifications() async {
    final response = await _client.get('/notifications');
    List rawList = [];
    if (response is List) {
      rawList = response;
    } else if (response is Map<String, dynamic>) {
      if (response['notifications'] is List) {
        rawList = response['notifications'];
      } else if (response['data'] is List) {
        rawList = response['data'];
      } else if (response['data'] is Map && response['data']['notifications'] is List) {
        rawList = response['data']['notifications'];
      }
    }
    return rawList
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> getUnreadCount() async {
    final response = await _client.get('/notifications/unread-count');
    if (response is Map<String, dynamic>) {
      if (response['count'] != null) return (response['count'] as num).toInt();
      if (response['unreadCount'] != null) return (response['unreadCount'] as num).toInt();
      if (response['data'] is Map && response['data']['count'] != null) {
        return (response['data']['count'] as num).toInt();
      }
    }
    return 0;
  }

  Future<void> markAsRead(String id) async {
    await _client.patch('/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _client.patch('/notifications/read-all');
  }
}
