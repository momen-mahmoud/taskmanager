import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart' hide Task;

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class AddTask implements UseCase<Task, AddTaskParams> {
  const AddTask(this._repository);

  final TaskRepository _repository;

  @override
  Future<Either<Failure, Task>> call(AddTaskParams params) {
    return _repository.addTask(
      projectId: params.projectId,
      userId: params.userId,
      title: params.title,
      priority: params.priority,
    );
  }
}

class AddTaskParams extends Equatable {
  const AddTaskParams({
    required this.projectId,
    required this.userId,
    required this.title,
    required this.priority,
  });

  final int projectId;
  final int userId;
  final String title;
  final TaskPriority priority;

  @override
  List<Object?> get props => [projectId, userId, title, priority];
}
