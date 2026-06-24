import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';

/// Contract for authentication operations. Implemented in the data layer.
abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> logout();

  /// Returns the logged-in user if a valid session exists, otherwise `null`.
  Future<Either<Failure, User?>> getCurrentUser();
}
