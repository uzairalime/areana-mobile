import '../../../core/config/app_config.dart';
import '../../../core/mock/mock_booking_data.dart';
import '../../../core/mock/mock_delay.dart';
import '../../../core/services/api_result.dart';
import '../model/booking_review_status.dart';
import '../model/user_booking.dart';
import 'bookings_client.dart';

class BookingsRepository {
  const BookingsRepository(this._client);

  final BookingsClient _client;

  Future<ApiResult<List<UserBooking>>> fetchBookings() {
    if (AppConfig.useMockApi) {
      return MockDelay.run(() => ApiSuccess(MockBookingData.myBookings));
    }
    return _client.fetchBookings();
  }

  Future<ApiResult<UserBooking>> submitReview({
    required String bookingId,
    required bool recommended,
  }) {
    if (AppConfig.useMockApi) {
      return MockDelay.run(() {
        MockBookingData.submitReview(
          bookingId: bookingId,
          recommended: recommended,
        );
        final booking = MockBookingData.bookingById(bookingId);
        if (booking == null) {
          return const ApiError(message: 'Booking not found');
        }
        return ApiSuccess(
          booking.copyWith(
            reviewStatus: recommended
                ? BookingReviewStatus.recommended
                : BookingReviewStatus.notRecommended,
          ),
        );
      });
    }
    return _client.submitReview(
      bookingId: bookingId,
      recommended: recommended,
    );
  }

  Future<ApiResult<UserBooking>> cancelBooking(String bookingId) {
    if (AppConfig.useMockApi) {
      return MockDelay.run(() {
        final updated = MockBookingData.cancel(bookingId);
        if (updated == null) {
          return const ApiError(message: 'Booking cannot be cancelled');
        }
        return ApiSuccess(updated);
      });
    }
    return _client.cancelBooking(bookingId);
  }
}
