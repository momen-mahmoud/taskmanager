import 'package:equatable/equatable.dart';

/// Base class for all failures surfaced to the domain/presentation layers.
///
/// Failures are returned (via `Either<Failure, T>`) rather than thrown, so the
/// UI can render a user-facing [message] consistently.
sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Server returned an error status or unexpected response.
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong on the server.']);
}

/// No connectivity / request timed out / socket error.
class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'No internet connection. Please try again.',
  ]);
}

/// Local cache read/write failed or no cached data is available.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'No cached data available.']);
}

/// Authentication failed (bad credentials, duplicate email, expired session).
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed.']);
}

/// Input validation failed.
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Invalid input.']);
}
