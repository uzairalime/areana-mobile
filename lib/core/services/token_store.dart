import 'session_store.dart';

/// Thin alias kept for Dio interceptor compatibility.
/// Prefer [SessionStore] for auth session reads and writes.
class TokenStore {
  TokenStore(this._session);

  final SessionStore _session;

  String? get accessToken => _session.accessToken;

  set accessToken(String? value) => _session.accessToken = value;
}
