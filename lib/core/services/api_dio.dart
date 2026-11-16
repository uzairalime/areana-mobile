import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../consts/api_endpoints.dart';
import 'api_log_interceptor.dart';

/// Shared transport settings for regular requests and token refresh.
/// Callers supply only the interceptors appropriate for that client.
Dio createApiDio({Iterable<Interceptor> interceptors = const []}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      responseType: ResponseType.json,
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );
  dio.interceptors.addAll(interceptors);
  if (kDebugMode) {
    dio.interceptors.add(ApiLogInterceptor());
  }
  return dio;
}
