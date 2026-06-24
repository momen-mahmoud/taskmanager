import '../../domain/entities/project.dart';

/// Data-layer [Project]. Maps a jsonplaceholder `/posts` item
/// (id, userId, title, body) onto our domain model, deriving a [ProjectStatus]
/// from the id (the API has no status). Also round-trips through Hive cache.
class ProjectModel extends Project {
  const ProjectModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.description,
    required super.status,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final statusName = json['status'] as String?;
    return ProjectModel(
      id: id,
      userId: json['userId'] as int,
      title: (json['title'] as String?)?.trim() ?? '',
      // 'body' from the API maps to our 'description'; cache uses 'description'.
      description: ((json['description'] ?? json['body']) as String?)?.trim() ?? '',
      status: statusName != null
          ? ProjectStatus.values.byName(statusName)
          : ProjectStatus.values[id % ProjectStatus.values.length],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'description': description,
        'status': status.name,
      };
}
