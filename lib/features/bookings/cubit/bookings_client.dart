import 'package:dio/dio.dart';

import '../../../core/consts/api_endpoints.dart';
import '../../../core/services/api_result.dart';
import '../model/booking_review_status.dart';
import '../model/user_booking.dart';

class BookingsClient {
  const BookingsClient(this._dio);

  final Dio _dio;

  Future<ApiResult<List<UserBooking>>> fetchBookings() async {
    try {
      final response = await _dio.get<dynamic>(ApiEndpoints.myBookings);
      final list = _asList(response.data);
      if (list == null) {
        return const ApiError(message: 'Unexpected response');
      }
      final bookings = list
          .whereType<Map>()
          .map((e) => UserBooking.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return ApiSuccess(bookings, statusCode: response.statusCode);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<UserBooking>> submitReview({
    required String bookingId,
    required bool recommended,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiEndpoints.bookingReview(bookingId),
        data: {
          'recommended': recommended,
          'review_status': recommended
              ? BookingReviewStatus.recommended.apiValue
              : BookingReviewStatus.notRecommended.apiValue,
        },
      );
      final map = _asMap(response.data);
      if (map == null) {
        return const ApiError(message: 'Unexpected response');
      }
      return ApiSuccess(
        UserBooking.fromJson(map),
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<UserBooking>> cancelBooking(String bookingId) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiEndpoints.bookingCancel(bookingId),
      );
      final map = _asMap(response.data);
      if (map == null) {
        return const ApiError(message: 'Unexpected response');
      }
      return ApiSuccess(
        UserBooking.fromJson(map),
        statusCode: response.statusCode,
      );
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
