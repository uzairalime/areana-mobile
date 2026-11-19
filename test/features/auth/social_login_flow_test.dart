import 'package:arana360/core/enums/app_loading.dart';
import 'package:arana360/core/services/app_interceptor.dart';
import 'package:arana360/core/services/locator.dart';
import 'package:arana360/core/services/session_cubit.dart';
import 'package:arana360/core/services/session_store.dart';
import 'package:arana360/core/services/token_store.dart';
import 'package:arana360/features/auth/cubit/auth_client.dart';
import 'package:arana360/features/auth/cubit/auth_cubit.dart';
import 'package:arana360/features/auth/cubit/auth_repository.dart';
import 'package:arana360/features/auth/cubit/auth_state.dart';
import 'package:arana360/features/auth/cubit/social_auth.dart';
import 'package:arana360/features/auth/widgets/auth_email_step.dart';
import 'package:arana360/features/auth/widgets/auth_widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_http_adapter.dart';
import '../../support/in_memory_secure_storage.dart';

class _FakeSocialAuth implements SocialAuth {
  _FakeSocialAuth({
    this.appleAvailable = false,
    this.google,
  });

  @override
  bool get googleAvailable => true;

  @override
  final bool appleAvailable;

  SocialCredential? google;
  int googleCalls = 0;

  @override
  Future<SocialCredential?> signInGoogle() async {
    googleCalls += 1;
    return google;
  }

  @override
  Future<SocialCredential?> signInApple() async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Google social login reuses the OTP session persist path', () async {
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
      expect(request.path, 'auth/social');
      expect(request.data, {
        'provider': 'google',
        'idToken': 'google-id-token',
        'name': 'Ali Khan',
      });
      return jsonResponse({
        'success': true,
        'data': {
          'accessToken': 'access-social',
          'refreshToken': 'refresh-social',
          'isComplete': false,
          'user': {
            'id': 'player-g',
            'email': 'ali@gmail.com',
            'name': 'Ali Khan',
            'phone': null,
            'provider': 'google',
          },
        },
      });
    });

    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api/'));
    final interceptor = AppInterceptor();
    dio.interceptors.add(interceptor);
    interceptor.dio = dio;
    dio.httpClientAdapter = adapter;
    addTearDown(dio.close);

    final repository = AuthRepository(AuthClient(dio), session, store);
    final result = await repository.socialLogin(
      provider: 'google',
      idToken: 'google-id-token',
      name: 'Ali Khan',
    );
    final payload = result.dataOrNull!;
    expect(payload.userProvider, 'google');
    expect(payload.isProfileCompleted, isFalse);
    final persisted = await repository.persistVerify(payload);
    expect(persisted.isSuccess, isTrue);
    expect(store.accessToken, 'access-social');
    expect(store.user?.provider, 'google');
    expect(store.user?.isProfileCompleted, isFalse);
  });

  test('cancelled Google sheet does not hit the API', () async {
    SharedPreferences.setMockInitialValues({});
    final store = SessionStore(secureStorage: InMemorySecureStorage());
    final session = SessionCubit(store);
    addTearDown(session.close);
    final adapter = FakeHttpAdapter((request) {
      fail('Unexpected ${request.method} ${request.path}');
    });
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api/'))
      ..httpClientAdapter = adapter;
    addTearDown(dio.close);
    final social = _FakeSocialAuth();
    final cubit = AuthCubit(
      AuthRepository(AuthClient(dio), session, store),
      socialAuth: social,
    );
    addTearDown(cubit.close);
    await cubit.continueWithGoogle();
    expect(social.googleCalls, 1);
    expect(adapter.requests, isEmpty);
    expect(cubit.state.status.isError, isFalse);
    expect(store.isAuthenticated, isFalse);
  });

  test('Google success finishes login and asks for profile details', () async {
    SharedPreferences.setMockInitialValues({});
    final store = SessionStore(secureStorage: InMemorySecureStorage());
    final session = SessionCubit(store);
    addTearDown(session.close);
    final adapter = FakeHttpAdapter((request) {
      return jsonResponse({
        'success': true,
        'data': {
          'accessToken': 'access',
          'refreshToken': 'refresh',
          'isComplete': false,
          'user': {
            'id': 'player-g',
            'email': 'ali@gmail.com',
            'name': 'Ali',
            'provider': 'google',
          },
        },
      });
    });
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api/'))
      ..httpClientAdapter = adapter;
    addTearDown(dio.close);
    final cubit = AuthCubit(
      AuthRepository(AuthClient(dio), session, store),
      socialAuth: _FakeSocialAuth(
        google: const SocialCredential(
          provider: 'google',
          idToken: 'id-token',
          name: 'Ali',
        ),
      ),
    );
    addTearDown(cubit.close);
    await cubit.continueWithGoogle();
    expect(cubit.state.step, AuthStep.signup);
    expect(store.user?.email, 'ali@gmail.com');
    expect(store.user?.provider, 'google');
  });

  testWidgets('Android shows Google and hides Apple', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final cubit = _emailCubit(apple: false);
    addTearDown(cubit.close);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: Scaffold(
            body: AuthEmailStep(onGuestContinue: () {}),
          ),
        ),
      ),
    );
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Continue with Apple'), findsNothing);
    expect(find.byType(SocialAuthButton), findsOneWidget);
  });

  testWidgets('iOS shows Google and Apple', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final cubit = _emailCubit(apple: true);
    addTearDown(cubit.close);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: Scaffold(
            body: AuthEmailStep(onGuestContinue: () {}),
          ),
        ),
      ),
    );
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Continue with Apple'), findsOneWidget);
  });
}

AuthCubit _emailCubit({required bool apple}) {
  final store = SessionStore(secureStorage: InMemorySecureStorage());
  return AuthCubit(
    AuthRepository(AuthClient(Dio()), SessionCubit(store), store),
    socialAuth: _FakeSocialAuth(appleAvailable: apple),
  );
}
