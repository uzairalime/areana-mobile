import 'package:dio/dio.dart';
import 'api_dio.dart';
import 'app_interceptor.dart';

class DioService {
  const DioService._();

  static Dio create() {
    final interceptor = AppInterceptor();
    final dio = createApiDio(interceptors: [interceptor]);
    // The interceptor needs the Dio instance to retry a request after
    // a successful refresh. Attach after creation to avoid a cycle.
    interceptor.dio = dio;
    return dio;
  }
}
