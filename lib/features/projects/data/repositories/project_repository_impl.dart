import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/project_local_datasource.dart';
import '../datasources/project_remote_datasource.dart';

/// Network-first repository: fetch from the API and refresh the cache; on any
/// network/server error (or when offline) fall back to the cached list.
class ProjectRepositoryImpl implements ProjectRepository {
  ProjectRepositoryImpl({
    required ProjectRemoteDataSource remote,
    required ProjectLocalDataSource local,
    required NetworkInfo networkInfo,
  })  : _remote = remote,
        _local = local,
        _networkInfo = networkInfo;

  final ProjectRemoteDataSource _remote;
  final ProjectLocalDataSource _local;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, List<Project>>> getProjects() async {
    if (!await _networkInfo.isConnected) {
      return _cacheOr(const NetworkFailure());
    }
    try {
      final projects = await _remote.getProjects();
      await _local.cacheProjects(projects);
      return right(projects);
    } on ServerException catch (e) {
      return _cacheOr(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return _cacheOr(NetworkFailure(e.message));
    } catch (_) {
      return _cacheOr(const ServerFailure());
    }
  }

  /// Returns cached projects if present, otherwise the supplied [failure].
  Either<Failure, List<Project>> _cacheOr(Failure failure) {
    try {
      return right(_local.getCachedProjects());
    } catch (_) {
      return left(failure);
    }
  }
}

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepositoryImpl(
    remote: ref.read(projectRemoteDataSourceProvider),
    local: ref.read(projectLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});
