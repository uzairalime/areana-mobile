import 'package:arana360/core/router/app_router.dart';
import 'package:arana360/core/services/locator.dart';
import 'package:arana360/core/services/session_cubit.dart';
import 'package:arana360/core/services/session_store.dart';
import 'package:arana360/core/widgets/app_otp_field.dart';
import 'package:arana360/core/widgets/app_text_field.dart';
import 'package:arana360/features/auth/cubit/auth_client.dart';
import 'package:arana360/features/auth/cubit/auth_cubit.dart';
import 'package:arana360/features/auth/cubit/auth_repository.dart';
import 'package:arana360/features/auth/cubit/auth_state.dart';
import 'package:arana360/features/auth/screen/auth_screen.dart';
import 'package:arana360/features/profile/cubit/profile_client.dart';
import 'package:arana360/features/profile/cubit/profile_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_http_adapter.dart';
import 'support/in_memory_secure_storage.dart';

class _AuthHarness {
  _AuthHarness({
    required this.adapter,
    required this.auth,
    required this.store,
    required this.secure,
  });

  final FakeHttpAdapter adapter;
  final AuthCubit auth;
  final SessionStore store;
  final InMemorySecureStorage secure;

  List<RequestOptions> get verifyRequests => adapter.requests
      .where((request) => request.path == 'auth/verify-otp')
      .toList();
}

Future<_AuthHarness> _pumpAuth(
  WidgetTester tester, {
  bool newAccount = false,
  String? next,
}) async {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final secure = InMemorySecureStorage();
  final store = SessionStore(secureStorage: secure);
  final session = SessionCubit(store);
  var user = <String, dynamic>{
    'id': 'player-1',
    'name': 'Ali',
    'email': 'player@example.com',
    'phone': '03001234567',
    'city': 'Lahore',
  };
  final adapter = FakeHttpAdapter((request) {
    switch (request.path) {
      case 'auth/request-otp':
        return jsonResponse({'message': 'Code sent', 'ttlSeconds': 600});
      case 'auth/verify-otp':
        final body = Map<String, dynamic>.from(request.data as Map);
        user = {
          'id': 'player-1',
          'email': body['email'],
          if (newAccount) ...{
            'name': '',
            'phone': '',
            'city': '',
            'isComplete': false,
          } else ...{
            'name': user['name'],
            'phone': user['phone'],
            'city': user['city'],
            'isComplete': true,
          },
        };
        return jsonResponse({
          'accessToken': 'verified-access-token',
          'refreshToken': 'verified-refresh-token',
          'isComplete': user['isComplete'],
          'user': user,
          'referralStatus': 'none',
        });
      case 'auth/complete-profile':
        final body = Map<String, dynamic>.from(request.data as Map);
        user = {
          ...user,
          'name': body['name'],
          'phone': body['phone'],
          'city': body['city'],
          'isComplete': true,
        };
        return jsonResponse({
          'success': true,
          'data': {
            'isComplete': true,
            'user': user,
            'referralStatus': 'none',
          },
        });
      case 'users/me':
        return jsonResponse(user);
      default:
        throw StateError('Unexpected auth test request: ${request.path}');
    }
  });
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/'))
    ..httpClientAdapter = adapter;
  final auth = AuthCubit(AuthRepository(AuthClient(dio), session, store));
  getIt.registerSingleton<ProfileRepository>(
    ProfileRepository(ProfileClient(dio), session),
  );
  final authLocation = Uri(
    path: AppRoutes.auth,
    queryParameters: next == null ? null : {'next': next},
  ).toString();
  final router = GoRouter(
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => Scaffold(
          body: TextButton(
            onPressed: () => context.push(authLocation),
            child: const Text('Open sign in'),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const Scaffold(body: Text('Home page')),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        builder: (context, state) =>
            const Scaffold(body: Text('Checkout page')),
      ),
    ],
  );
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
    await auth.close();
    await session.close();
    dio.close();
  });
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: auth),
        BlocProvider<SessionCubit>.value(value: session),
      ],
      child: MaterialApp.router(theme: ThemeData(), routerConfig: router),
    ),
  );
  await tester.tap(find.text('Open sign in'));
  await tester.pumpAndSettle();
  return _AuthHarness(
    adapter: adapter,
    auth: auth,
    store: store,
    secure: secure,
  );
}

