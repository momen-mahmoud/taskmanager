import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._local);

  final AuthLocalDataSource _local;

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) =>
      _guard(() => _local.login(email: email, password: password));

  @override
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
  }) =>
      _guard(() => _local.register(name: name, email: email, password: password));

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _local.logout();
      return right(unit);
    } catch (_) {
      return left(const CacheFailure('Failed to clear session.'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      return right(await _local.getCurrentUser());
    } catch (_) {
      return right(null); // treat a broken session as "logged out"
    }
  }

  Future<Either<Failure, User>> _guard(Future<User> Function() action) async {
    try {
      return right(await action());
    } on AuthException catch (e) {
      return left(AuthFailure(e.message));
    } catch (_) {
      return left(const ServerFailure('Unexpected error. Please try again.'));
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(authLocalDataSourceProvider));
});
