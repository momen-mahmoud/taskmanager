import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/hive_boxes.dart';
import '../models/project_model.dart';

/// Caches the project list as a JSON string in Hive for offline access.
class ProjectLocalDataSource {
  ProjectLocalDataSource([Box<String>? box]) : _box = box ?? HiveBoxes.cache;

  final Box<String> _box;

  Future<void> cacheProjects(List<ProjectModel> projects) {
    final encoded = jsonEncode(projects.map((p) => p.toJson()).toList());
    return _box.put(AppConstants.projectsCacheKey, encoded);
  }

  List<ProjectModel> getCachedProjects() {
    final raw = _box.get(AppConstants.projectsCacheKey);
    if (raw == null) throw const CacheException();
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => ProjectModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final projectLocalDataSourceProvider = Provider<ProjectLocalDataSource>((ref) {
  return ProjectLocalDataSource();
});
