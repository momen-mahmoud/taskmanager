/// Centralized route paths and names used by GoRouter and navigation calls.
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';

  static const String projectDetails = '/project/:id';
  static String projectDetailsPath(int id) => '/project/$id';
}
