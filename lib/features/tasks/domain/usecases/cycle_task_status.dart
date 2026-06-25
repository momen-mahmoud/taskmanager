import 'package:fpdart/fpdart.dart' hide Task;

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Advances a task to its next status (Pending → In Progress → Done → …).
class CycleTaskStatus implements UseCase<Task, Task> {
  const CycleTaskStatus(this._repository);

  final TaskRepository _repository;

  @override
  Future<Either<Failure, Task>> call(Task params) {
    return _repository.cycleStatus(params);
  }
}
