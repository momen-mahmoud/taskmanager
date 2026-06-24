import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/usecase/usecase.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/register.dart';

// ---- use-case providers ----
final loginUseCaseProvider =
    Provider((ref) => Login(ref.read(authRepositoryProvider)));
final registerUseCaseProvider =
    Provider((ref) => Register(ref.read(authRepositoryProvider)));
final logoutUseCaseProvider =
    Provider((ref) => Logout(ref.read(authRepositoryProvider)));
final getCurrentUserUseCaseProvider =
    Provider((ref) => GetCurrentUser(ref.read(authRepositoryProvider)));

/// Holds the authenticated [User] (or `null`). On build it restores any
/// existing session, which drives auto-navigation to Home on app launch.
///
/// The `AsyncValue` state also feeds the GoRouter redirect guard.
class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final result =
        await ref.read(getCurrentUserUseCaseProvider).call(const NoParams());
    return result.fold((_) => null, (user) => user);
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncValue.loading();
    final result = await ref
        .read(loginUseCaseProvider)
        .call(LoginParams(email: email, password: password));
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (user) => AsyncValue.data(user),
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    final result = await ref
        .read(registerUseCaseProvider)
        .call(RegisterParams(name: name, email: email, password: password));
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (user) => AsyncValue.data(user),
    );
  }

  Future<void> logout() async {
    await ref.read(logoutUseCaseProvider).call(const NoParams());
    state = const AsyncValue.data(null);
  }
}

final authProvider =
    AsyncNotifierProvider<AuthNotifier, User?>(AuthNotifier.new);

/// Convenience: true when a user is logged in (ignores loading/error).
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).valueOrNull != null;
});
