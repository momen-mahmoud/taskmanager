import 'package:fpdart/fpdart.dart' hide Task;

import '../../../../core/error/failures.dart';
import '../entities/task.dart';

abstract class TaskRepository {
  /// Tasks for a project. jsonplaceholder has no project→task link, so we fetch
  /// `/todos?userId={userId}` and treat them as [projectId]'s tasks.
  Future<Either<Failure, List<Task>>> getTasks({
    required int projectId,
    required int userId,
  });

  /// Toggles a task's done state (optimistic; cache is the source of truth).
  Future<Either<Failure, Task>> toggleDone(Task task);

  /// Adds a new task to a project.
  Future<Either<Failure, Task>> addTask({
    required int projectId,
    required int userId,
    required String title,
    required TaskPriority priority,
  });
}
