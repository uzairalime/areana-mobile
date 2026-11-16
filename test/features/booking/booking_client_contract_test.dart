import 'package:arana360/features/booking/cubit/booking_client.dart';
import 'package:arana360/features/bookings/cubit/bookings_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

Dio stubApi(
  List<RequestOptions> requests,
  Object? Function(RequestOptions request) respond,
) {
  return Dio(BaseOptions(baseUrl: 'https://example.test/api/'))
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) {
          requests.add(request);
          handler.resolve(
            Response<dynamic>(
              requestOptions: request,
              statusCode: 200,
              data: respond(request),
            ),
          );
        },
      ),
    );
}

void main() {
  test(
    'court and availability requests preserve endpoint/query contracts',
    () async {
      final requests = <RequestOptions>[];
      final dio = stubApi(requests, (request) {
        if (request.path == 'venues/venue-1/courts') {
          return [
            {'id': 'court-1', 'pricePerHour': '3000.00', 'slotMinutes': 60},
          ];
        }
        return {
          'courtId': 'court-1',
          'venueId': 'venue-1',
          'date': '2026-11-17',
          'slots': [
            {
              'startMinutes': 1080,
              'endMinutes': 1140,
              'price': '3000.00',
              'available': true,
            },
          ],
        };
      });
      addTearDown(dio.close);
      final client = BookingClient(dio);
      final courts = await client.fetchVenueCourts('venue-1');
      final availability = await client.fetchAvailability(
        courtId: 'court-1',
        date: '2026-11-17',
      );
      expect(courts.dataOrNull!.single.pricePerHour, 3000);
      expect(availability.dataOrNull!.slots.single.price, 3000);
      expect(requests.map((request) => request.method), ['GET', 'GET']);
      expect(requests.last.path, 'courts/court-1/availability');
      expect(requests.last.queryParameters, {'date': '2026-11-17'});
    },
  );

  test(
    'promo remains a GET query and create retains its exact POST body',
    () async {
      final requests = <RequestOptions>[];
      final dio = stubApi(requests, (request) {
        if (request.path == 'bookings/validate-promo') {
          return {
            'promo': {'code': 'PLAY', 'kind': 'flat', 'value': '500.00'},
            'discount': '500.00',
          };
        }
        return {
          'id': 'booking-1',
          'venueId': 'venue-1',
          'courtId': 'court-1',
          'date': '2026-11-17',
          'startMinutes': 1080,
          'endMinutes': 1200,
          'totalPrice': '5500.00',
          'discountAmount': '500.00',
          'status': 'pending',
        };
      });
      addTearDown(dio.close);
      final client = BookingClient(dio);
      final promo = await client.validatePromo(
        code: 'PLAY',
        courtId: 'court-1',
        slotCount: 2,
        date: '2026-11-17',
        startMinutes: 1080,
      );
      final body = {
        'courtId': 'court-1',
        'date': '2026-11-17',
        'startMinutes': 1080,
        'slotCount': 2,
        'promoCode': 'PLAY',
      };
      final created = await client.createBooking(body);
      expect(promo.dataOrNull!.discount, 500);
      expect(requests.first.method, 'GET');
      expect(requests.first.data, isNull);
      expect(requests.first.queryParameters, {
        'code': 'PLAY',
        'courtId': 'court-1',
        'slotCount': 2,
        'date': '2026-11-17',
        'startMinutes': 1080,
      });
      expect(requests.last.method, 'POST');
      expect(requests.last.path, 'bookings');
      expect(requests.last.data, body);
      expect(created.dataOrNull!.totalPrice, 5500);
      expect(created.dataOrNull!.slotCount, 2);
    },
  );

  test(
    'cancellation and reschedule preserve their different HTTP methods',
    () async {
      final requests = <RequestOptions>[];
      final dio = stubApi(
        requests,
        (_) => {
          'id': 'booking-1',
          'date': '2026-11-17T00:00:00.000Z',
          'startMinutes': 1080,
          'endMinutes': 1140,
          'totalPrice': '3000.00',
          'status': 'cancelled',
        },
      );
      addTearDown(dio.close);
      final client = BookingsClient(dio);
      final cancelled = await client.cancelBooking('booking-1');
      await client.requestReschedule(
        bookingId: 'booking-1',
        date: '2026-11-18',
        startMinutes: 1140,
      );
      expect(cancelled.dataOrNull!.canModify, isFalse);
      expect(requests.first.method, 'PATCH');
      expect(requests.first.path, 'bookings/booking-1/cancel');
      expect(requests.last.method, 'POST');
      expect(requests.last.path, 'bookings/booking-1/reschedule');
      expect(requests.last.data, {'date': '2026-11-18', 'startMinutes': 1140});
    },
  );
}
