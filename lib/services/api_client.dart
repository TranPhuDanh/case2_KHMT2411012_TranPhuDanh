import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  static const String baseUrl = AppConstants.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  Future<Map<String, String>> _buildHeaders({bool withAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (withAuth) {
      final token = await _getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      String message = 'Lỗi không xác định';
      try {
        final body = jsonDecode(response.body);
        message = body['message'] ?? body['error'] ?? message;
      } catch (_) {}
      throw ApiException(response.statusCode, message);
    }
  }

  Future<dynamic> get(String path, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: queryParams,
    );
    final headers = await _buildHeaders();
    final response = await http.get(uri, headers: headers);
    return _handleResponse(response);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body, bool withAuth = true}) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _buildHeaders(withAuth: withAuth);
    final response = await http.post(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _buildHeaders();
    final response = await http.put(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _buildHeaders();
    final response = await http.patch(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _buildHeaders();
    final response = await http.delete(uri, headers: headers);
    return _handleResponse(response);
  }
}
