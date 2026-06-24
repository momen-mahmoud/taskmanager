import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart' hide Task;

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class GetTasks implements UseCase<List<Task>, GetTasksParams> {
  const GetTasks(this._repository);

  final TaskRepository _repository;

  @override
  Future<Either<Failure, List<Task>>> call(GetTasksParams params) {
    return _repository.getTasks(
      projectId: params.projectId,
      userId: params.userId,
    );
  }
}

class GetTasksParams extends Equatable {
  const GetTasksParams({required this.projectId, required this.userId});

  final int projectId;
  final int userId;

  @override
  List<Object?> get props => [projectId, userId];
}
