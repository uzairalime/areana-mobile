import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../consts/api_endpoints.dart';
import 'api_log_interceptor.dart';
import 'app_interceptor.dart';

class DioService {
  const DioService._();

  static Dio create() {
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
    final interceptor = AppInterceptor();
    dio.interceptors.add(interceptor);
    // The interceptor needs the Dio instance to retry a request after
    // a successful refresh. Attach after creation to avoid a cycle.
    interceptor.dio = dio;
    // Replaces Dio's built-in LogInterceptor: that one prints headers
    // (including Authorization) and raw bodies (including OTP codes
    // and tokens). ApiLogInterceptor logs endpoint + request body +
    // response body through `logger`, with secrets redacted, and
    // never logs headers.
    if (kDebugMode) {
      dio.interceptors.add(ApiLogInterceptor());
    }
    return dio;
  }
}
