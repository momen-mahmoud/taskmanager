import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/task_model.dart';

class TaskRemoteDataSource {
  TaskRemoteDataSource(this._dio);

  final Dio _dio;

  /// GET /todos?userId={userId} — mapped to the given [projectId].
  Future<List<TaskModel>> getTasks({
    required int userId,
    required int projectId,
  }) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        AppConstants.todosEndpoint,
        queryParameters: {'userId': userId},
      );
      final data = response.data ?? const [];
      return data
          .map((e) => TaskModel.fromApi(e as Map<String, dynamic>, projectId))
          .toList();
    } on DioException catch (e) {
      mapDioException(e);
    }
  }

  /// PATCH /todos/{id} — jsonplaceholder fakes a successful response.
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

  /// POST /todos — jsonplaceholder fakes a created response (always id 201).
  Future<void> create({required String title, required int userId}) async {
    try {
      await _dio.post<dynamic>(
        AppConstants.todosEndpoint,
        data: {'title': title, 'userId': userId, 'completed': false},
      );
    } on DioException catch (e) {
      mapDioException(e);
    }
  }
}

final taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
  return TaskRemoteDataSource(ref.read(dioProvider));
});
