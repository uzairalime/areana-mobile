import 'dart:async';

import 'package:arana360/core/services/app_interceptor.dart';
import 'package:arana360/core/services/locator.dart';
import 'package:arana360/core/services/session_store.dart';
import 'package:arana360/core/services/token_store.dart';
import 'package:arana360/features/auth/model/auth_session.dart';
import 'package:arana360/features/auth/model/user_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_http_adapter.dart';
import '../../support/in_memory_secure_storage.dart';

const _user = UserModel(
  id: 'player',
  name: 'Player',
  email: 'player@example.com',
);
const _initial = AuthSession(
  accessToken: 'old',
  refreshToken: 'refresh-old',
  user: _user,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SessionStore store;
  late InMemorySecureStorage secure;
  late Dio mainDio;
  late Dio refreshDio;

  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    secure = InMemorySecureStorage();
    store = SessionStore(secureStorage: secure);
    await store.save(_initial);
    getIt.registerSingleton<SessionStore>(store);
    getIt.registerSingleton<TokenStore>(TokenStore(store));
    refreshDio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api/'));
    final interceptor = AppInterceptor(refreshDio: refreshDio);
    mainDio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api/'));
    mainDio.interceptors.add(interceptor);
    interceptor.dio = mainDio;
  });

  tearDown(() async {
    mainDio.close(force: true);
    refreshDio.close(force: true);
    await getIt.reset();
  });

  test(
    'parallel 401s share one refresh and retry with the rotated pair',
    () async {
      final started = Completer<void>();
      final release = Completer<void>();
      final refreshAdapter = FakeHttpAdapter((request) async {
        expect(request.path, 'auth/refresh');
        expect(request.data, {'refreshToken': 'refresh-old'});
        started.complete();
        await release.future;
        return jsonResponse({
          'accessToken': 'new',
          'refreshToken': 'refresh-new',
        });
      });
      refreshDio.httpClientAdapter = refreshAdapter;
      final tokens = <String>[];
      mainDio.httpClientAdapter = FakeHttpAdapter((request) {
        final token = request.headers['Authorization'] as String;
        tokens.add(token);
        return jsonResponse({}, statusCode: token == 'Bearer new' ? 200 : 401);
      });
      final first = mainDio.get<dynamic>('bookings/me');
      final second = mainDio.get<dynamic>('favorites');
      await started.future;
      await Future<void>.delayed(Duration.zero);
      release.complete();
      final responses = await Future.wait([first, second]);
      expect(responses.every((response) => response.statusCode == 200), isTrue);
      expect(refreshAdapter.requests, hasLength(1));
      expect(tokens.where((token) => token == 'Bearer new'), hasLength(2));
      expect(store.accessToken, 'new');
      expect(store.refreshToken, 'refresh-new');
      expect(store.user, _user);
    },
  );

  for (final status in [200, 401]) {
    test(
      'a late refresh $status cannot restore or clear another session',
      () async {
        final started = Completer<void>();
        final release = Completer<void>();
        refreshDio.httpClientAdapter = FakeHttpAdapter((_) async {
          started.complete();
          await release.future;
          return jsonResponse({
            'accessToken': 'stale',
            'refreshToken': 'stale-refresh',
          }, statusCode: status);
        });
        mainDio.httpClientAdapter = FakeHttpAdapter(
          (_) => jsonResponse({}, statusCode: 401),
        );
        final failure = expectLater(
          mainDio.get<dynamic>('bookings/me'),
          throwsA(isA<DioException>()),
        );
        await started.future;
        await store.save(
          const AuthSession(
            accessToken: 'other',
            refreshToken: 'other-refresh',
            user: _user,
          ),
        );
        release.complete();
        await failure;
        expect(store.accessToken, 'other');
        expect(store.refreshToken, 'other-refresh');
      },
    );
  }

  test('logout during refresh stays logged out', () async {
    final started = Completer<void>();
    final release = Completer<void>();
    refreshDio.httpClientAdapter = FakeHttpAdapter((_) async {
      started.complete();
      await release.future;
      return jsonResponse({
        'accessToken': 'stale',
        'refreshToken': 'stale-refresh',
      });
    });
    mainDio.httpClientAdapter = FakeHttpAdapter(
      (_) => jsonResponse({}, statusCode: 401),
    );
    final failure = expectLater(
      mainDio.get<dynamic>('favorites'),
      throwsA(isA<DioException>()),
    );
    await started.future;
    await store.clear();
    release.complete();
    await failure;
    expect(store.isAuthenticated, isFalse);
    expect(store.refreshToken, isNull);
  });

  test(
    'logout during refresh persistence prevents an authenticated retry',
    () async {
      final started = Completer<void>();
      final release = Completer<void>();
      secure.beforeWrite = (key, value) async {
        if (key == 'areana_access_token' && value == 'new') {
          started.complete();
          await release.future;
        }
      };
      refreshDio.httpClientAdapter = FakeHttpAdapter(
        (_) =>
            jsonResponse({'accessToken': 'new', 'refreshToken': 'refresh-new'}),
      );
      final adapter = FakeHttpAdapter((_) => jsonResponse({}, statusCode: 401));
      mainDio.httpClientAdapter = adapter;
      final failure = expectLater(
        mainDio.get<dynamic>('favorites'),
        throwsA(isA<DioException>()),
      );
      await started.future;
      final clear = store.clear();
      release.complete();
      await Future.wait([clear, failure]);
      expect(adapter.requests, hasLength(1));
      final restored = SessionStore(secureStorage: secure);
      await restored.restore();
      expect(restored.isAuthenticated, isFalse);
    },
  );

  for (final status in [401, 503]) {
    test('refresh $status clears only a revoked session', () async {
      refreshDio.httpClientAdapter = FakeHttpAdapter(
        (_) => jsonResponse({}, statusCode: status),
      );
      mainDio.httpClientAdapter = FakeHttpAdapter(
        (_) => jsonResponse({}, statusCode: 401),
      );
      await expectLater(
        mainDio.get<dynamic>('favorites'),
        throwsA(isA<DioException>()),
      );
      expect(store.isAuthenticated, status != 401);
    });
  }

  test('public OTP 401s never attempt token refresh', () async {
    final refreshAdapter = FakeHttpAdapter(
      (_) => throw StateError('unexpected refresh'),
    );
    refreshDio.httpClientAdapter = refreshAdapter;
    mainDio.httpClientAdapter = FakeHttpAdapter(
      (_) => jsonResponse({}, statusCode: 401),
    );
    await expectLater(
      mainDio.post<dynamic>('auth/verify-otp'),
      throwsA(isA<DioException>()),
    );
    expect(refreshAdapter.requests, isEmpty);
    expect(store.isAuthenticated, isTrue);
  });

  test('signed-out player APIs never leave the device', () async {
    await store.clear();
    final adapter = FakeHttpAdapter((request) {
      if (request.path.contains('bookings')) {
        throw StateError('token API must not run while signed out');
      }
      return jsonResponse({});
    });
    mainDio.httpClientAdapter = adapter;
    await expectLater(
      mainDio.get<dynamic>('bookings/me'),
      throwsA(
        isA<DioException>().having(
          (error) => error.type,
          'type',
          DioExceptionType.cancel,
        ),
      ),
    );
    expect(adapter.requests, isEmpty);
    await expectLater(mainDio.get<dynamic>('venues'), completes);
    expect(adapter.requests.single.path, 'venues');
  });

  test('a retried 401 is returned without refreshing a second time', () async {
    final refreshAdapter = FakeHttpAdapter(
      (_) =>
          jsonResponse({'accessToken': 'new', 'refreshToken': 'refresh-new'}),
    );
    refreshDio.httpClientAdapter = refreshAdapter;
    mainDio.httpClientAdapter = FakeHttpAdapter(
      (_) => jsonResponse({}, statusCode: 401),
    );
    await expectLater(
      mainDio.get<dynamic>('favorites'),
      throwsA(isA<DioException>()),
    );
    expect(refreshAdapter.requests, hasLength(1));
  });
}
