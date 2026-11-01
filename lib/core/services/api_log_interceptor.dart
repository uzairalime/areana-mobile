import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// App-wide logger. Reuse this for non-API logs too; do not create a
/// second `Logger` elsewhere.
///
/// Debug-only in practice: the interceptor that uses it is only added
/// in `kDebugMode` (see [DioService] and the refresh Dio in
/// [AppInterceptor]), so no request or response body ever reaches a
/// release log.
final appLogger = Logger(printer: SimplePrinter(colors: false));

/// Logs every API call through [appLogger]: method + full endpoint URL,
/// request body, and response body (or error body).
///
/// Example (debug console):
///   API → POST http://10.31.147.229:3000/api/auth/request-otp
///   API → body: {"email":"alex@pitchside.app"}
///   API ← 200 POST http://10.31.147.229:3000/api/auth/request-otp (214ms)
///   API ← body: {"message":"...","expiresAt":"...","ttlSeconds":600}
///
/// Sensitive values are NEVER logged in the clear. Any map key that
/// looks like a secret — OTP `code`, passwords, `accessToken` /
/// `refreshToken`, `deviceToken`, `Authorization` — is replaced with
/// `***REDACTED***` in both request and response bodies, and headers
/// are never logged at all. That rule is the reason this interceptor
/// exists instead of Dio's built-in `LogInterceptor`, which would
/// print the OTP code and both tokens verbatim.
class ApiLogInterceptor extends Interceptor {
  static const _startedAtKey = '__areana_log_started_at';
  static const _maxBodyLength = 2000;

  /// Keys whose values are redacted, compared after lowercasing and
  /// stripping underscores, so `accessToken`, `access_token` and
  /// `AccessToken` all match.
  static const _sensitiveKeys = {
    'code',
    'otp',
    'password',
    'accesstoken',
    'refreshtoken',
    'token',
    'authorization',
    'devicetoken',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startedAtKey] =
        DateTime.now().millisecondsSinceEpoch;
    appLogger.i('API → ${options.method} ${options.uri}');
    if (options.queryParameters.isNotEmpty) {
      appLogger.i('API → query: ${_stringify(options.queryParameters)}');
    }
    if (options.data != null) {
      appLogger.i('API → body: ${_stringify(_redact(options.data))}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final request = response.requestOptions;
    appLogger.i(
      'API ← ${response.statusCode} ${request.method} ${request.uri} '
      '(${_elapsedMs(request)}ms)',
    );
    if (response.data != null) {
      appLogger.i('API ← body: ${_stringify(_redact(response.data))}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final request = err.requestOptions;
    final status = err.response?.statusCode;
    appLogger.e(
      'API ✗ ${status ?? err.type} ${request.method} ${request.uri} '
      '(${_elapsedMs(request)}ms)',
    );
    final errorBody = err.response?.data;
    if (errorBody != null) {
      appLogger.e('API ✗ body: ${_stringify(_redact(errorBody))}');
    } else if (err.message != null) {
      appLogger.e('API ✗ ${err.message}');
    }
    handler.next(err);
  }

  int _elapsedMs(RequestOptions request) {
    final started = request.extra[_startedAtKey];
    if (started is! int) return 0;
    return DateTime.now().millisecondsSinceEpoch - started;
  }

  dynamic _redact(dynamic data) {
    if (data is Map) {
      return data.map(
        (key, value) => MapEntry(
          key,
          _sensitiveKeys.contains(
            key.toString().toLowerCase().replaceAll('_', ''),
          )
              ? '***REDACTED***'
              : _redact(value),
        ),
      );
    }
    if (data is List) {
      return data.map(_redact).toList();
    }
    if (data is FormData) {
      // Fields only, redacted the same way; file contents are never
      // logged, only their names.
      return {
        'fields': data.fields.map(
          (field) => MapEntry(
            field.key,
            _sensitiveKeys.contains(
              field.key.toLowerCase().replaceAll('_', ''),
            )
                ? '***REDACTED***'
                : field.value,
          ),
        ),
        'files': data.files.map((file) => file.value.filename).toList(),
      };
    }
    return data;
  }

  String _stringify(dynamic data) {
    String text;
    try {
      text = data is String ? data : jsonEncode(data);
    } catch (_) {
      text = data.toString();
    }
    if (text.length <= _maxBodyLength) return text;
    return '${text.substring(0, _maxBodyLength)}… (truncated)';
  }
}
