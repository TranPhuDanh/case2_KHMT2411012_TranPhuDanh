import 'api_client.dart';

class StatisticsService {
  final ApiClient _client = ApiClient();

  Future<Map<String, dynamic>> getTaskStats() async {
    final response = await _client.get('/statistics/tasks');
    return response is Map<String, dynamic> ? response : {};
  }

  Future<Map<String, dynamic>> getAssignmentStats() async {
    final response = await _client.get('/statistics/assignments');
    return response is Map<String, dynamic> ? response : {};
  }

  Future<Map<String, dynamic>> getDeadlineStats() async {
    final response = await _client.get('/statistics/deadlines');
    return response is Map<String, dynamic> ? response : {};
  }
}
