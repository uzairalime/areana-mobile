import 'package:arana360/core/consts/app_colors.dart';
import 'package:arana360/features/home/model/areana_models.dart';
import 'package:arana360/features/home/model/venue.dart';
import 'package:arana360/features/home/widgets/venue_card.dart';
import 'package:arana360/features/home/widgets/venue_detail_sections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Venue _venue({double rating = 0, int reviewCount = 0}) => Venue(
  id: 'venue-1',
  name: 'Squash Court 10',
  sport: 'Squash',
  location: '21 Sports Lane, Lahore',
  priceFrom: 2500,
  amenities: const ['Parking', 'Floodlights'],
  nextSlot: 'Today 4:00 PM',
  heroColor: AppColors.primary,
  rating: rating,
  reviewCount: reviewCount,
);

AreanaReview _review(String id) => AreanaReview(
  id: id,
  rating: 5,
  comment: 'Great court $id',
  createdAt: '2026-11-20T10:00:00.000Z',
  userName: 'Player $id',
);

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}

void main() {
  testWidgets('venue card drops next-free-slot and shows rating when present', (
    tester,
  ) async {
    await _pump(
      tester,
      VenueCard(
        venue: _venue(rating: 4.5, reviewCount: 21),
        onOpen: () {},
        onBook: () {},
        showFavorite: false,
      ),
    );
    expect(find.text('Next free slot'), findsNothing);
    expect(find.text('Today 4:00 PM'), findsNothing);
    expect(find.text('Book slot'), findsOneWidget);
    expect(find.text('4.5'), findsOneWidget);
    expect(find.text('(21 reviews)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('venue card hides rating when the venue has none', (
    tester,
  ) async {
    await _pump(
      tester,
      VenueCard(
        venue: _venue(),
        onOpen: () {},
        onBook: () {},
        showFavorite: false,
      ),
    );
    expect(find.textContaining('reviews'), findsNothing);
    expect(find.text('Book slot'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reviews preview shows four items then see more', (tester) async {
    var taps = 0;
    await _pump(
      tester,
      VenueReviewsSection(
        reviews: [
          _review('1'),
          _review('2'),
          _review('3'),
          _review('4'),
          _review('5'),
        ],
        hasMore: true,
        reviewCount: 21,
        onSeeMore: () => taps++,
      ),
    );
    expect(find.text('Great court 1'), findsOneWidget);
    expect(find.text('Great court 4'), findsOneWidget);
    expect(find.text('Great court 5'), findsNothing);
    expect(find.text('See more reviews'), findsOneWidget);
    await tester.tap(find.text('See more reviews'));
    expect(taps, 1);
    expect(tester.takeException(), isNull);
  });
}
