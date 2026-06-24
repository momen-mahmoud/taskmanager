import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/task_model.dart';

class TaskRemoteDataSource {
  TaskRemoteDataSource(this._dio);

  final Dio _dio;

  /// Tasks for a project. dummyjson's per-user todos are sparse (a post's
  /// userId rarely has todos), so we map each project to a deterministic,
  /// non-empty slice of `/todos` derived from its id. Response is wrapped:
  /// { "todos": [...], "total", "skip", "limit" }.
  Future<List<TaskModel>> getTasks({required int projectId}) async {
    try {
      final skip = (projectId * 7) % 240; // stable per project, always in range
      final response = await _dio.get<Map<String, dynamic>>(
        AppConstants.todosEndpoint,
        queryParameters: {'limit': 10, 'skip': skip},
      );
      final data = (response.data?['todos'] as List<dynamic>?) ?? const [];
      return data
          .map((e) => TaskModel.fromApi(e as Map<String, dynamic>, projectId))
          .toList();
    } on DioException catch (e) {
      mapDioException(e);
    }
  }

  /// PATCH /todos/{id} — dummyjson echoes the update (does not persist).
  Future<void> setCompleted({required int id, required bool completed}) async {
    try {
      await _dio.patch<dynamic>(
        '${AppConstants.todosEndpoint}/$id',
        data: {'completed': completed},
      );
    } on DioException catch (e) {
      mapDioException(e);
    }
  }

  /// POST /todos/add — dummyjson echoes a created todo (does not persist).
  Future<void> create({required String title, required int userId}) async {
    try {
      await _dio.post<dynamic>(
        AppConstants.todosAddEndpoint,
        data: {'todo': title, 'userId': userId, 'completed': false},
      );
    } on DioException catch (e) {
      mapDioException(e);
    }
  }
}

final taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
  return TaskRemoteDataSource(ref.read(dioProvider));
});
