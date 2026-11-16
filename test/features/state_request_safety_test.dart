import 'dart:async';

import 'package:arana360/core/enums/app_loading.dart';
import 'package:arana360/core/services/api_result.dart';
import 'package:arana360/core/services/notification/notification_service.dart';
import 'package:arana360/core/services/recent_search_store.dart';
import 'package:arana360/core/services/session_cubit.dart';
import 'package:arana360/core/services/session_state.dart';
import 'package:arana360/core/services/session_store.dart';
import 'package:arana360/features/auth/cubit/auth_client.dart';
import 'package:arana360/features/auth/cubit/auth_cubit.dart';
import 'package:arana360/features/auth/cubit/auth_repository.dart';
import 'package:arana360/features/auth/model/auth_session.dart';
import 'package:arana360/features/auth/model/otp_models.dart';
import 'package:arana360/features/auth/model/user_model.dart';
import 'package:arana360/features/booking/cubit/booking_client.dart';
import 'package:arana360/features/booking/cubit/booking_cubit.dart';
import 'package:arana360/features/booking/cubit/booking_repository.dart';
import 'package:arana360/features/bookings/cubit/bookings_client.dart';
import 'package:arana360/features/bookings/cubit/bookings_cubit.dart';
import 'package:arana360/features/bookings/cubit/bookings_repository.dart';
import 'package:arana360/features/games/cubit/games_client.dart';
import 'package:arana360/features/games/cubit/games_cubit.dart';
import 'package:arana360/features/games/cubit/games_repository.dart';
import 'package:arana360/features/home/cubit/home_client.dart';
import 'package:arana360/features/home/cubit/home_cubit.dart';
import 'package:arana360/features/home/cubit/home_repository.dart';
import 'package:arana360/features/home/model/venue.dart';
import 'package:arana360/features/notifications/cubit/notifications_client.dart';
import 'package:arana360/features/notifications/cubit/notifications_cubit.dart';
import 'package:arana360/features/notifications/cubit/notifications_repository.dart';
import 'package:arana360/features/notifications/model/notification_type.dart';
import 'package:arana360/features/profile/cubit/profile_client.dart';
import 'package:arana360/features/profile/cubit/profile_cubit.dart';
import 'package:arana360/features/profile/cubit/profile_repository.dart';
import 'package:arana360/features/search/cubit/search_client.dart';
import 'package:arana360/features/search/cubit/search_cubit.dart';
import 'package:arana360/features/search/cubit/search_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Every request stops at the interceptor. No test can contact a real backend.
class _Api {
  _Api() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          pending.add(_Request(options, handler));
        },
      ),
    );
  }

  final dio = Dio(BaseOptions(baseUrl: 'https://audit.invalid/api/'));
  final pending = <_Request>[];

  Future<_Request> take(String path) async {
    for (var i = 0; i < 100; i++) {
      final index = pending.indexWhere(
        (request) => request.options.path == path,
      );
      if (index >= 0) return pending.removeAt(index);
      await Future<void>.delayed(Duration.zero);
    }
    throw StateError('No queued request for $path');
  }
}

class _Request {
  _Request(this.options, this.handler);
  final RequestOptions options;
  final RequestInterceptorHandler handler;

  void respond(Object? data) => handler.resolve(
    Response<dynamic>(requestOptions: options, statusCode: 200, data: data),
  );
}

class _Notifications extends NotificationService {
  @override
  Future<void> show({
    required NotificationType type,
    required String title,
    required String body,
    String? link,
    String? id,
    int? notificationId,
  }) async {}
}

class _Session extends SessionCubit {
  _Session() : super(SessionStore());
  void signIn(String id) => emit(
    SessionState(
      accessToken: 'test-token',
      user: UserModel(id: id, name: 'Player', email: '$id@example.com'),
    ),
  );
}

class _AuthRepository extends AuthRepository {
  _AuthRepository() : super(AuthClient(Dio()), _Session(), SessionStore());
  final persistence = Completer<ApiResult<AuthSession>>();

  @override
  Future<ApiResult<OtpVerifyResponse>> verifyOtp({
    required String email,
    required String code,
    String? name,
    String? phone,
    String? city,
    String? referralCode,
  }) async => ApiSuccess(
    OtpVerifyResponse.fromJson({
      'accessToken': 'access',
      'refreshToken': 'refresh',
      'user': {'id': 'player', 'email': email, 'name': 'Player'},
    }),
  );

