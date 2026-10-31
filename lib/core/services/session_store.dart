import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/model/auth_session.dart';
import '../../features/auth/model/user_model.dart';

class SessionStore {
  SessionStore();

  static const _tokenKey = 'pitchside_access_token';
  static const _userKey = 'pitchside_user';

  String? accessToken;
  UserModel? user;

  bool get isAuthenticated =>
      accessToken != null && accessToken!.isNotEmpty && user != null;

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString(_tokenKey);
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
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    }
  }

  Future<void> save(AuthSession session) async {
    accessToken = session.accessToken;
    user = session.user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, session.accessToken);
    await prefs.setString(_userKey, jsonEncode(session.user.toJson()));
  }

  Future<void> saveUser(UserModel next) async {
    user = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(next.toJson()));
  }

  Future<void> clear() async {
    accessToken = null;
    user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
