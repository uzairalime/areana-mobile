import 'package:dio/dio.dart';

import '../../../core/consts/api_endpoints.dart';
import '../../../core/services/api_result.dart';
import '../../../core/services/pagination.dart';
import '../model/conversation_models.dart';

class ConversationsClient {
  const ConversationsClient(this._dio);

  final Dio _dio;

  Future<ApiResult<CursorPage<ConversationThread>>> fetchThreads({
    String? cursor,
    String? q,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.conversations,
        queryParameters: {
          'limit': 30,
          'cursor': ?cursor,
          if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
        },
      );
      return ApiSuccess(
        parseCursorPage(response.data, ConversationThread.fromJson),
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<ConversationThread>> openThread({
    required String venueId,
    String? bookingId,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiEndpoints.conversations,
        data: {
          'venueId': venueId,
          'bookingId': ?bookingId,
        },
      );
      final data = response.data;
      if (data is! Map) return const ApiError(message: 'Unexpected response');
      return ApiSuccess(
        ConversationThread.fromJson(Map<String, dynamic>.from(data)),
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<ConversationThread>> fetchThread(String id) async {
    try {
      final response = await _dio.get<dynamic>(ApiEndpoints.conversation(id));
      final data = response.data;
      if (data is! Map) return const ApiError(message: 'Unexpected response');
      return ApiSuccess(
        ConversationThread.fromJson(Map<String, dynamic>.from(data)),
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<CursorPage<ChatMessage>>> fetchMessages({
    required String conversationId,
    String? cursor,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.conversationMessages(conversationId),
        queryParameters: {
          'limit': 40,
          'cursor': ?cursor,
        },
      );
      return ApiSuccess(
        parseCursorPage(response.data, ChatMessage.fromJson),
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<ChatMessage>> sendMessage({
    required String conversationId,
    required String body,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiEndpoints.conversationMessages(conversationId),
        data: {'body': body},
      );
      final data = response.data;
      if (data is! Map) return const ApiError(message: 'Unexpected response');
      return ApiSuccess(
        ChatMessage.fromJson(Map<String, dynamic>.from(data)),
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<void>> markRead(String conversationId) async {
    try {
      await _dio.patch<dynamic>(ApiEndpoints.conversationRead(conversationId));
      return const ApiSuccess(null);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }
}
