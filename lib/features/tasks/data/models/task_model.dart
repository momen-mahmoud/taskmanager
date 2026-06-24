import '../../domain/entities/task.dart';

/// Data-layer [Task]. Maps a jsonplaceholder `/todos` item
/// (userId, id, title, completed) onto our domain model and round-trips through
/// the Hive cache. Status/priority are derived where the API lacks them.
class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.projectId,
    required super.title,
    required super.status,
    required super.priority,
  });

  /// Maps a `/todos` API item. [projectId] is supplied by the caller because the
  /// API has no project association.
  factory TaskModel.fromApi(Map<String, dynamic> json, int projectId) {
    final id = json['id'] as int;
    final completed = json['completed'] as bool? ?? false;
    return TaskModel(
      id: id,
      projectId: projectId,
      title: (json['title'] as String?)?.trim() ?? '',
      status: completed ? TaskStatus.done : TaskStatus.pending,
      priority: TaskPriority.values[id % TaskPriority.values.length],
    );
  }

  /// Reads a task back from cached JSON (full fidelity, includes our fields).
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as int,
      projectId: json['projectId'] as int,
      title: json['title'] as String,
      status: TaskStatus.values.byName(json['status'] as String),
      priority: TaskPriority.values.byName(json['priority'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'title': title,
        'status': status.name,
        'priority': priority.name,
      };

  factory TaskModel.fromEntity(Task task) => TaskModel(
        id: task.id,
        projectId: task.projectId,
        title: task.title,
        status: task.status,
        priority: task.priority,
      );
}
