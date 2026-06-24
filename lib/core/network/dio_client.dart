import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../error/exceptions.dart';
import '../storage/secure_storage.dart';
import 'auth_interceptor.dart';

/// Configured [Dio] instance (base URL, timeouts, auth + logging interceptors).
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(AuthInterceptor(ref.read(secureStorageProvider)));

  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: false),
    );
  }

  return dio;
});

/// Translates a low-level [DioException] into a domain-level exception so the
/// repository layer can map it to a [Failure] with a single switch.
Never mapDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      throw const NetworkException('Connection timed out. Check your network.');
    case DioExceptionType.badResponse:
      final code = e.response?.statusCode;
      if (code == 401 || code == 403) {
        throw const AuthException('Session expired. Please log in again.');
      }
      throw ServerException('Server error (${code ?? 'unknown'}).');
    case DioExceptionType.cancel:
      throw const NetworkException('Request cancelled.');
    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
      throw const NetworkException('Network error. Please try again.');
  }
}
