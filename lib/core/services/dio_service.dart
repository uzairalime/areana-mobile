import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../consts/api_endpoints.dart';
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
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (object) => debugPrint(object.toString()),
        ),
      );
    }
    return dio;
  }
}
