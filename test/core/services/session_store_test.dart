import 'dart:async';
import 'dart:convert';

import 'package:arana360/core/services/session_store.dart';
import 'package:arana360/features/auth/model/auth_session.dart';
import 'package:arana360/features/auth/model/user_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/in_memory_secure_storage.dart';

const _session = AuthSession(
  accessToken: 'access',
  refreshToken: 'refresh',
  user: UserModel(id: 'player', name: 'Player', email: 'player@example.com'),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'a logout waits for old writes and remains logged out after restart',
    () async {
      final secure = InMemorySecureStorage();
      final started = Completer<void>();
      final release = Completer<void>();
      secure.beforeWrite = (key, value) async {
        if (key == 'areana_access_token') {
          started.complete();
          await release.future;
        }
      };
      final store = SessionStore(secureStorage: secure);
      final save = store.save(_session);
      await started.future;
      final clear = store.clear();
      expect(store.isAuthenticated, isFalse);
      release.complete();
      await Future.wait([save, clear]);
      expect(secure.values, isEmpty);
      final restored = SessionStore(secureStorage: secure);
      await restored.restore();
      expect(restored.isAuthenticated, isFalse);
      expect(restored.refreshToken, isNull);
    },
  );

  test('an older restore cannot replace a newly applied login', () async {
    final secure = InMemorySecureStorage();
    final started = Completer<void>();
    final release = Completer<void>();
    secure.beforeRead = (key) async {
      if (key == 'areana_access_token') {
        started.complete();
        await release.future;
      }
    };
    final store = SessionStore(secureStorage: secure);
    final restore = store.restore();
    await started.future;
    final save = store.save(_session);
    release.complete();
    await Future.wait([restore, save]);
    expect(store.accessToken, 'access');
    expect(store.user, _session.user);
  });

  test('a failed write does not block a subsequent logout', () async {
    final secure = InMemorySecureStorage()
      ..beforeWrite = (_, _) async => throw StateError('storage failed');
    final store = SessionStore(secureStorage: secure);
    await expectLater(store.save(_session), throwsStateError);
    await store.clear();
    expect(store.isAuthenticated, isFalse);
    expect(secure.values, isEmpty);
  });

  test(
    'legacy tokens migrate and malformed profiles clear the session',
    () async {
      SharedPreferences.setMockInitialValues({
        'pitchside_access_token': 'legacy',
        'pitchside_user': jsonEncode(_session.user.toJson()),
      });
      final secure = InMemorySecureStorage();
      final store = SessionStore(secureStorage: secure);
      await store.restore();
      expect(store.isAuthenticated, isTrue);
      expect(secure.values['areana_access_token'], 'legacy');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('pitchside_access_token'), isFalse);
      await prefs.setString('pitchside_user', 'invalid JSON');
      await store.restore();
      expect(store.isAuthenticated, isFalse);
      expect(secure.values, isEmpty);
    },
  );
}
