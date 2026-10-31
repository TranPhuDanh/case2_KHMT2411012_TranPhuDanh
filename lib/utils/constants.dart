class AppConstants {
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  // For web/desktop testing use: 'http://localhost:3000/api'

  // Task priorities
  static const String priorityLow = 'low';
  static const String priorityMedium = 'medium';
  static const String priorityHigh = 'high';

  // Task statuses
  static const String statusTodo = 'todo';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';

  // Task share permissions
  static const String permissionViewer = 'viewer';
  static const String permissionEditor = 'editor';

  // SharedPreferences keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
  static const String userFullNameKey = 'user_full_name';
}
