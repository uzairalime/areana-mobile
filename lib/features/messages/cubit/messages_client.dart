import 'package:dio/dio.dart';

import '../../../core/consts/api_endpoints.dart';
import '../../../core/services/api_result.dart';
import '../model/chat_message.dart';
import '../model/chat_thread.dart';

class MessagesClient {
  const MessagesClient(this._dio);

  final Dio _dio;

  Future<ApiResult<List<ChatThread>>> fetchThreads() async {
    try {
      final response = await _dio.get<dynamic>(ApiEndpoints.conversations);
      final list = _asList(response.data);
      if (list == null) {
        return const ApiError(message: 'Unexpected response');
      }
      final threads = list
          .whereType<Map>()
          .map((e) => ChatThread.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return ApiSuccess(threads, statusCode: response.statusCode);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<ChatThread>> fetchThread(String id) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.conversation(id),
      );
      final map = _asMap(response.data);
      if (map == null) {
        return const ApiError(message: 'Unexpected response');
      }
      return ApiSuccess(
        ChatThread.fromJson(map),
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<List<ChatMessage>>> fetchMessages(String threadId) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.conversationMessages(threadId),
      );
      final list = _asList(response.data);
      if (list == null) {
        return const ApiError(message: 'Unexpected response');
      }
      final messages = list
          .whereType<Map>()
          .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return ApiSuccess(messages, statusCode: response.statusCode);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<ChatMessage>> sendMessage({
    required String threadId,
    required String text,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiEndpoints.conversationMessages(threadId),
        data: {'text': text},
      );
      final map = _asMap(response.data);
      if (map == null) {
        return const ApiError(message: 'Unexpected response');
      }
      return ApiSuccess(
        ChatMessage.fromJson(map),
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<void>> markRead(String threadId) async {
    try {
      await _dio.post<dynamic>(ApiEndpoints.conversationRead(threadId));
      return const ApiSuccess(null);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  static List? _asList(dynamic data) => switch (data) {
    final List raw => raw,
    final Map map when map['data'] is List => map['data'] as List,
    _ => null,
  };

  static Map<String, dynamic>? _asMap(dynamic data) => switch (data) {
    final Map map when map['data'] is Map =>
      Map<String, dynamic>.from(map['data'] as Map),
    final Map map => Map<String, dynamic>.from(map),
    _ => null,
  };
}
