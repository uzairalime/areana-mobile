import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  factory ApiException.fromDio(DioException error) {
    final data = error.response?.data;
    var message = error.message ?? 'Request failed';
    if (data is Map) {
      final serverMessage = data['message'];
      if (serverMessage is String && serverMessage.isNotEmpty) {
        message = serverMessage;
      } else if (serverMessage is List) {
        final messages = serverMessage.whereType<String>().where(
          (value) => value.isNotEmpty,
        );
        if (messages.isNotEmpty) message = messages.join('\n');
      }
    }
    return ApiException(message, statusCode: error.response?.statusCode);
  }

  @override
  String toString() => message;
}