  @override
  Future<ApiResult<AuthSession>> persistVerify(OtpVerifyResponse verify) =>
      persistence.future;
}

Map<String, dynamic> _court(String id) => {
  'id': id,
  'venueId': 'venue',
  'name': id,
  'sport': 'Football',
  'slotMinutes': 60,
  'pricePerHour': '3000',
};

Map<String, dynamic> _slots(String id, {int start = 600}) => {
  'courtId': id,
  'venueId': 'venue',
  'date': '2026-11-17',
  'slots': [
    for (var i = 0; i < 3; i++)
      {
        'startMinutes': start + i * 60,
        'endMinutes': start + (i + 1) * 60,
        'available': true,
        'price': '3000',
      },
  ],
};

Venue _venue(String id) => Venue(
  id: id,
  name: id,
  sport: 'Football',
  location: 'Lahore',
  priceFrom: 3000,
  amenities: const [],
  nextSlot: '',
  heroColor: Colors.green,
);

Map<String, dynamic> _page(
  List<Map<String, dynamic>> items, {
  int page = 1,
  bool more = false,
}) => {
  'items': items,
  'total': more ? 100 : items.length,
  'page': page,
  'limit': 20,
  'hasMore': more,
};

Future<void> _startBooking(_Api api, BookingCubit cubit) async {
  final start = cubit.start(_venue('venue'));
  (await api.take('venues/venue/courts'))
      .respond([_court('one'), _court('two')]);
  (await api.take('courts/one/availability')).respond(_slots('one'));
  await start;
}

