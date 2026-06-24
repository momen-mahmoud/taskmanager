import 'package:dio/dio.dart';

/// Retries transient connection failures (e.g. "connection reset by peer",
/// timeouts) a few times with a short backoff before giving up.
///
/// CDN-backed hosts and emulators frequently drop the first connection, so a
/// couple of automatic retries dramatically improves reliability.
class RetryInterceptor extends Interceptor {
  RetryInterceptor(this._dio, {this.maxRetries = 3});

  final Dio _dio;
  final int maxRetries;

  static const _attemptKey = 'retry_attempt';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final attempt = (err.requestOptions.extra[_attemptKey] as int?) ?? 0;

    if (_isRetryable(err) && attempt < maxRetries) {
      final next = attempt + 1;
      // Linear backoff: 400ms, 800ms, 1200ms.
      await Future<void>.delayed(Duration(milliseconds: 400 * next));

      final options = err.requestOptions..extra[_attemptKey] = next;
      try {
        final response = await _dio.fetch<dynamic>(options);
        return handler.resolve(response);
      } on DioException catch (e) {
        return handler.next(e);
      }
    }
    handler.next(err);
  }

  bool _isRetryable(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return true;
      case DioExceptionType.badResponse:
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return false;
    }
  }
}
