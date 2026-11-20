import 'package:arana360/core/consts/app_colors.dart';
import 'package:arana360/core/router/app_router.dart';
import 'package:arana360/core/services/session_cubit.dart';
import 'package:arana360/core/services/session_store.dart';
import 'package:arana360/core/widgets/app_button.dart';
import 'package:arana360/core/widgets/primary_button.dart';
import 'package:arana360/core/widgets/primary_outline_button.dart';
import 'package:arana360/features/auth/cubit/splash_cubit.dart';
import 'package:arana360/features/auth/screen/splash_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' as material_ui;

final _theme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(52),
      backgroundColor: AppColors.surface,
    ),
  ),
);

Future<void> _pumpButton(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: _theme,
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

Future<(SplashCubit, GoRouter)> _pumpSplash(
  WidgetTester tester, {
  Size size = const Size(800, 700),
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final session = SessionCubit(SessionStore());
  final splash = SplashCubit.idle(session);
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
  addTearDown(session.close);
  await tester.pumpWidget(
    MaterialApp.router(
      theme: _theme,
      routerConfig: router,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: true,
        ),
        child: child!,
      ),
    ),
  );
  return (splash, router);
}

void main() {
  final variants = <(String, Widget Function(VoidCallback?, bool))>[
    (
      'filled',
      (onPressed, loading) => PrimaryButton(
        label: 'Continue',
        onPressed: onPressed,
        loading: loading,
      ),
    ),
    (
      'outline',
      (onPressed, loading) => PrimaryOutlineButton(
        label: 'Continue',
        onPressed: onPressed,
        loading: loading,
      ),
    ),
  ];

  for (final (name, buildButton) in variants) {
    testWidgets('$name button invokes the enabled callback once', (
      tester,
    ) async {
      var taps = 0;
      await _pumpButton(tester, buildButton(() => taps++, false));
      await tester.tap(find.text('Continue'));
      expect(taps, 1);
    });

    testWidgets('$name button supports disabled and loading states', (
      tester,
    ) async {
      await _pumpButton(tester, buildButton(null, false));
      final disabled = tester.widget<ButtonStyleButton>(
        find.byWidgetPredicate((widget) => widget is ButtonStyleButton),
      );
      expect(disabled.enabled, isFalse);

      var taps = 0;
      await _pumpButton(tester, buildButton(() => taps++, true));
      final loading = tester.widget<ButtonStyleButton>(
        find.byWidgetPredicate((widget) => widget is ButtonStyleButton),
      );
      expect(loading.enabled, isFalse);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(CircularProgressIndicator));
      expect(taps, 0);
    });

    testWidgets('$name keeps its full width while loading in a loose Column', (
      tester,
    ) async {
      Widget layout(bool loading) => SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [buildButton(() {}, loading)],
        ),
      );
      final buttonFinder = find.byWidgetPredicate(
        (widget) => widget is ButtonStyleButton,
      );
      await _pumpButton(tester, layout(false));
      final enabledWidth = tester.getSize(buttonFinder).width;
      expect(enabledWidth, 300);
      await _pumpButton(tester, layout(true));
      expect(tester.getSize(buttonFinder).width, enabledWidth);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('new and legacy buttons work in a Row without Expanded', (
    tester,
  ) async {
    await _pumpButton(
      tester,
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(label: 'Save', onPressed: () {}),
          PrimaryOutlineButton(label: 'Back', onPressed: () {}),
          AppButton(label: 'Next', onPressed: () {}),
          AppButton.outlined(label: 'Skip', onPressed: () {}),
        ],
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(FilledButton), findsNWidgets(2));
    expect(find.byType(OutlinedButton), findsNWidgets(2));
  });

  testWidgets('long labels wrap inside a narrow button', (tester) async {
    const label = 'Continue to finish creating your account';
    await _pumpButton(
      tester,
      SizedBox(
        width: 160,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PrimaryButton(label: label, onPressed: () {}),
            PrimaryOutlineButton(
              label: label,
              icon: Icons.person_outline,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    for (final text in find.text(label).evaluate()) {
      expect(
        tester.getSize(find.byElementPredicate((item) => item == text)).width,
        lessThan(160),
      );
    }
  });

  testWidgets('outline stays transparent over the themed surface', (
    tester,
  ) async {
    await _pumpButton(
      tester,
      PrimaryOutlineButton(label: 'Account', onPressed: () {}),
    );
    final material = tester.widget<Material>(
      find
          .descendant(
            of: find.byType(OutlinedButton),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(material.color, Colors.transparent);
    expect(
      DefaultTextStyle.of(tester.element(find.text('Account'))).style.color,
      AppColors.onPrimary,
    );
  });

  testWidgets('splash replaces launch with reusable actions', (tester) async {
    final (splash, _) = await _pumpSplash(tester);
    expect(find.byKey(const Key('splash-launch')), findsOneWidget);
    expect(find.byType(PrimaryButton), findsNothing);
    splash.debugSetDestination(SplashDestination.welcome);
    await tester.pump();
    expect(find.byKey(const Key('splash-launch')), findsNothing);
    expect(find.byType(PrimaryButton), findsOneWidget);
    expect(find.byType(PrimaryOutlineButton), findsOneWidget);
    expect(
      find.widgetWithText(material_ui.TextButton, 'Continue as guest'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  for (final (label, routeText) in [
    ('Get started', 'Auth route'),
    ('I already have an account', 'Auth route'),
    ('Continue as guest', 'Home route'),
  ]) {
    testWidgets('splash $label keeps its navigation', (tester) async {
      final (splash, _) = await _pumpSplash(tester);
      splash.debugSetDestination(SplashDestination.welcome);
      await tester.pumpAndSettle();
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(find.text(routeText), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('splash home state still redirects to home', (tester) async {
    final (splash, _) = await _pumpSplash(tester);
    splash.debugSetDestination(SplashDestination.home);
    await tester.pumpAndSettle();
    expect(find.text('Home route'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'small splash supports larger text and scrolling to guest action',
    (tester) async {
      final (splash, _) = await _pumpSplash(
        tester,
        size: const Size(320, 480),
        textScale: 1.3,
      );
      splash.debugSetDestination(SplashDestination.welcome);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Padel'), findsOneWidget);
      expect(find.text('Football'), findsOneWidget);
      expect(find.text('Indoor Cricket'), findsOneWidget);
      await tester.ensureVisible(find.text('Continue as guest'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue as guest'));
      await tester.pumpAndSettle();
      expect(find.text('Home route'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
