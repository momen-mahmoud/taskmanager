import 'package:fpdart/fpdart.dart' hide Task;

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class ToggleTaskDone implements UseCase<Task, Task> {
  const ToggleTaskDone(this._repository);

  final TaskRepository _repository;

  @override
  Future<Either<Failure, Task>> call(Task params) {
    return _repository.toggleDone(params);
  }
}
