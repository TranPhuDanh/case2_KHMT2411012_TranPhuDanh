import '../models/user.dart';
import 'api_client.dart';

class UserService {
  final ApiClient _client = ApiClient();

  Future<List<User>> searchUsers(String q) async {
    final response = await _client.get('/users/search', queryParams: q.isNotEmpty ? {'q': q} : null);
    dynamic listData;
    if (response is List) {
      listData = response;
    } else if (response is Map) {
      if (response['users'] is List) {
        listData = response['users'];
      } else if (response['data'] is Map && response['data']['users'] is List) {
        listData = response['data']['users'];
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

  Future<User> getUserById(String id) async {
    final response = await _client.get('/users/$id');
    Map<String, dynamic> userData;
    if (response is Map<String, dynamic>) {
      if (response['user'] is Map<String, dynamic>) {
        userData = response['user'] as Map<String, dynamic>;
      } else if (response['data'] is Map<String, dynamic> && response['data']['user'] is Map<String, dynamic>) {
        userData = response['data']['user'] as Map<String, dynamic>;
      } else if (response['data'] is Map<String, dynamic>) {
        userData = response['data'] as Map<String, dynamic>;
      } else {
        userData = response;
      }
    } else {
      throw ApiException(500, 'Invalid user response format');
    }
    return User.fromJson(userData);
  }
}
