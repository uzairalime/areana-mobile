import 'package:dio/dio.dart';

import '../../../core/consts/api_endpoints.dart';
import '../../../core/services/api_result.dart';
import '../model/booking_confirmation.dart';
import '../model/venue_availability.dart';

class BookingClient {
  const BookingClient(this._dio);

  final Dio _dio;

  Future<ApiResult<VenueAvailability>> fetchAvailability(String venueId) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.venueAvailability(venueId),
      );
      final data = response.data;
      if (data is! Map) {
        return const ApiError(message: 'Unexpected response');
      }
      return ApiSuccess(
        VenueAvailability.fromJson(Map<String, dynamic>.from(data)),
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
        ApiEndpoints.createBooking,
        data: body,
      );
      final data = response.data;
      if (data is! Map) {
        return const ApiError(message: 'Unexpected response');
      }
      return ApiSuccess(
        BookingConfirmation.fromJson(Map<String, dynamic>.from(data)),
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }
}
