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
  SessionStore();

  final FlutterSecureStorage _secure = const FlutterSecureStorage();

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

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = await _secure.read(key: _accessKey);
    refreshToken = await _secure.read(key: _refreshKey);
    if (accessToken == null || accessToken!.isEmpty) {
      // One-time migration from the old SharedPreferences token.
      final legacy = prefs.getString(_legacyTokenKey);
      if (legacy != null && legacy.isNotEmpty) {
        accessToken = legacy;
        await _secure.write(key: _accessKey, value: legacy);
        await prefs.remove(_legacyTokenKey);
      }
    }
    final rawUser = prefs.getString(_userKey);
    if (rawUser == null || rawUser.isEmpty) {
      user = null;
      return;
    }
    try {
      user = UserModel.fromJson(
        Map<String, dynamic>.from(jsonDecode(rawUser) as Map),
      );
    } catch (_) {
      user = null;
      accessToken = null;
      refreshToken = null;
      await _secure.delete(key: _accessKey);
      await _secure.delete(key: _refreshKey);
      await prefs.remove(_userKey);
    }
  }

  Future<void> save(AuthSession session) async {
    accessToken = session.accessToken;
    refreshToken = session.refreshToken;
    user = session.user;
    await _secure.write(key: _accessKey, value: session.accessToken);
    if (session.refreshToken != null && session.refreshToken!.isNotEmpty) {
      await _secure.write(key: _refreshKey, value: session.refreshToken!);
    } else {
      await _secure.delete(key: _refreshKey);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(session.user.toJson()));
  }

  Future<void> saveUser(UserModel next) async {
    user = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(next.toJson()));
  }

  Future<void> clear() async {
    accessToken = null;
    refreshToken = null;
    user = null;
    await _secure.delete(key: _accessKey);
    await _secure.delete(key: _refreshKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_legacyTokenKey);
    await prefs.remove(_userKey);
  }
}
