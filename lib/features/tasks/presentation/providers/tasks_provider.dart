import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/task_repository_impl.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/add_task.dart';
import '../../domain/usecases/cycle_task_status.dart';
import '../../domain/usecases/get_tasks.dart';

/// Family argument: a project's id plus the user id used to fetch its tasks.
typedef TaskArgs = ({int projectId, int userId});

// ---- use-case providers ----
final getTasksUseCaseProvider =
    Provider((ref) => GetTasks(ref.read(taskRepositoryProvider)));
final cycleTaskStatusUseCaseProvider =
    Provider((ref) => CycleTaskStatus(ref.read(taskRepositoryProvider)));
final addTaskUseCaseProvider =
    Provider((ref) => AddTask(ref.read(taskRepositoryProvider)));

/// Per-project task list. Mutations update the in-memory `AsyncValue` and the
/// Hive cache, so they persist across navigation and offline.
class TasksNotifier extends FamilyAsyncNotifier<List<Task>, TaskArgs> {
  @override
  Future<List<Task>> build(TaskArgs arg) async {
    final result = await ref.read(getTasksUseCaseProvider).call(
          GetTasksParams(projectId: arg.projectId),
        );
    return result.fold((failure) => throw failure.message, (tasks) => tasks);
  }

  Future<void> cycle(Task task) async {
    final result = await ref.read(cycleTaskStatusUseCaseProvider).call(task);
    result.match(
      (failure) => throw failure.message,
      (updated) {
        final current = [...?state.valueOrNull];
        final index = current.indexWhere((t) => t.id == updated.id);
        if (index >= 0) current[index] = updated;
        state = AsyncValue.data(current);
      },
    );
  }

  Future<void> add({required String title, required TaskPriority priority}) async {
    final result = await ref.read(addTaskUseCaseProvider).call(
          AddTaskParams(
            projectId: arg.projectId,
            userId: arg.userId,
            title: title,
            priority: priority,
          ),
        );
    result.match(
      (failure) => throw failure.message,
      (task) => state = AsyncValue.data([task, ...?state.valueOrNull]),
    );
  }
}

final tasksProvider =
    AsyncNotifierProvider.family<TasksNotifier, List<Task>, TaskArgs>(
  TasksNotifier.new,
);
