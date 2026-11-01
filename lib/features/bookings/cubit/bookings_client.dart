import 'package:dio/dio.dart';

import '../../../core/consts/api_endpoints.dart';
import '../../../core/services/api_result.dart';
import '../../../core/services/pagination.dart';
import '../model/user_booking.dart';

class BookingsClient {
  const BookingsClient(this._dio);

  final Dio _dio;

  Future<ApiResult<OffsetPage<UserBooking>>> fetchBookings({
    String filter = 'upcoming',
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.bookingsMe,
        queryParameters: {'filter': filter, 'page': page, 'limit': limit},
      );
      final pageResult = parseOffsetPage(
        response.data,
        (e) => UserBooking.fromJson(Map<String, dynamic>.from(e as Map)),
      );
      return ApiSuccess(pageResult, statusCode: response.statusCode);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<UserBooking>> fetchBooking(String bookingId) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.booking(bookingId),
      );
      final map = _asMap(response.data);
      if (map == null) return const ApiError(message: 'Unexpected response');
      return ApiSuccess(
        UserBooking.fromJson(map),
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  /// One review per completed booking; the server rejects duplicates.
  Future<ApiResult<void>> submitReview({
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiEndpoints.reviews,
        data: {
          'bookingId': bookingId,
          'rating': rating,
          if (comment != null && comment.trim().isNotEmpty)
            'comment': comment.trim(),
        },
      );
      return ApiSuccess(null, statusCode: response.statusCode);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<UserBooking>> cancelBooking(String bookingId) async {
    try {
      final response = await _dio.patch<dynamic>(
        ApiEndpoints.bookingCancel(bookingId),
      );
      final map = _asMap(response.data);
      if (map == null) return const ApiError(message: 'Unexpected response');
      return ApiSuccess(
        UserBooking.fromJson(map),
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<void>> requestReschedule({
    required String bookingId,
    required String date,
    required int startMinutes,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiEndpoints.bookingReschedule(bookingId),
        data: {'date': date, 'startMinutes': startMinutes},
      );
      return ApiSuccess(null, statusCode: response.statusCode);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<void>> withdrawReschedule(String bookingId) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiEndpoints.bookingRescheduleWithdraw(bookingId),
      );
      return ApiSuccess(null, statusCode: response.statusCode);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  static Map<String, dynamic>? _asMap(dynamic data) => switch (data) {
    final Map map when map['data'] is Map =>
      Map<String, dynamic>.from(map['data'] as Map),
    final Map map => Map<String, dynamic>.from(map),
    _ => null,
  };
}
