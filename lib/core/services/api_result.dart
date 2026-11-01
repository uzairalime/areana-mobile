import 'package:dio/dio.dart';

import 'api_exception.dart';

sealed class ApiResult<T> {
  const ApiResult();

  bool get isSuccess => this is ApiSuccess<T>;

  bool get isError => this is ApiError<T>;

  T? get dataOrNull => switch (this) {
    ApiSuccess(:final data) => data,
    ApiError() => null,
  };

  ApiError<T>? get errorOrNull => switch (this) {
    ApiSuccess() => null,
    final ApiError<T> error => error,
  };

  R when<R>({
    required R Function(T data) success,
    required R Function(ApiError<T> error) failure,
  }) {
    return switch (this) {
      ApiSuccess(:final data) => success(data),
      final ApiError<T> error => failure(error),
    };
  }

  ApiResult<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      ApiSuccess(:final data, :final statusCode) => ApiSuccess(
        transform(data),
        statusCode: statusCode,
      ),
      final ApiError<T> error => error.cast(),
    };
  }
}

final class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data, {this.statusCode});

  final T data;
  final int? statusCode;
}

final class ApiError<T> extends ApiResult<T> {
  const ApiError({
    required this.message,
    this.statusCode,
    this.error,
    this.errors,
    this.data,
  });

  final String message;
  final int? statusCode;
  final Object? error;
  final Map<String, dynamic>? errors;

  /// Full response body, when it was a JSON object. Callers use it for
  /// top-level fields that are not field errors — for example the
  /// OTP 429 body's `retryAfterSeconds` / `resetsAt`.
  final Map<String, dynamic>? data;

  factory ApiError.fromDio(DioException exception) {
    final apiException = ApiException.fromDio(exception);
    final data = exception.response?.data;
    Map<String, dynamic>? fieldErrors;
    Map<String, dynamic>? body;
    if (data is Map) {
      body = Map<String, dynamic>.from(data);
      if (data['errors'] is Map) {
        fieldErrors = Map<String, dynamic>.from(data['errors'] as Map);
      }
    }
    return ApiError(
      message: apiException.message,
      statusCode: apiException.statusCode,
      error: exception,
      errors: fieldErrors,
      data: body,
    );
  }

  factory ApiError.fromException(Object exception) {
    return switch (exception) {
      DioException value => ApiError.fromDio(value),
      ApiException value => ApiError(
        message: value.message,
        statusCode: value.statusCode,
        error: value,
      ),
      _ => ApiError(message: exception.toString(), error: exception),
    };
  }

  ApiError<R> cast<R>() {
    return ApiError<R>(
      message: message,
      statusCode: statusCode,
      error: error,
      errors: errors,
      data: data,
    );
  }

  @override
  String toString() => 'ApiError($statusCode): $message';
}
