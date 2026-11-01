import '../../../core/services/api_result.dart';
import '../../../core/services/pagination.dart';
import '../model/user_booking.dart';
import 'bookings_client.dart';

class BookingsRepository {
  const BookingsRepository(this._client);

  final BookingsClient _client;

  Future<ApiResult<OffsetPage<UserBooking>>> fetchBookings({
    String filter = 'upcoming',
    int page = 1,
    int limit = 20,
  }) => _client.fetchBookings(filter: filter, page: page, limit: limit);

  Future<ApiResult<UserBooking>> fetchBooking(String bookingId) =>
      _client.fetchBooking(bookingId);

  Future<ApiResult<void>> submitReview({
    required String bookingId,
    required int rating,
    String? comment,
  }) => _client.submitReview(
    bookingId: bookingId,
    rating: rating,
    comment: comment,
  );

  Future<ApiResult<UserBooking>> cancelBooking(String bookingId) =>
      _client.cancelBooking(bookingId);

  Future<ApiResult<void>> requestReschedule({
    required String bookingId,
    required String date,
    required int startMinutes,
  }) => _client.requestReschedule(
    bookingId: bookingId,
    date: date,
    startMinutes: startMinutes,
  );

  Future<ApiResult<void>> withdrawReschedule(String bookingId) =>
      _client.withdrawReschedule(bookingId);
}
