/// App-wide constants: API configuration and local storage keys.
class AppConstants {
  AppConstants._();

  // ---- API ----
  static const String baseUrl = 'https://dummyjson.com';
  static const String postsEndpoint = '/posts';
  static const String todosEndpoint = '/todos';
  static const String todosAddEndpoint = '/todos/add';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // ---- Secure storage keys ----
  static const String tokenKey = 'auth_jwt_token';

  // ---- Hive box names ----
  static const String usersBox = 'users_box'; // registered mock users (by email)
  static const String cacheBox = 'cache_box'; // cached projects/tasks JSON
  static const String settingsBox = 'settings_box'; // theme mode, etc.

  // ---- Settings keys ----
  static const String themeModeKey = 'theme_mode';

  // ---- Cache keys ----
  static const String projectsCacheKey = 'cached_projects';
  static String tasksCacheKey(int projectId) => 'cached_tasks_$projectId';
  static const String currentUserKey = 'current_user';
}
