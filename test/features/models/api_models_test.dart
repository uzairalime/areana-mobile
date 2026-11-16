import 'package:arana360/features/booking/model/areana_booking.dart';
import 'package:arana360/features/auth/model/auth_session.dart';
import 'package:arana360/features/bookings/model/user_booking.dart';
import 'package:arana360/features/games/model/game_post.dart';
import 'package:arana360/features/home/model/areana_models.dart';
import 'package:arana360/features/home/model/venue.dart';
import 'package:arana360/features/profile/model/profile_stats.dart';
import 'package:arana360/features/profile/model/user_review.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> bookingJson({
  String date = '2026-11-16',
  String status = 'confirmed',
}) => {
  'id': 'booking-1',
  'venueId': 'venue-1',
  'courtId': 'court-1',
  'date': date,
  'startMinutes': 1080,
  'endMinutes': 1200,
  'totalPrice': '6000.00',
  'discountAmount': '500.00',
  'status': status,
  'checkInCode': 'CHECK-1',
  'shareCode': 'SHARE-1',
  'venue': {
    'name': 'Football Arena',
    'address': 'DHA',
    'city': 'Lahore',
    'lat': '31.4657',
    'lng': '74.415',
    'images': ['https://example.com/arena.jpg'],
  },
  'court': {'name': 'Turf A', 'sport': 'Football'},
};

void main() {
  test(
    'refresh parses camelCase tokens and retains persisted session keys',
    () {
      final session = AuthSession.fromJson({
        'accessToken': 'new-access-token',
        'refreshToken': 'new-refresh-token',
        'user': {'id': 'player-1', 'name': 'Ali', 'email': 'ali@example.com'},
      });
      expect(session.accessToken, 'new-access-token');
      expect(session.refreshToken, 'new-refresh-token');
      expect(session.user.id, 'player-1');
      final stored = session.toJson();
      expect(stored['access_token'], 'new-access-token');
      expect(stored['refresh_token'], 'new-refresh-token');
      expect(AuthSession.fromJson(stored), session);
      expect(
        AuthSession.fromJson({'token': 'legacy-access'}).accessToken,
        'legacy-access',
      );
    },
  );

  test('discovery models accept numeric strings and preserve card fields', () {
    final venue = AreanaVenue.fromJson({
      'id': 'venue-1',
      'name': 'Football Arena',
      'address': 'DHA',
      'city': 'Lahore',
      'sports': ['Football'],
      'fromPrice': '3000.75',
      'rating': '4.8',
      'ratingCount': '15',
      'lat': '31.4657',
      'lng': '74.415',
      '_count': {'courts': '2'},
    });
    final card = venue.toVenue();
    expect(card.priceFrom, 3000);
    expect(card.rating, 4.8);
    expect(card.reviewCount, 15);
    expect(card.hasCoordinates, isTrue);
    expect(card.courtsLabel, '2 courts');
    expect(card.location, 'DHA, Lahore');
    expect(AreanaVenue.fromJson(venue.toJson()), venue);

    final court = AreanaCourt.fromJson({
      'id': 'court-1',
      'pricePerHour': '3000.75',
      'slotMinutes': '60',
    });
    expect(court.pricePerHour, 3000);
    expect(court.slotMinutes, 60);
  });

  test('booking, promo and availability retain Decimal price parsing', () {
    final booking = BookingConfirmation.fromJson(bookingJson());
    expect(booking.amountDue, 6000);
    expect(booking.discountAmount, 500);
    expect(booking.slotCount, 2);
    expect(booking.timeLabel, '18:00 – 20:00');
    expect(booking.venueName, 'Football Arena');

    final promo = PromoPreview.fromJson({
      'promo': {'code': 'PLAY', 'kind': 'flat', 'value': '500.00'},
      'discount': '500.00',
    });
    expect(promo.discount, 500);
    expect(promo.value, 500);
    expect(promo.maxDiscount, isNull);

    final slot = AvailabilitySlot.fromJson({
      'startMinutes': '1080',
      'endMinutes': '1140',
      'price': '3000.00',
      'available': true,
    });
    expect(slot.price, 3000);
    expect(slot.label, '18:00 – 19:00');
    expect(slot.available, isTrue);
  });

  test('player booking handles Prisma DATE without falling back to now', () {
    final expected = DateTime(2026, 11, 16, 18);
    for (final date in [
      '2026-11-16',
      '2026-11-16T00:00:00.000Z',
      '2026-11-16T00:00:00+05:00',
    ]) {
      final booking = UserBooking.fromJson(bookingJson(date: date));
      expect(booking.occurredAt, expected);
      expect(booking.amountDue, 6000);
      expect(booking.venueLat, 31.4657);
      expect(booking.venueLng, 74.415);
      expect(booking.timeLabel, '18:00 – 20:00');
      expect(booking.canModify, isTrue);
    }
  });

  test('no-show bookings stay in past and cannot expose upcoming actions', () {
    final booking = UserBooking.fromJson(bookingJson(status: 'no_show'));
    expect(booking.status, UserBookingStatus.noShow);
    expect(booking.status.label, 'No show');
    expect(booking.status.apiValue, 'no_show');
    expect(booking.isPast, isTrue);
    expect(booking.isUpcoming, isFalse);
    expect(booking.canModify, isFalse);
    expect(booking.canAddReview, isFalse);
  });

  test('game prices and counts accept the same numeric payload variants', () {
    final game = GamePost.fromJson({
      'id': 'game-1',
      'startMinutes': '1080',
      'playersNeeded': '5',
      'pricePerPlayer': '600.50',
      'courtFee': '3000.00',
      'distanceKm': '2.5',
      '_count': {'participants': '4'},
    });
    expect(game.startMinutes, 1080);
    expect(game.playersNeeded, 5);
    expect(game.participantCount, 4);
    expect(game.pricePerPlayer, 600.5);
    expect(game.courtFee, 3000);
    expect(game.distanceKm, 2.5);
  });

  test('persisted venue and profile data accept Decimal strings safely', () {
    final venue = Venue.fromJson({
      'id': 'venue-1',
      'price_from': '3000.00',
      'rating': '4.8',
      'review_count': '15',
      'latitude': '31.4657',
      'longitude': '74.415',
    });
    expect(venue.priceFrom, 3000);
    expect(venue.rating, 4.8);
    expect(venue.hasCoordinates, isTrue);
    expect(Venue.fromJson(venue.toJson()), venue);
    expect(ProfileStats.fromJson({'hours_played': '12.0'}).hoursPlayed, 12);
    expect(UserReview.fromJson({'rating': '5'}).displayRating, 5);
  });
}
