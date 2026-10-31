import 'package:arana360/app.dart';
import 'package:arana360/core/consts/app_colors.dart';
import 'package:arana360/core/consts/app_strings.dart';
import 'package:arana360/core/services/locator.dart';
import 'package:arana360/core/services/session_cubit.dart';
import 'package:arana360/core/services/session_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Finder fieldError(String message) {
  return find.byWidgetPredicate((widget) {
    return widget is Text &&
        widget.data == message &&
        widget.style?.color == AppColors.error;
  });
}

Future<void> pumpApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  setupLocator();
  await getIt<SessionCubit>().restore();
  await tester.pumpWidget(const App());
  await tester.pump(const Duration(milliseconds: 1000));
  await tester.pumpAndSettle();
}

void main() {
  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('opens login and signup from the splash screen', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    expect(find.text(AppStrings.appName), findsWidgets);
    expect(find.text('Get started'), findsOneWidget);

    await tester.tap(find.text('I already have an account'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(find.text('Create your account'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue as guest'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Find a court.\nLock your slot.'), findsOneWidget);
    expect(find.byIcon(Icons.stadium_rounded), findsOneWidget);
    expect(find.byIcon(Icons.event_available_outlined), findsOneWidget);
  });

  testWidgets('shows field errors when an auth form is submitted empty', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await pumpApp(tester);

    await tester.tap(find.text('I already have an account'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pump();
    expect(fieldError('Enter your email or phone number'), findsOneWidget);
    expect(fieldError('Enter your password'), findsOneWidget);

    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Send code'));
    await tester.pump();
    expect(fieldError('Enter an email'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));
    expect(fieldError('Enter your name'), findsOneWidget);
    expect(fieldError('Enter your phone number'), findsOneWidget);
    expect(fieldError('Enter an email'), findsOneWidget);
    expect(fieldError('Enter a password'), findsOneWidget);
    expect(
      find.text('Agree to the Terms of Service and Privacy Policy'),
      findsOneWidget,
    );
  });

  testWidgets('login mock success saves session and opens home', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await pumpApp(tester);

    await tester.tap(find.text('I already have an account'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'alex@test.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password1');
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Find a court.\nLock your slot.'), findsOneWidget);
    expect(getIt<SessionStore>().isAuthenticated, isTrue);
    expect(getIt<SessionStore>().user?.email, 'alex@test.com');
  });
}
