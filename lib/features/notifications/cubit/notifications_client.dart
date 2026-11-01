import 'package:dio/dio.dart';

import '../../../core/consts/api_endpoints.dart';
import '../../../core/services/api_result.dart';
import '../../../core/services/pagination.dart';
import '../model/app_notification.dart';

class NotificationsClient {
  const NotificationsClient(this._dio);

  final Dio _dio;

  /// Cursor-paged inbox, newest first (server order preserved).
  Future<ApiResult<CursorPage<AppNotification>>> fetchNotifications({
    String? cursor,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.notifications,
        queryParameters: {
          'limit': 30,
          if (cursor != null) 'cursor': cursor,
        },
      );
      final page = parseCursorPage(
        response.data,
        (json) => AppNotification.fromJson(json),
      );
      return ApiSuccess(page, statusCode: response.statusCode);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  /// Unread count. The exact response key is unverified in
  /// api-reference, so every plausible key is accepted.
  Future<ApiResult<int>> fetchUnreadCount() async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.notificationsUnreadCount,
      );
      final map = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : const <String, dynamic>{};
      for (final key in ['unreadCount', 'count', 'unread', 'total']) {
        final value = map[key];
        if (value is num) {
          return ApiSuccess(
            value.toInt(),
            statusCode: response.statusCode,
          );
        }
      }
      return const ApiError(message: 'Unexpected response');
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<void>> markRead(String id) async {
    try {
      await _dio.patch<dynamic>(ApiEndpoints.notificationRead(id));
      return const ApiSuccess(null);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<void>> markAllRead() async {
    try {
      await _dio.patch<dynamic>(ApiEndpoints.notificationsReadAll);
      return const ApiSuccess(null);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }
}
