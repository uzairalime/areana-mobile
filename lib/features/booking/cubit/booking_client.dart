import 'package:dio/dio.dart';

import '../../../core/consts/api_endpoints.dart';
import '../../../core/services/api_result.dart';
import '../../../core/services/pagination.dart';
import '../../home/model/areana_models.dart';
import '../model/areana_booking.dart';

/// Booking client — the only booking file that imports Dio.
/// Court-first, like user-web: courts from the venue, slots from
/// `GET /courts/:id/availability?date=…`, promo via
/// `GET /bookings/validate-promo`, create via `POST /bookings`
/// (pay-at-venue; no online payment in the launch flow).
class BookingClient {
  const BookingClient(this._dio);

  final Dio _dio;

  Future<ApiResult<List<AreanaCourt>>> fetchVenueCourts(String venueId) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.venueCourts(venueId),
      );
      final page = parseOffsetPage(response.data, AreanaCourt.fromJson);
      return ApiSuccess(page.items, statusCode: response.statusCode);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<AvailabilityResponse>> fetchAvailability({
    required String courtId,
    required String date,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.courtAvailability(courtId),
        queryParameters: {'date': date},
      );
      final data = response.data;
      if (data is! Map) return const ApiError(message: 'Unexpected response');
      return ApiSuccess(
        AvailabilityResponse.fromJson(Map<String, dynamic>.from(data)),
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<PromoPreview>> validatePromo({
    required String code,
    required String courtId,
    required int slotCount,
    String? date,
    int? startMinutes,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.validatePromo,
        queryParameters: {
          'code': code,
          'courtId': courtId,
          'slotCount': slotCount,
          if (date != null && startMinutes != null) 'date': date,
          if (date != null && startMinutes != null) 'startMinutes': startMinutes,
        },
      );
      final data = response.data;
      if (data is! Map) return const ApiError(message: 'Unexpected response');
      return ApiSuccess(
        PromoPreview.fromJson(Map<String, dynamic>.from(data)),
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<BookingConfirmation>> createBooking(
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiEndpoints.bookings,
        data: body,
      );
      final data = response.data;
      if (data is! Map) return const ApiError(message: 'Unexpected response');
      return ApiSuccess(
        BookingConfirmation.fromJson(Map<String, dynamic>.from(data)),
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<ShareResult>> shareBooking(String bookingId) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiEndpoints.bookingShare(bookingId),
      );
      final data = response.data;
      if (data is! Map) return const ApiError(message: 'Unexpected response');
      return ApiSuccess(
        ShareResult.fromJson(Map<String, dynamic>.from(data)),
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }
}
