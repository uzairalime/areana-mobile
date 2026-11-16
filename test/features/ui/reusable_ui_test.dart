import 'package:arana360/core/consts/app_colors.dart';
import 'package:arana360/core/widgets/pagination_loader.dart';
import 'package:arana360/features/booking/widgets/court_hero_canvas.dart';
import 'package:arana360/features/bookings/model/user_booking.dart';
import 'package:arana360/features/bookings/widgets/booking_list_tile.dart';
import 'package:arana360/features/bookings/widgets/booking_status_chip.dart';
import 'package:arana360/features/bookings/widgets/past_booking_tile.dart';
import 'package:arana360/features/bookings/widgets/upcoming_featured_card.dart';
import 'package:arana360/features/bookings/widgets/upcoming_timeline_tile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

UserBooking _booking({UserBookingStatus status = UserBookingStatus.confirmed}) {
  return UserBooking(
    id: 'booking-1',
    code: 'BK-001',
    venueId: 'venue-1',
    venueName: 'Test Arena',
    sport: 'Football',
    location: 'Lahore',
    dateLabel: 'Tomorrow',
    timeLabel: '18:00–19:00',
    courtLabel: 'Turf A',
    durationLabel: '1 hour',
    amountDue: 3000,
    status: status,
    heroColor: AppColors.primary,
    occurredAt: DateTime(2026, 11, 17, 18),
    imageUrl: '   ',
  );
}

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 20, height: 1.2),
          titleSmall: TextStyle(fontSize: 15, height: 1.2),
          labelLarge: TextStyle(fontSize: 14, height: 1.2),
          labelMedium: TextStyle(fontSize: 12, height: 1.2),
          labelSmall: TextStyle(fontSize: 11, height: 1.2),
        ),
      ),
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  testWidgets('pagination requests after layout and only once per cursor', (
    tester,
  ) async {
    var calls = 0;
    var cursor = 'page-2';
    late StateSetter update;
    await _pump(
      tester,
      StatefulBuilder(
        builder: (context, setState) {
          update = setState;
          return PaginationLoader(
            pageKey: cursor,
            onLoadMore: () => setState(() => calls++),
          );
        },
      ),
    );
    expect(calls, 1);
    await tester.pump();
    expect(calls, 1);
    expect(tester.takeException(), isNull);

    update(() => cursor = 'page-3');
    await tester.pump();
    expect(calls, 2);
    await tester.pump();
    expect(calls, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pagination waits for an active request before loading again', (
    tester,
  ) async {
    var calls = 0;
    var enabled = false;
    late StateSetter update;
    await _pump(
      tester,
      StatefulBuilder(
        builder: (context, setState) {
          update = setState;
          return PaginationLoader(
            pageKey: 'page-2',
            enabled: enabled,
            onLoadMore: () => calls++,
          );
        },
      ),
    );
    expect(calls, 0);
    update(() => enabled = true);
    await tester.pump();
    expect(calls, 1);
    update(() => enabled = false);
    await tester.pump();
    update(() => enabled = true);
    await tester.pump();
    expect(
      calls,
      1,
      reason: 'A failed page must not cause an automatic retry loop.',
    );
    expect(tester.takeException(), isNull);
  });

  final cards = <(String, Widget Function(VoidCallback), double)>[
    (
      'booking list',
      (onTap) => BookingListTile(booking: _booking(), onTap: onTap),
      BookingListTile.height,
    ),
    (
      'featured booking',
      (onTap) => UpcomingFeaturedCard(booking: _booking(), onTap: onTap),
      220,
    ),
    (
      'timeline booking',
      (onTap) =>
          UpcomingTimelineTile(booking: _booking(), isLast: true, onTap: onTap),
      56,
    ),
    (
      'past booking',
      (onTap) => PastBookingTile(
        booking: _booking(status: UserBookingStatus.noShow),
        onTap: onTap,
        onRebook: () {},
      ),
      64,
    ),
  ];

  for (final (name, build, imageHeight) in cards) {
    testWidgets('$name keeps its fallback image and tap callback', (
      tester,
    ) async {
      var taps = 0;
      await _pump(tester, SizedBox(width: 400, child: build(() => taps++)));
      expect(find.byType(CourtHeroCanvas), findsOneWidget);
      expect(tester.getSize(find.byType(CourtHeroCanvas)).height, imageHeight);
      await tester.tap(find.text('Test Arena'));
      await tester.pump();
      expect(taps, 1);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('no-show booking displays its status without a review action', (
    tester,
  ) async {
    await _pump(
      tester,
      SizedBox(
        width: 400,
        child: PastBookingTile(
          booking: _booking(status: UserBookingStatus.noShow),
          onTap: () {},
          onRebook: () {},
          onAddReview: () {},
        ),
      ),
    );
    expect(find.text('No show'), findsOneWidget);
    expect(find.text('Write review'), findsNothing);
    expect(find.text('Add review'), findsNothing);
    expect(tester.takeException(), isNull);

    await _pump(
      tester,
      const BookingStatusChip(status: UserBookingStatus.noShow),
    );
    expect(find.text('No show'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
