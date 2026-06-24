import 'package:equatable/equatable.dart';

/// Lifecycle status of a project. jsonplaceholder has no status field, so it is
/// derived deterministically from the project id (see ProjectModel).
enum ProjectStatus {
  active,
  onHold,
  completed;

  String get label => switch (this) {
        ProjectStatus.active => 'Active',
        ProjectStatus.onHold => 'On Hold',
        ProjectStatus.completed => 'Completed',
      };
}

class Project extends Equatable {
  const Project({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.status,
  });

  final int id;
  final int userId;
  final String title;
  final String description;
  final ProjectStatus status;

  @override
  List<Object?> get props => [id, userId, title, description, status];
}