Future<void> _enterField(
  WidgetTester tester,
  String label,
  String value,
) async {
  final field = find.byWidgetPredicate(
    (widget) => widget is AppTextField && widget.label == label,
  );
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
}

Future<void> _sendCode(
  WidgetTester tester, {
  String email = 'player@example.com',
}) async {
  await _enterField(tester, 'Email', email);
  await tester.tap(find.text('Send code'));
  await tester.pumpAndSettle();
  expect(find.text('Verify code'), findsOneWidget);
}

Future<void> _verifyCode(WidgetTester tester) async {
  final digitField = find
      .descendant(
        of: find.byType(AppOtpField),
        matching: find.byType(EditableText),
      )
      .first;
  await tester.enterText(digitField, '123456');
  await tester.tap(find.text('Verify code'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await getIt.reset();
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets(
    'email validation prevents requests until a valid email is entered',
    (tester) async {
      final harness = await _pumpAuth(tester);
      expect(find.text('Sign in or create an account'), findsOneWidget);
      expect(find.text('Password'), findsNothing);
      await tester.tap(find.text('Send code'));
      await tester.pump();
      expect(find.text('Enter an email'), findsOneWidget);
      await _enterField(tester, 'Email', 'invalid-email');
      await tester.tap(find.text('Send code'));
      await tester.pump();
      expect(find.text('Enter a valid email'), findsOneWidget);
      expect(harness.adapter.requests, isEmpty);
    },
  );

  for (final (next, destination) in <(String?, String)>[
    (null, 'Home page'),
    ('checkout', 'Checkout page'),
  ]) {
    testWidgets(
      'returning OTP login persists the session before $destination',
      (tester) async {
        final harness = await _pumpAuth(tester, next: next);
        await _sendCode(tester, email: 'PLAYER@Example.COM ');
        expect(harness.adapter.requests.first.method, 'POST');
        expect(harness.adapter.requests.first.data, {
          'email': 'player@example.com',
        });
        await _verifyCode(tester);
        expect(find.text(destination), findsOneWidget);
        expect(harness.verifyRequests.single.data, {
          'email': 'player@example.com',
          'code': '123456',
        });
        expect(harness.store.isAuthenticated, isTrue);
        expect(harness.store.user!.email, 'player@example.com');
        expect(
          harness.secure.values['areana_access_token'],
          'verified-access-token',
        );
        expect(
          harness.secure.values['areana_refresh_token'],
          'verified-refresh-token',
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'new account reuses verified OTP and submits name/phone without a password',
    (tester) async {
      final harness = await _pumpAuth(tester, newAccount: true);
      await _sendCode(tester, email: 'new@example.com');
      await _verifyCode(tester);
      expect(find.text('Complete your profile'), findsOneWidget);
      expect(harness.auth.state.step, AuthStep.signup);
      expect(harness.auth.otpController.text, isEmpty);
      expect(harness.verifyRequests, hasLength(1));
      await tester.ensureVisible(find.text('Complete profile'));
      await tester.tap(find.text('Complete profile'));
      await tester.pump();
      expect(find.text('Please tell us your name.'), findsOneWidget);
      expect(find.text('Enter your phone number'), findsOneWidget);
      expect(harness.verifyRequests, hasLength(1));
      await _enterField(tester, 'Full name', 'New Player');
      await _enterField(tester, 'Phone number', '03001234567');
      await _enterField(tester, 'City (optional)', 'Lahore');
      await tester.ensureVisible(find.text('Complete profile'));
      await tester.tap(find.text('Complete profile'));
      await tester.pumpAndSettle();
      expect(find.text('Home page'), findsOneWidget);
      expect(harness.verifyRequests, hasLength(1));
      expect(
        harness.adapter.requests
            .where((request) => request.path == 'auth/complete-profile')
            .single
            .data,
        {
          'name': 'New Player',
          'phone': '03001234567',
          'city': 'Lahore',
        },
      );
      expect(harness.store.user!.name, 'New Player');
      expect(harness.store.user!.phone, '03001234567');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('guest continues to home without an auth request or session', (
    tester,
  ) async {
    final harness = await _pumpAuth(tester);
    await tester.tap(find.text('Continue as guest'));
    await tester.pumpAndSettle();
    expect(find.text('Home page'), findsOneWidget);
    expect(harness.adapter.requests, isEmpty);
    expect(harness.store.isAuthenticated, isFalse);
    expect(tester.takeException(), isNull);
  });
}
