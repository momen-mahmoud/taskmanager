import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/hive_boxes.dart';
import '../models/task_model.dart';

/// Per-project task cache (JSON in Hive). This is the source of truth for
/// mutations, since jsonplaceholder does not persist writes.
class TaskLocalDataSource {
  TaskLocalDataSource([Box<String>? box]) : _box = box ?? HiveBoxes.cache;

  final Box<String> _box;

  Future<void> cacheTasks(int projectId, List<TaskModel> tasks) {
    final encoded = jsonEncode(tasks.map((t) => t.toJson()).toList());
    return _box.put(AppConstants.tasksCacheKey(projectId), encoded);
  }

  /// Returns cached tasks, or `null` if nothing is cached for this project.
  List<TaskModel>? getCachedTasks(int projectId) {
    final raw = _box.get(AppConstants.tasksCacheKey(projectId));
    if (raw == null) return null;
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Replaces a single task in the cache and returns the updated list.
  Future<List<TaskModel>> upsertTask(TaskModel task) async {
    final current = getCachedTasks(task.projectId) ?? <TaskModel>[];
    final index = current.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      current[index] = task;
    } else {
      current.insert(0, task);
    }
    await cacheTasks(task.projectId, current);
    return current;
  }

  List<TaskModel> requireCachedTasks(int projectId) {
    final cached = getCachedTasks(projectId);
    if (cached == null) throw const CacheException();
    return cached;
  }
}

final taskLocalDataSourceProvider = Provider<TaskLocalDataSource>((ref) {
  return TaskLocalDataSource();
});
