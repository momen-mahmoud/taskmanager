import 'package:equatable/equatable.dart';

enum TaskStatus {
  pending,
  inProgress,
  done;

  String get label => switch (this) {
        TaskStatus.pending => 'Pending',
        TaskStatus.inProgress => 'In Progress',
        TaskStatus.done => 'Done',
      };
}

/// Priority is not provided by jsonplaceholder; it is derived from the task id.
enum TaskPriority {
  low,
  medium,
  high;

  String get label => switch (this) {
        TaskPriority.low => 'Low',
        TaskPriority.medium => 'Medium',
        TaskPriority.high => 'High',
      };
}

class Task extends Equatable {
  const Task({
    required this.id,
    required this.projectId,
    required this.title,
    required this.status,
    required this.priority,
  });

  final int id;
  final int projectId;
  final String title;
  final TaskStatus status;
  final TaskPriority priority;

  bool get isDone => status == TaskStatus.done;

  /// Next status when the user taps the task: Pending → In Progress → Done → …
  TaskStatus get nextStatus => switch (status) {
        TaskStatus.pending => TaskStatus.inProgress,
        TaskStatus.inProgress => TaskStatus.done,
        TaskStatus.done => TaskStatus.pending,
      };

  Task copyWith({TaskStatus? status, TaskPriority? priority, String? title}) {
    return Task(
      id: id,
      projectId: projectId,
      title: title ?? this.title,
      status: status ?? this.status,
      priority: priority ?? this.priority,
    );
  }

  @override
  List<Object?> get props => [id, projectId, title, status, priority];
}
