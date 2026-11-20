import 'package:arana360/core/services/session_cubit.dart';
import 'package:arana360/core/services/session_store.dart';
import 'package:arana360/core/widgets/guest_gate.dart';
import 'package:arana360/features/auth/model/auth_session.dart';
import 'package:arana360/features/auth/model/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/in_memory_secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('signed-out tabs show Account required instead of private UI', (
    tester,
  ) async {
    final session = SessionCubit(
      SessionStore(secureStorage: InMemorySecureStorage()),
    );
    addTearDown(session.close);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: session,
          child: const GuestGate(
            title: 'Account required',
            message:
                'Create an account to save court bookings, get slot reminders, and manage your schedule in one place.',
            child: Text('private-bookings'),
          ),
        ),
      ),
    );
    expect(find.text('Account required'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);
    expect(find.text('private-bookings'), findsNothing);
  });

  testWidgets('signed-in tabs keep the private child', (tester) async {
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
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: session,
          child: const GuestGate(child: Text('private-bookings')),
        ),
      ),
    );
    expect(find.text('private-bookings'), findsOneWidget);
    expect(find.text('Account required'), findsNothing);
  });
}
