import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../logger/logger.dart';

/// Logs every request, response and error without changing transport data.
/// Headers and file contents are omitted; credentials are redacted recursively.
class ApiLogInterceptor extends Interceptor {
  static const _startedAtKey = '__areana_log_started_at';
  static const _redacted = '***REDACTED***';
  static const _sensitiveKeys = {
    'code',
    'otp',
    'password',
    'passwordhash',
    'accesstoken',
    'refreshtoken',
    'token',
    'authorization',
    'devicetoken',
    'apikey',
    'clientsecret',
    'secret',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!Logger.isEnabled) {
      handler.next(options);
      return;
    }
    options.extra[_startedAtKey] = Stopwatch()..start();
    Logger.info(
      tag: 'HTTP_REQUEST',
      message: {
        'method': options.method,
        'url': _safeUri(options.uri),
        if (options.queryParameters.isNotEmpty)
          'query': _redact(options.queryParameters),
        if (options.data != null) 'body': _redact(options.data),
      },
    );
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (!Logger.isEnabled) {
      handler.next(response);
      return;
    }
    final request = response.requestOptions;
    Logger.success(
      tag: 'HTTP_RESPONSE',
      message: {
        'method': request.method,
        'url': _safeUri(request.uri),
        'statusCode': response.statusCode,
        'elapsedMs': _elapsedMs(request),
        'body': _redact(response.data),
      },
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!Logger.isEnabled) {
      handler.next(err);
      return;
    }
    final request = err.requestOptions;
    Logger.error(
      tag: 'HTTP_ERROR',
      message: {
        'method': request.method,
        'url': _safeUri(request.uri),
        'statusCode': err.response?.statusCode,
        'elapsedMs': _elapsedMs(request),
        'type': err.type.name,
        if (err.message != null)
          'message': err.message!.replaceAll(
            request.uri.toString(),
            _safeUri(request.uri),
          ),
        if (err.response?.data != null) 'body': _redact(err.response!.data),
      },
      stackTrace: err.stackTrace,
    );
    handler.next(err);
  }

  int _elapsedMs(RequestOptions request) {
    final started = request.extra[_startedAtKey];
    return started is Stopwatch ? started.elapsedMilliseconds : 0;
  }

  bool _isSensitive(String key) => _sensitiveKeys.contains(
    key.toLowerCase().replaceAll(RegExp(r'[_\-\s]'), ''),
  );

  String _safeUri(Uri uri) => uri
      .replace(
        userInfo: '',
        queryParameters: uri.hasQuery
            ? {
                for (final entry in uri.queryParametersAll.entries)
                  entry.key: _isSensitive(entry.key) ? _redacted : entry.value,
              }
            : null,
      )
      .toString();

  Object? _redact(Object? data) {
    if (data is FormData) {
      return {
        'fields': [
          for (final field in data.fields)
            {
              'name': field.key,
              'value': _isSensitive(field.key)
                  ? _redacted
                  : _redact(field.value),
            },
        ],
        'files': [for (final file in data.files) file.value.filename],
      };
    }
    if (data is Uint8List) return '<binary: ${data.length} bytes>';
    if (data is Stream) return '<stream>';
    if (data is Map) {
      return {
        for (final entry in data.entries)
          entry.key.toString(): _isSensitive(entry.key.toString())
              ? _redacted
              : _redact(entry.value),
      };
    }
    if (data is List) return data.map(_redact).toList(growable: false);
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map || decoded is List) return _redact(decoded);
      } on FormatException {
        // Plain text, rather than JSON.
      }
    }
    return data;
  }
}
