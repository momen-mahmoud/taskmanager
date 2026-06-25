import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/projects/domain/entities/project.dart';
import '../../features/projects/presentation/screens/home_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/tasks/presentation/screens/project_details_screen.dart';
import '../widgets/splash_screen.dart';
import 'app_routes.dart';

/// Builds the app's [GoRouter] with an auth-aware redirect guard.
///
/// The redirect reads [authProvider] and refreshes whenever auth state changes
/// (via the [ValueNotifier] listenable), so login/logout navigate automatically.
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final loggedIn = auth.valueOrNull != null;
      final loc = state.matchedLocation;
      final onSplash = loc == '/';
      final onAuthPages =
          loc == AppRoutes.login || loc == AppRoutes.register;

      // Stay on the splash while the initial session check is in flight.
      if (onSplash && auth.isLoading) return null;

      if (!loggedIn) {
        return onAuthPages ? null : AppRoutes.login;
      }
      // Logged in: keep users out of the splash/auth pages.
      if (onSplash || onAuthPages) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => _fadePage(state, const LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (context, state) =>
            _fadePage(state, const RegisterScreen()),
      ),
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) => _fadePage(state, const HomeScreen()),
      ),
      GoRoute(
        path: AppRoutes.profile,
        pageBuilder: (context, state) => _fadePage(state, const ProfileScreen()),
      ),
      GoRoute(
        path: AppRoutes.projectDetails,
        pageBuilder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          final project = state.extra is Project ? state.extra as Project : null;
          return _fadePage(
            state,
            ProjectDetailsScreen(projectId: id, project: project),
          );
        },
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Route not found: ${state.uri}'))),
  );
});

/// Shared springy fade + scale page transition (bonus: page transitions).
CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 360),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      final pop = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
      return FadeTransition(
        opacity: fade,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1.0).animate(pop),
          child: child,
        ),
      );
    },
  );
}
