import 'package:arana360/core/services/app_interceptor.dart';
import 'package:arana360/core/services/locator.dart';
import 'package:arana360/core/services/session_cubit.dart';
import 'package:arana360/core/services/session_store.dart';
import 'package:arana360/core/services/token_store.dart';
import 'package:arana360/features/auth/cubit/auth_client.dart';
import 'package:arana360/features/auth/cubit/auth_repository.dart';
import 'package:arana360/features/auth/model/otp_models.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_http_adapter.dart';
import '../../support/in_memory_secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('isComplete false keeps a named player on profile completion', () {
    final response = OtpVerifyResponse.fromJson({
      'data': {
        'accessToken': 'access-1',
        'refreshToken': 'refresh-1',
        'isComplete': false,
        'user': {
          'id': 'player-1',
          'email': 'player@example.com',
          'name': 'Ali',
          'phone': '03001234567',
        },
      },
    });

    expect(response.accessToken, 'access-1');
    expect(response.isProfileCompleted, isFalse);
  });

  test('email, otp, resend, and profile completion share one stored access token', () async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    final secure = InMemorySecureStorage();
    final store = SessionStore(secureStorage: secure);
    final session = SessionCubit(store);
    addTearDown(session.close);
    addTearDown(getIt.reset);
    getIt.registerSingleton<SessionStore>(store);
    getIt.registerSingleton<TokenStore>(TokenStore(store));

    final adapter = FakeHttpAdapter((request) {
      switch (request.path) {
        case 'auth/request-otp':
          return jsonResponse({
            'message': 'Login code sent to your email',
            'expiresAt': '2026-11-20T00:10:00.000Z',
            'ttlSeconds': 600,
          });
        case 'auth/verify-otp':
          expect(request.data, {
            'email': 'player@example.com',
            'code': '482913',
          });
          return jsonResponse({
            'success': true,
            'data': {
              'accessToken': 'access-1',
              'refreshToken': 'refresh-1',
              'isComplete': false,
              'user': {
                'id': 'player-1',
                'email': 'player@example.com',
                'name': null,
                'phone': null,
              },
            },
          });
        case 'auth/complete-profile':
          expect(request.headers['Authorization'], 'Bearer access-1');
          expect(request.data, {
            'name': 'Ali Khan',
            'phone': '03001234567',
            'city': 'Lahore',
          });
          return jsonResponse({
            'success': true,
            'data': {
              'isComplete': true,
              'user': {
                'id': 'player-1',
                'email': 'player@example.com',
                'name': 'Ali Khan',
                'phone': '03001234567',
                'city': 'Lahore',
              },
            },
          });
        default:
          fail('Unexpected ${request.method} ${request.path}');
      }
    });

    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api/'));
    final interceptor = AppInterceptor();
    dio.interceptors.add(interceptor);
    interceptor.dio = dio;
    dio.httpClientAdapter = adapter;
    addTearDown(dio.close);

    final repository = AuthRepository(AuthClient(dio), session, store);

    final sent = await repository.requestOtp(email: 'player@example.com');
    expect(sent.dataOrNull?.ttlSeconds, 600);

    final verified = await repository.verifyOtp(
      email: 'player@example.com',
      code: '482913',
    );
    final otp = verified.dataOrNull!;
    expect(otp.isProfileCompleted, isFalse);
    final persisted = await repository.persistVerify(otp);
    expect(persisted.isSuccess, isTrue);
    expect(store.accessToken, 'access-1');
    expect(secure.values['areana_access_token'], 'access-1');
    expect(store.user?.isProfileCompleted, isFalse);

    final resent = await repository.requestOtp(email: 'player@example.com');
    expect(resent.isSuccess, isTrue);

    final completed = await repository.completeProfile(
      name: 'Ali Khan',
      phone: '03001234567',
      city: 'Lahore',
    );
    expect(completed.isSuccess, isTrue);
    expect(store.user?.name, 'Ali Khan');
    expect(store.user?.phone, '03001234567');
    expect(store.user?.city, 'Lahore');
    expect(store.user?.isProfileCompleted, isTrue);
    expect(store.accessToken, 'access-1');

    expect(
      adapter.requests.map((request) => request.path).toList(),
      [
        'auth/request-otp',
        'auth/verify-otp',
        'auth/request-otp',
        'auth/complete-profile',
      ],
    );
  });
}
