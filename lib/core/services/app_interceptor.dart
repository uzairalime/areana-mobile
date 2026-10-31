import 'package:dio/dio.dart';

import 'locator.dart';
import 'token_store.dart';

class AppInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (getIt.isRegistered<TokenStore>()) {
      final token = getIt<TokenStore>().accessToken;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }
}
