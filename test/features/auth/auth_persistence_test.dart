import 'package:arana360/core/services/session_cubit.dart';
import 'package:arana360/core/services/session_store.dart';
import 'package:arana360/features/auth/cubit/auth_client.dart';
import 'package:arana360/features/auth/cubit/auth_repository.dart';
import 'package:arana360/features/auth/model/otp_models.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/in_memory_secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('failed secure persistence cannot leave the player signed in', () async {
    SharedPreferences.setMockInitialValues({});
    final secure = InMemorySecureStorage()
      ..beforeWrite = (_, _) async => throw StateError('storage unavailable');
    final store = SessionStore(secureStorage: secure);
    final session = SessionCubit(store);
    addTearDown(session.close);
    final dio = Dio();
    addTearDown(dio.close);
    final repository = AuthRepository(AuthClient(dio), session, store);
    final result = await repository.persistVerify(
      OtpVerifyResponse.fromJson({
        'accessToken': 'access',
        'refreshToken': 'refresh',
        'user': {
          'id': 'player',
          'email': 'player@example.com',
          'name': 'Player',
        },
      }),
    );
    expect(result.isError, isTrue);
    expect(store.isAuthenticated, isFalse);
    expect(session.state.isAuthenticated, isFalse);
    expect(secure.values, isEmpty);
  });
}
