import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart' hide Task;

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_datasource.dart';
import '../datasources/task_remote_datasource.dart';
import '../models/task_model.dart';

/// jsonplaceholder does not persist writes, so once tasks are loaded the local
/// cache becomes the source of truth: reads prefer the cache, and mutations are
/// applied to the cache (with best-effort remote sync) so they survive.
class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl({
    required TaskRemoteDataSource remote,
    required TaskLocalDataSource local,
    required NetworkInfo networkInfo,
  })  : _remote = remote,
        _local = local,
        _networkInfo = networkInfo;

  final TaskRemoteDataSource _remote;
  final TaskLocalDataSource _local;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, List<Task>>> getTasks({
    required int projectId,
    required int userId,
  }) async {
    // Cache holds any local mutations and is authoritative once populated.
    final cached = _local.getCachedTasks(projectId);
    if (cached != null) return right(cached);

    if (!await _networkInfo.isConnected) {
      return left(const NetworkFailure());
    }
    try {
      final tasks = await _remote.getTasks(userId: userId, projectId: projectId);
      await _local.cacheTasks(projectId, tasks);
      return right(tasks);
    } on ServerException catch (e) {
      return left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return left(NetworkFailure(e.message));
    } catch (_) {
      return left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Task>> toggleDone(Task task) async {
    final updated = TaskModel.fromEntity(
      task.copyWith(
        status: task.isDone ? TaskStatus.pending : TaskStatus.done,
      ),
    );
    try {
      await _local.upsertTask(updated);
    } catch (_) {
      return left(const CacheFailure('Could not update the task.'));
    }
    // Best-effort remote sync; the mock API does not persist, so we tolerate
    // failures here and keep the local change (also enables offline edits).
    try {
      await _remote.setCompleted(id: updated.id, completed: updated.isDone);
    } catch (_) {/* ignored intentionally */}
    return right(updated);
  }

  @override
  Future<Either<Failure, Task>> addTask({
    required int projectId,
    required int userId,
    required String title,
    required TaskPriority priority,
  }) async {
    final newTask = TaskModel(
      // Local id (POST /todos always returns 201, so we can't rely on it).
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      projectId: projectId,
      title: title.trim(),
      status: TaskStatus.pending,
      priority: priority,
    );
    try {
      await _local.upsertTask(newTask);
    } catch (_) {
      return left(const CacheFailure('Could not save the task.'));
    }
    try {
      await _remote.create(title: newTask.title, userId: userId);
    } catch (_) {/* ignored intentionally */}
    return right(newTask);
  }
}

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(
    remote: ref.read(taskRemoteDataSourceProvider),
    local: ref.read(taskLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});
