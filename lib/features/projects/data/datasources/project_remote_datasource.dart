import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/project_model.dart';

class ProjectRemoteDataSource {
  ProjectRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<ProjectModel>> getProjects() async {
    try {
      final response = await _dio.get<List<dynamic>>(AppConstants.postsEndpoint);
      final data = response.data ?? const [];
      return data
          .map((e) => ProjectModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      mapDioException(e); // throws a domain exception (returns Never)
    }
  }
}

final projectRemoteDataSourceProvider = Provider<ProjectRemoteDataSource>((ref) {
  return ProjectRemoteDataSource(ref.read(dioProvider));
});
