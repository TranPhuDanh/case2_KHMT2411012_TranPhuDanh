import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _client = ApiClient();

  Future<User> login(String email, String password) async {
    final response = await _client.post(
      '/auth/login',
      body: {'email': email, 'password': password},
      withAuth: false,
    );
    final token = response['token'] ?? response['accessToken'] ?? '';
    final userData = response['user'] ?? response;
    final user = User.fromJson(userData as Map<String, dynamic>);
    await _saveSession(token, user);
    return user;
  }

  Future<User> register(String fullName, String email, String password) async {
    final response = await _client.post(
      '/auth/register',
      body: {'fullName': fullName, 'email': email, 'password': password},
      withAuth: false,
    );
    final token = response['token'] ?? response['accessToken'] ?? '';
    final userData = response['user'] ?? response;
    final user = User.fromJson(userData as Map<String, dynamic>);
    await _saveSession(token, user);
    return user;
  }

  Future<void> _saveSession(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
    await prefs.setString(AppConstants.userIdKey, user.id);
    await prefs.setString(AppConstants.userEmailKey, user.email);
    await prefs.setString(AppConstants.userFullNameKey, user.fullName);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userIdKey);
    await prefs.remove(AppConstants.userEmailKey);
    await prefs.remove(AppConstants.userFullNameKey);
  }

  Future<User> getCurrentUser() async {
    final response = await _client.get('/auth/me');
    return User.fromJson(response as Map<String, dynamic>);
  }

  Future<User> updateProfile(String fullName) async {
    final response = await _client.put('/auth/profile', body: {'fullName': fullName});
    final userData = response['user'] ?? response;
    final user = User.fromJson(userData as Map<String, dynamic>);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userFullNameKey, user.fullName);
    return user;
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _client.put('/auth/change-password', body: {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    });
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  Future<String?> getCachedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.userIdKey);
  }

  Future<String?> getCachedFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.userFullNameKey);
  }

  Future<String?> getCachedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.userEmailKey);
  }
}
