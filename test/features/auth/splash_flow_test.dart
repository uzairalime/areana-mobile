import 'package:arana360/core/consts/app_strings.dart';
import 'package:arana360/core/router/app_router.dart';
import 'package:arana360/core/services/session_cubit.dart';
import 'package:arana360/core/services/session_store.dart';
import 'package:arana360/core/widgets/pitchside_mark.dart';
import 'package:arana360/features/auth/cubit/splash_cubit.dart';
import 'package:arana360/features/auth/model/auth_session.dart';
import 'package:arana360/features/auth/model/user_model.dart';
import 'package:arana360/features/auth/screen/splash_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/in_memory_secure_storage.dart';

Future<void> _waitUntilNotLaunch(SplashCubit cubit) async {
  if (cubit.state.destination != SplashDestination.launch) {
    return;
  }
  await cubit.stream.firstWhere(
    (state) => state.destination != SplashDestination.launch,
  );
}

Future<SplashCubit> _pumpSplash(
  WidgetTester tester,
  SplashCubit splash,
) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => BlocProvider<SplashCubit>.value(
          value: splash,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => const Scaffold(body: Text('Auth route')),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const Scaffold(body: Text('Home route')),
      ),
    ],
  );
  addTearDown(router.dispose);
  addTearDown(splash.close);
  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child!,
      ),
    ),
  );
  return splash;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('launch then welcome for guests, home for signed-in users', () {
    expect(
      splashAfterLaunch(isAuthenticated: false),
      SplashDestination.welcome,
    );
    expect(
      splashAfterLaunch(isAuthenticated: true),
      SplashDestination.home,
    );
  });

  test('bootstrap shows welcome after A0 when the session is empty', () async {
    final session = SessionCubit(
      SessionStore(secureStorage: InMemorySecureStorage()),
    );
    addTearDown(session.close);
    final cubit = SplashCubit(session, launchHold: Duration.zero);
    addTearDown(cubit.close);
    await _waitUntilNotLaunch(cubit);
    expect(cubit.state.destination, SplashDestination.welcome);
  });

  test('bootstrap skips A1 when the player is already signed in', () async {
    final session = SessionCubit(
      SessionStore(secureStorage: InMemorySecureStorage()),
    );
    addTearDown(session.close);
    await session.applySession(
      const AuthSession(
        accessToken: 'token',
        user: UserModel(id: 'u1', name: 'Ali', email: 'ali@arena.test'),
      ),
    );
    final cubit = SplashCubit(session, launchHold: Duration.zero);
    addTearDown(cubit.close);
    await _waitUntilNotLaunch(cubit);
    expect(cubit.state.destination, SplashDestination.home);
  });

  testWidgets('A0 launch splash shows Game on and the court loader', (
    tester,
  ) async {
    final session = SessionCubit(SessionStore());
    addTearDown(session.close);
    await _pumpSplash(tester, SplashCubit.idle(session));
    expect(find.byKey(const Key('splash-launch')), findsOneWidget);
    expect(find.text(AppStrings.gameOn), findsOneWidget);
    expect(find.text(AppStrings.gettingCourtsReady), findsOneWidget);
    final bar = tester.getRect(find.byKey(const Key('splash-launch-progress')));
    final caption = tester.getRect(find.text(AppStrings.gettingCourtsReady));
    expect(bar.height, 4);
    expect(bar.bottom, lessThan(caption.top));
    expect(find.text(AppStrings.getStarted), findsNothing);
    expect(find.text(AppStrings.bookYourCourt), findsNothing);
  });

  testWidgets('A1 welcome splash follows A0 with sport chips and actions', (
    tester,
  ) async {
    final session = SessionCubit(SessionStore());
    addTearDown(session.close);
    final splash = SplashCubit.idle(session);
    await _pumpSplash(tester, splash);
    splash.debugSetDestination(SplashDestination.welcome);
    await tester.pump();
    expect(find.byKey(const Key('splash-welcome')), findsOneWidget);
    expect(find.text(AppStrings.bookYourCourt), findsOneWidget);
    expect(find.text('Padel'), findsOneWidget);
    expect(find.text(AppStrings.getStarted), findsOneWidget);
    expect(find.text(AppStrings.alreadyHaveAccount), findsOneWidget);
    expect(find.text(AppStrings.continueAsGuest), findsOneWidget);
    expect(find.text(AppStrings.gettingCourtsReady), findsNothing);
  });

  testWidgets('A0 and A1 splash items sit on the horizontal center', (
    tester,
  ) async {
    final session = SessionCubit(SessionStore());
    addTearDown(session.close);
    final splash = SplashCubit.idle(session);
    await _pumpSplash(tester, splash);
    const screenCenter = 390 / 2;
    void expectCentered(Finder finder) {
      expect(tester.getCenter(finder).dx, closeTo(screenCenter, 1));
    }

    expectCentered(find.byType(PitchsideMark));
    expectCentered(find.text(AppStrings.appName));
    expectCentered(find.text(AppStrings.gameOn));
    expectCentered(find.byKey(const Key('splash-launch-progress')));
    expectCentered(find.text(AppStrings.gettingCourtsReady));

    splash.debugSetDestination(SplashDestination.welcome);
    await tester.pump();
    expectCentered(find.byType(PitchsideMark));
    expectCentered(find.text(AppStrings.appName));
    expectCentered(find.text(AppStrings.bookYourCourt));
  });

  testWidgets('tapping A0 advances a guest to A1', (tester) async {
    final session = SessionCubit(SessionStore());
    addTearDown(session.close);
    await _pumpSplash(tester, SplashCubit.idle(session));
    await tester.tap(find.byKey(const Key('splash-launch')));
    await tester.pump();
    expect(find.byKey(const Key('splash-welcome')), findsOneWidget);
    expect(find.text(AppStrings.getStarted), findsOneWidget);
  });
}