Future<void> _flush() => Future<void>.delayed(Duration.zero);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (_) async => null);
  });

  test('booking ignores availability for an older court selection', () async {
    final api = _Api();
    final cubit = BookingCubit(
      BookingRepository(BookingClient(api.dio)),
      _Notifications(),
    );
    addTearDown(cubit.close);
    await _startBooking(api, cubit);
    final first = cubit.selectCourt('two');
    final stale = await api.take('courts/two/availability');
    final second = cubit.selectCourt('one');
    (await api.take('courts/one/availability'))
        .respond(_slots('one', start: 900));
    await second;
    stale.respond(_slots('two', start: 600));
    await first;
    expect(cubit.state.selectedCourtId, 'one');
    expect(cubit.state.slots.first.startMinutes, 900);
  });

  test(
    'starting another venue ignores the older venue court response',
    () async {
      final api = _Api();
      final cubit = BookingCubit(
        BookingRepository(BookingClient(api.dio)),
        _Notifications(),
      );
      addTearDown(cubit.close);
      final old = cubit.start(_venue('old'));
      final oldRequest = await api.take('venues/old/courts');
      final current = cubit.start(_venue('new'));
      (await api.take('venues/new/courts')).respond([_court('new-court')]);
      (await api.take('courts/new-court/availability'))
          .respond(_slots('new-court'));
      await current;
      oldRequest.respond([_court('old-court')]);
      await old;
      expect(cubit.state.venue?.id, 'new');
      expect(cubit.state.selectedCourtId, 'new-court');
    },
  );

  test(
    'promo responses and discounts are invalidated by slot changes',
    () async {
      final api = _Api();
      final cubit = BookingCubit(
        BookingRepository(BookingClient(api.dio)),
        _Notifications(),
      );
      addTearDown(cubit.close);
      await _startBooking(api, cubit);
      cubit.selectSlot(600);
      cubit.setPromoCode('SAVE');
      final validation = cubit.validatePromo();
      final request = await api.take('bookings/validate-promo');
      cubit.selectSlot(660);
      request.respond({
        'promo': {'code': 'SAVE', 'kind': 'flat', 'value': 500},
        'discount': 500,
      });
      await validation;
      expect(cubit.state.promo, isNull);
      expect(cubit.state.total, 3000);
      expect(cubit.state.promoStatus, AppLoading.initial);
    },
  );

  test(
    'duplicate confirm sends one booking and preserves price guard payload',
    () async {
      final api = _Api();
      final cubit = BookingCubit(
        BookingRepository(BookingClient(api.dio)),
        _Notifications(),
      );
      addTearDown(cubit.close);
      await _startBooking(api, cubit);
      cubit.selectSlot(600);
      cubit.selectSlotCount(2);
      final confirmation = cubit.confirmBooking();
      final request = await api.take('bookings');
      expect(await cubit.confirmBooking(), isFalse);
      expect(request.options.data, containsPair('expectedTotal', 6000));
      expect(request.options.data, containsPair('slotCount', 2));
      cubit.selectSlot(660);
      expect(cubit.state.selectedStartMinutes, 600);
      request.respond({
        'id': 'booking',
        'courtId': 'one',
        'venueId': 'venue',
        'date': '2026-11-17',
        'startMinutes': 600,
        'endMinutes': 720,
        'totalPrice': '6000',
        'status': 'pending',
      });
      expect(await confirmation, isTrue);
      expect(api.pending, isEmpty);
    },
  );

  test('clearing search invalidates in-flight results immediately', () async {
    final api = _Api();
    final cubit = SearchCubit(
      SearchRepository(SearchClient(api.dio), RecentSearchStore()),
    );
    addTearDown(cubit.close);
    cubit.onQueryChanged('old');
    final search = cubit.search('old');
    final request = await api.take('venues');
    cubit.onQueryChanged('');
    request.respond(
      _page([
        {
          'id': 'old',
          'name': 'Old',
          'sports': ['Football'],
        },
      ]),
    );
    await search;
    expect(cubit.state.query, isEmpty);
    expect(cubit.state.venues, isEmpty);
    expect(cubit.state.showIdle, isTrue);
  });

  test(
    'typing a new query discards old results before debounce fires',
    () async {
      final api = _Api();
      final cubit = SearchCubit(
        SearchRepository(SearchClient(api.dio), RecentSearchStore()),
      );
      addTearDown(cubit.close);
      final search = cubit.search('old');
      final request = await api.take('venues');
      cubit.onQueryChanged('new');
      request.respond(
        _page([
          {'id': 'old', 'name': 'Old'},
        ]),
      );
      await search;
      expect(cubit.state.query, 'new');
      expect(cubit.state.venues, isEmpty);
    },
  );

  test(
    'home keeps the latest sport response when requests finish out of order',
    () async {
      final api = _Api();
      final cubit = HomeCubit(HomeRepository(HomeClient(api.dio)));
      addTearDown(cubit.close);
      for (final path in ['sports', 'venues/cities', 'banners']) {
        (await api.take(path)).respond([]);
      }
      (await api.take('venues')).respond(_page([]));
      await _flush();
      final first = cubit.selectSport('Football');
      final old = await api.take('venues');
      final latest = cubit.selectSport('Padel');
      final current = await api.take('venues');
      expect(current.options.queryParameters['sport'], 'Padel');
      current.respond(
        _page([
          {
            'id': 'new',
            'name': 'New',
            'sports': ['Padel'],
          },
        ]),
      );
      await latest;
      old.respond(
        _page([
          {'id': 'old', 'name': 'Old'},
        ]),
      );
      await first;
      expect(cubit.state.venues.single.id, 'new');
    },
  );

  test('games discard an old appended page after refresh', () async {
    final api = _Api();
    final cubit = GamesCubit(
      GamesRepository(GamesClient(api.dio), BookingsClient(api.dio)),
    );
    addTearDown(cubit.close);
    (await api.take('game-posts')).respond(
      _page([
        {'id': 'old'},
      ], more: true),
    );
    await _flush();
    final append = cubit.loadMore();
    final stale = await api.take('game-posts');
    final refresh = cubit.refresh();
    (await api.take('game-posts')).respond(
      _page([
        {'id': 'current'},
      ]),
    );
    await refresh;
    stale.respond(
      _page([
        {'id': 'stale-page'},
      ], page: 2),
    );
    await append;
    expect(cubit.state.games.map((game) => game.id), ['current']);
    expect(cubit.state.isLoadingMore, isFalse);
  });

  test(
    'notifications clear the old cursor and ignore stale pagination',
    () async {
      final api = _Api();
      final cubit = NotificationsCubit(
        NotificationsRepository(NotificationsClient(api.dio)),
      );
      addTearDown(cubit.close);
      (await api.take('notifications')).respond({
        'items': [
          {'id': 'old'},
        ],
        'nextCursor': 'older',
      });
      await _flush();
      final append = cubit.loadMore();
      final stale = await api.take('notifications');
      final refresh = cubit.refresh();
      (await api.take('notifications')).respond({
        'items': [
          {'id': 'current'},
        ],
        'nextCursor': null,
      });
      await refresh;
      stale.respond({
        'items': [
          {'id': 'stale-page'},
        ],
        'nextCursor': null,
      });
      await append;
      expect(cubit.state.items.map((item) => item.id), ['current']);
      expect(cubit.state.nextCursor, isNull);
      expect(cubit.state.isLoadingMore, isFalse);
    },
  );

  test('booking list discards an appended page after refresh', () async {
    final api = _Api();
    final cubit = BookingsCubit(BookingsRepository(BookingsClient(api.dio)));
    addTearDown(cubit.close);
    (await api.take('bookings/me')).respond(
      _page([
        {'id': 'old'},
      ], more: true),
    );
    await _flush();
    final append = cubit.loadMore();
    final stale = await api.take('bookings/me');
    final refresh = cubit.refresh();
    (await api.take('bookings/me')).respond(
      _page([
        {'id': 'current'},
      ]),
    );
    await refresh;
    stale.respond(
      _page([
        {'id': 'stale-page'},
      ], page: 2),
    );
    await append;
    expect(cubit.state.bookings.map((booking) => booking.id), ['current']);
    expect(cubit.state.isLoadingMore, isFalse);
  });

  test(
    'favorites hydration is single flight and preserves optimistic saves',
    () async {
      final api = _Api();
      final session = _Session()..signIn('player');
      final cubit = ProfileCubit(
        ProfileRepository(ProfileClient(api.dio), session),
        session,
      );
      addTearDown(cubit.close);
      addTearDown(session.close);
      final hydration = cubit.ensureSavedVenueIds();
      final request = await api.take('favorites');
      await cubit.ensureSavedVenueIds();
      expect(api.pending, isEmpty);
      final save = cubit.saveVenue('local-save');
      (await api.take('favorites')).respond({});
      expect(await save, isTrue);
      request.respond({
        'items': [
          {
            'venue': {'id': 'server-save'},
          },
        ],
        'nextCursor': null,
      });
      await hydration;
      expect(
        cubit.state.savedVenueIds,
        containsAll(['local-save', 'server-save']),
      );
    },
  );

  test(
    'favorites from an older signed-in user do not populate another account',
    () async {
      final api = _Api();
      final session = _Session()..signIn('old-user');
      final cubit = ProfileCubit(
        ProfileRepository(ProfileClient(api.dio), session),
        session,
      );
      addTearDown(cubit.close);
      addTearDown(session.close);
      final old = cubit.ensureSavedVenueIds();
      final oldRequest = await api.take('favorites');
      session.signIn('new-user');
      final current = cubit.ensureSavedVenueIds();
      (await api.take('favorites')).respond({
        'items': [
          {
            'venue': {'id': 'new-save'},
          },
        ],
        'nextCursor': null,
      });
      await current;
      oldRequest.respond({
        'items': [
          {
            'venue': {'id': 'old-save'},
          },
        ],
        'nextCursor': null,
      });
      await old;
      expect(cubit.state.savedVenueIds, ['new-save']);
    },
  );

  testWidgets(
    'OTP verification waits for persistence and reports save failures',
    (tester) async {
      final repository = _AuthRepository();
      final cubit = AuthCubit(repository);
      addTearDown(cubit.close);
      await tester.pumpWidget(
        MaterialApp(
          home: Form(
            key: cubit.otpFormKey,
            child: TextFormField(controller: cubit.otpController),
          ),
        ),
      );
      cubit.emailController.text = 'player@example.com';
      cubit.otpController.text = '123456';
      var completed = false;
      final verification = cubit.verifyCode().then((_) => completed = true);
      await tester.pump();
      expect(completed, isFalse);
      expect(cubit.state.status, AppLoading.loading);
      repository.persistence.complete(
        const ApiError(message: 'Storage unavailable'),
      );
      await verification;
      expect(cubit.state.status, AppLoading.error);
      expect(cubit.state.errorMessage, 'Storage unavailable');
    },
  );
}
