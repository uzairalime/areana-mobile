import '../../../core/services/api_result.dart';
import '../../home/model/areana_models.dart';
import '../model/areana_booking.dart';
import 'booking_client.dart';

class BookingRepository {
  const BookingRepository(this._client);

  final BookingClient _client;

  Future<ApiResult<List<AreanaCourt>>> fetchVenueCourts(String venueId) =>
      _client.fetchVenueCourts(venueId);

  Future<ApiResult<AvailabilityResponse>> fetchAvailability({
    required String courtId,
    required String date,
  }) =>
      _client.fetchAvailability(courtId: courtId, date: date);

  Future<ApiResult<PromoPreview>> validatePromo({
    required String code,
    required String courtId,
    required int slotCount,
    String? date,
    int? startMinutes,
  }) =>
      _client.validatePromo(
        code: code,
        courtId: courtId,
        slotCount: slotCount,
        date: date,
        startMinutes: startMinutes,
      );

  Future<ApiResult<BookingConfirmation>> confirmBooking({
    required String courtId,
    required String date,
    required int startMinutes,
    required int slotCount,
    String? promoCode,
    int? expectedTotal,
  }) =>
      _client.createBooking({
        'courtId': courtId,
        'date': date,
        'startMinutes': startMinutes,
        'slotCount': slotCount,
        if (promoCode != null && promoCode.isNotEmpty) 'promoCode': promoCode,
        if (expectedTotal != null) 'expectedTotal': expectedTotal,
      });

  Future<ApiResult<ShareResult>> shareBooking(String bookingId) =>
      _client.shareBooking(bookingId);
}
