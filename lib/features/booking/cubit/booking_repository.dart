import '../../../core/config/app_config.dart';
import '../../../core/mock/mock_booking_data.dart';
import '../../../core/mock/mock_delay.dart';
import '../../../core/services/api_result.dart';
import '../../home/model/venue.dart';
import '../model/booking_confirmation.dart';
import '../model/booking_date.dart';
import '../model/court_option.dart';
import '../model/time_slot.dart';
import '../model/venue_availability.dart';
import 'booking_client.dart';

class BookingRepository {
  const BookingRepository(this._client);

  final BookingClient _client;

  Future<ApiResult<VenueAvailability>> fetchAvailability(Venue venue) {
    if (AppConfig.useMockApi) {
      return MockDelay.run(
        () => ApiSuccess(MockBookingData.availabilityFor(venue)),
      );
    }
    return _client.fetchAvailability(venue.id);
  }

  Future<ApiResult<BookingConfirmation>> confirmBooking({
    required Venue venue,
    required CourtOption court,
    required BookingDate date,
    required TimeSlot slot,
    required String duration,
    required bool payAtGround,
  }) {
    if (AppConfig.useMockApi) {
      return MockDelay.run(
        () => ApiSuccess(
          MockBookingData.confirm(
            venue: venue,
            court: court,
            date: date,
            slot: slot,
            duration: duration,
            payAtGround: payAtGround,
          ),
        ),
      );
    }
    return _client.createBooking({
      'venue_id': venue.id,
      'court_id': court.id,
      'date_id': date.id,
      'slot_id': slot.id,
      'duration': duration,
      'pay_at_ground': payAtGround,
    });
  }
}
