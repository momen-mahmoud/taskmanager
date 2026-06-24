import 'package:assessment/features/tasks/data/models/task_model.dart';
import 'package:assessment/features/tasks/domain/entities/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TaskModel.fromApi', () {
    test('maps completed=true to TaskStatus.done', () {
      final model = TaskModel.fromApi(
        {'id': 3, 'title': 'Write report', 'completed': true},
        7,
      );
      expect(model.status, TaskStatus.done);
      expect(model.projectId, 7);
      expect(model.title, 'Write report');
    });

    test('maps completed=false to TaskStatus.pending', () {
      final model =
          TaskModel.fromApi({'id': 1, 'title': 'x', 'completed': false}, 1);
      expect(model.status, TaskStatus.pending);
    });

    test('derives priority deterministically from id', () {
      for (var id = 0; id < 9; id++) {
        final model =
            TaskModel.fromApi({'id': id, 'title': 't', 'completed': false}, 1);
        expect(model.priority, TaskPriority.values[id % 3]);
      }
    });
  });

  group('TaskModel JSON round-trip', () {
    test('toJson then fromJson preserves all fields', () {
      const original = TaskModel(
        id: 42,
        projectId: 5,
        title: 'Cache me',
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
      );
      final restored = TaskModel.fromJson(original.toJson());
      expect(restored, original);
    });
  });

  group('Task.copyWith', () {
    test('toggles status while keeping identity', () {
      const task = Task(
        id: 1,
        projectId: 1,
        title: 't',
        status: TaskStatus.pending,
        priority: TaskPriority.low,
      );
      final done = task.copyWith(status: TaskStatus.done);
      expect(done.isDone, true);
      expect(done.id, task.id);
      expect(done.title, task.title);
    });
  });
}
