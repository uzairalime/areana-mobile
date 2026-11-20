import 'package:arana360/core/consts/app_colors.dart';
import 'package:arana360/core/enums/app_loading.dart';
import 'package:arana360/core/services/locator.dart';
import 'package:arana360/core/services/session_cubit.dart';
import 'package:arana360/core/services/session_state.dart';
import 'package:arana360/core/services/session_store.dart';
import 'package:arana360/core/widgets/pagination_loader.dart';
import 'package:arana360/features/auth/model/user_model.dart';
import 'package:arana360/features/booking/widgets/court_hero_canvas.dart';
import 'package:arana360/features/bookings/model/user_booking.dart';
import 'package:arana360/features/bookings/widgets/booking_status_chip.dart';
import 'package:arana360/features/bookings/widgets/past_booking_tile.dart';
import 'package:arana360/features/bookings/widgets/upcoming_featured_card.dart';
import 'package:arana360/features/bookings/widgets/upcoming_timeline_tile.dart';
import 'package:arana360/features/home/cubit/home_client.dart';
import 'package:arana360/features/home/cubit/home_cubit.dart';
import 'package:arana360/features/home/cubit/home_repository.dart';
import 'package:arana360/features/home/cubit/home_state.dart';
import 'package:arana360/features/home/widgets/home_body.dart';
import 'package:arana360/features/profile/cubit/profile_client.dart';
import 'package:arana360/features/profile/cubit/profile_cubit.dart';
import 'package:arana360/features/profile/cubit/profile_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

class _Session extends SessionCubit {
  _Session() : super(SessionStore());

  void signIn(String id) {
    emit(
      SessionState(
        accessToken: 'test-token',
        user: UserModel(id: id, name: 'Test', email: 'test@example.com'),
      ),
    );
  }
}

class _Home extends HomeCubit {
  _Home() : super(HomeRepository(HomeClient(Dio()))) {
    emit(const HomeState(status: AppLoading.error, errorMessage: 'Offline'));
  }

  @override
  Future<void> load() async {}
}

class _Profile extends ProfileCubit {
  _Profile(SessionCubit session)
    : super(ProfileRepository(ProfileClient(Dio()), session), session);

  var hydrationCalls = 0;

  @override
  Future<void> ensureSavedVenueIds() async {
    hydrationCalls++;
    emit(state.copyWith(savedVenueIds: ['saved-$hydrationCalls']));
  }

  @override
  Future<void> ensureLoaded() async {}
}

void main() {
  testWidgets('home hydrates favorites outside build and after user changes', (
    tester,
  ) async {
    final session = _Session();
    final home = _Home();
    final profile = _Profile(session);
    getIt.registerSingleton<ProfileCubit>(profile);
    addTearDown(() => getIt.unregister<ProfileCubit>());
    addTearDown(profile.close);
    addTearDown(home.close);
    addTearDown(session.close);
    late StateSetter rebuild;
    await _pump(
      tester,
      MultiBlocProvider(
        providers: [
          BlocProvider<SessionCubit>.value(value: session),
          BlocProvider<HomeCubit>.value(value: home),
        ],
        child: StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return HomeBody(key: ValueKey(home));
          },
        ),
      ),
    );
    expect(profile.hydrationCalls, 1);
    rebuild(() {});
    await tester.pump();
    expect(profile.hydrationCalls, 1);
    session.signIn('player-1');
    await tester.pumpAndSettle();
    expect(profile.hydrationCalls, 2);
    session.signIn('player-2');
    await tester.pumpAndSettle();
    expect(profile.hydrationCalls, 3);
    expect(tester.takeException(), isNull);
  });

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

  testWidgets('a failed page has an explicit retry without an automatic loop', (
    tester,
  ) async {
    var calls = 0;
    await _pump(
      tester,
      PaginationLoader(
        pageKey: 'page-2',
        errorMessage: 'Connection failed',
        onLoadMore: () => calls++,
      ),
    );
    expect(calls, 0);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.tap(find.text('Retry loading more'));
    await tester.pump();
    expect(calls, 1);
    expect(tester.takeException(), isNull);
  });

  final cards = <(String, Widget Function(VoidCallback), double)>[
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
