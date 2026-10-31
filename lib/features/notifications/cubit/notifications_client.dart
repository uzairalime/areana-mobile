import 'package:dio/dio.dart';

import '../../../core/consts/api_endpoints.dart';
import '../../../core/services/api_result.dart';
import '../model/app_notification.dart';

class NotificationsClient {
  const NotificationsClient(this._dio);

  final Dio _dio;

  Future<ApiResult<List<AppNotification>>> fetchNotifications() async {
    try {
      final response = await _dio.get<dynamic>(ApiEndpoints.notifications);
      final list = _asList(response.data);
      if (list == null) {
        return const ApiError(message: 'Unexpected response');
      }
      final items = list
          .whereType<Map>()
          .map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return ApiSuccess(items, statusCode: response.statusCode);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<void>> markRead(String id) async {
    try {
      await _dio.post<dynamic>(ApiEndpoints.notificationRead(id));
      return const ApiSuccess(null);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<void>> markAllRead() async {
    try {
      await _dio.post<dynamic>(ApiEndpoints.notificationsReadAll);
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
}
