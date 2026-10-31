import '../models/user.dart';
import 'api_client.dart';

class UserService {
  final ApiClient _client = ApiClient();

  Future<List<User>> searchUsers(String q) async {
    final response = await _client.get('/users/search', queryParams: {'q': q});
    final data = response is List ? response : (response['users'] ?? response['data'] ?? []);
    return (data as List).map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<User> getUserById(String id) async {
    final response = await _client.get('/users/$id');
    final userData = response['user'] ?? response;
    return User.fromJson(userData as Map<String, dynamic>);
  }
}
