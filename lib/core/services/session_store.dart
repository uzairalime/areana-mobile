import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/model/auth_session.dart';
import '../../features/auth/model/user_model.dart';

/// Owns the persisted auth session.
///
/// Tokens live in secure storage (iOS Keychain / Android Keystore).
/// Only the non-secret user profile JSON stays in SharedPreferences.
/// In-memory fields are the source of truth for request-time reads;
/// [restore] hydrates them, [save] keeps both stores in sync.
class SessionStore {
  SessionStore({FlutterSecureStorage? secureStorage})
    : _secure = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secure;
  Future<void> _storageOperation = Future<void>.value();
  var _revision = 0;

  static const _accessKey = 'areana_access_token';
  static const _refreshKey = 'areana_refresh_token';

  /// Legacy Pitchside token key, kept only for one-time migration.
  static const _legacyTokenKey = 'pitchside_access_token';
  static const _userKey = 'pitchside_user';

  String? accessToken;
  String? refreshToken;
  UserModel? user;

  bool get isAuthenticated =>
      accessToken != null && accessToken!.isNotEmpty && user != null;

  Future<void> restore() {
    final revision = _revision;
    return _withStorage(() async {
      if (revision != _revision) return;
      final prefs = await SharedPreferences.getInstance();
      var restoredAccess = await _secure.read(key: _accessKey);
      var restoredRefresh = await _secure.read(key: _refreshKey);
      if (revision != _revision) return;
      if (restoredAccess == null || restoredAccess.isEmpty) {
        // One-time migration from the old SharedPreferences token.
        final legacy = prefs.getString(_legacyTokenKey);
        if (legacy != null && legacy.isNotEmpty) {
          restoredAccess = legacy;
          await _secure.write(key: _accessKey, value: legacy);
          await prefs.remove(_legacyTokenKey);
        }
      }
      final rawUser = prefs.getString(_userKey);
      UserModel? restoredUser;
      if (rawUser != null && rawUser.isNotEmpty) {
        try {
          restoredUser = UserModel.fromJson(
            Map<String, dynamic>.from(jsonDecode(rawUser) as Map),
          );
        } catch (_) {
          restoredAccess = null;
          restoredRefresh = null;
          await _secure.delete(key: _accessKey);
          await _secure.delete(key: _refreshKey);
          await prefs.remove(_userKey);
        }
      }
      if (revision != _revision) return;
      accessToken = restoredAccess;
      refreshToken = restoredRefresh;
      user = restoredUser;
    });
  }

  Future<void> save(AuthSession session) {
    _revision++;
    accessToken = session.accessToken;
    refreshToken = session.refreshToken;
    user = session.user;
    return _withStorage(() async {
      await _secure.write(key: _accessKey, value: session.accessToken);
      if (session.refreshToken != null && session.refreshToken!.isNotEmpty) {
        await _secure.write(key: _refreshKey, value: session.refreshToken!);
      } else {
        await _secure.delete(key: _refreshKey);
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(session.user.toJson()));
    });
  }

  Future<void> saveUser(UserModel next) {
    _revision++;
    user = next;
    return _withStorage(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(next.toJson()));
    });
  }

  Future<void> clear() {
    _revision++;
    accessToken = null;
    refreshToken = null;
    user = null;
    return _withStorage(() async {
      await _secure.delete(key: _accessKey);
      await _secure.delete(key: _refreshKey);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_legacyTokenKey);
      await prefs.remove(_userKey);
    });
  }

  // Keep storage writes in call order: a slow login/refresh write cannot
  // persist old credentials after a later logout or a different login.
  Future<void> _withStorage(Future<void> Function() operation) {
    final current = _storageOperation.then((_) => operation());
    _storageOperation = current.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return current;
  }
}
