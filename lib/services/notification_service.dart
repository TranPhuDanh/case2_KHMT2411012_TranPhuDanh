import '../models/notification_model.dart';
import 'api_client.dart';

class NotificationService {
  final ApiClient _client = ApiClient();

  Future<List<NotificationModel>> getNotifications() async {
    final response = await _client.get('/notifications');
    final data = response is List
        ? response
        : (response['notifications'] ?? response['data'] ?? []);
    return (data as List)
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> getUnreadCount() async {
    final response = await _client.get('/notifications/unread-count');
    return response['count'] ?? response['unreadCount'] ?? 0;
  }

  Future<void> markAsRead(String id) async {
    await _client.patch('/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _client.patch('/notifications/read-all');
  }
}
