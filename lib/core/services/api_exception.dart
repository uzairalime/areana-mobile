import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  factory ApiException.fromDio(DioException error) {
    final data = error.response?.data;
    var message = error.message ?? 'Request failed';
    if (data is Map && data['message'] is String) {
      message = data['message'] as String;
    }
    return ApiException(message, statusCode: error.response?.statusCode);
  }

  @override
  String toString() => message;
}
