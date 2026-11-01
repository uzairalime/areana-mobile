import 'package:dio/dio.dart';

import '../../features/auth/model/auth_session.dart';
import '../consts/api_endpoints.dart';
import 'locator.dart';
import 'session_cubit.dart';
import 'session_store.dart';
import 'token_store.dart';

/// Auth interceptor for the single app-wide [Dio] instance.
///
/// Request side: attaches `Authorization: Bearer <accessToken>` when one
/// is stored. The token is read at request time, never at Dio creation.
///
/// Error side: single-flight refresh for Areana token rotation.
///
/// Areana rules this implements (see `api-reference.md` §1.4):
/// - Access tokens live ~15 minutes; refresh tokens rotate on every
///   successful `POST /auth/refresh` and the old pair must be discarded.
/// - Parallel 401s must share ONE refresh call. Firing one refresh per
///   401 would present the just-rotated token again and trip the
///   server's reuse detection, which revokes ALL sessions.
/// - A refresh that returns 401 means the session is dead (revoked,
///   expired, or reuse-detected): clear the session and let the
///   original 401 reach the UI so it can route back to login.
/// - A refresh that fails for any other reason (network, timeout,
///   404/5xx from a backend that does not have this endpoint yet)
///   keeps the session: the original error is returned unchanged, so
///   the user is not logged out by a transient failure.
/// - A request that was already retried once is never retried again,
///   and public auth endpoints are never refreshed (a 401 there means
///   a wrong code/password, not an expired access token).
class AppInterceptor extends Interceptor {
  /// Set by [DioService] after the main Dio is created. Without it,
  /// retries cannot be dispatched and 401s pass through unchanged.
  late Dio dio;

  Future<AuthSession?>? _refreshFuture;

  static const _retriedKey = '__areana_retried';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (getIt.isRegistered<TokenStore>()) {
      final token = getIt<TokenStore>().accessToken;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    if (response?.statusCode != 401 ||
        err.requestOptions.extra[_retriedKey] == true ||
        _isAuthPath(err.requestOptions.path)) {
      handler.next(err);
      return;
    }

    final store = _sessionStore;
    if (store == null) {
      handler.next(err);
      return;
    }

    // Another in-flight request may already have refreshed: if the
    // token used by this failed request is no longer the current one,
    // retry with the current token instead of refreshing again.
    final usedToken = _bearerToken(err.requestOptions);
    final currentToken = store.accessToken;
    if (usedToken != null &&
        currentToken != null &&
        currentToken.isNotEmpty &&
        usedToken != currentToken) {
      await _retryWith(handler, err, currentToken);
      return;
    }

    final refreshToken = store.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      handler.next(err);
      return;
    }

    final refreshed = await _refreshSingleFlight(refreshToken);
    if (refreshed == null) {
      // Transient refresh failure (network, timeout, endpoint missing):
      // keep the session, return the original 401 unchanged.
      handler.next(err);
      return;
    }
    if (refreshed.accessToken.isEmpty) {
      handler.next(err);
      return;
    }
    await _retryWith(handler, err, refreshed.accessToken);
  }

  Future<void> _retryWith(
    ErrorInterceptorHandler handler,
    DioException err,
    String token,
  ) async {
    try {
      final options = err.requestOptions
        ..headers['Authorization'] = 'Bearer $token'
        ..extra[_retriedKey] = true;
      final response = await dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    } catch (_) {
      handler.next(err);
    }
  }

  /// Returns the refreshed session, or null when refresh failed
  /// transiently. A refresh 401 clears the session first and also
  /// returns null, so callers must not retry after it.
  Future<AuthSession?> _refreshSingleFlight(String refreshToken) {
    _refreshFuture ??= _doRefresh(refreshToken).whenComplete(() {
      _refreshFuture = null;
    });
    return _refreshFuture!;
  }

  Future<AuthSession?> _doRefresh(String refreshToken) async {
    // A clean Dio: no interceptors, otherwise the refresh call itself
    // would re-enter this interceptor and loop.
    final refreshDio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        responseType: ResponseType.json,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
    try {
      final response = await refreshDio.post<dynamic>(
        ApiEndpoints.refresh,
        data: {'refreshToken': refreshToken},
      );
      final data = response.data;
      if (data is! Map) {
        return null;
      }
      var session = AuthSession.fromJson(Map<String, dynamic>.from(data));
      final store = _sessionStore;
      // Refresh responses may omit the user: keep the stored profile
      // instead of replacing it with an empty user model.
      if (session.user.id.isEmpty && store?.user != null) {
        session = AuthSession(
          accessToken: session.accessToken,
          refreshToken: session.refreshToken,
          user: store!.user!,
        );
      }
      if (session.accessToken.isEmpty) {
        return null;
      }
      await _applySession(session);
      return session;
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        // Dead session (revoked / expired / reuse-detected).
        await _clearSession();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _applySession(AuthSession session) async {
    if (getIt.isRegistered<SessionCubit>()) {
      await getIt<SessionCubit>().applySession(session);
      return;
    }
    await _sessionStore?.save(session);
  }

  Future<void> _clearSession() async {
    if (getIt.isRegistered<SessionCubit>()) {
      await getIt<SessionCubit>().clear();
      return;
    }
    await _sessionStore?.clear();
  }

  SessionStore? get _sessionStore {
    if (getIt.isRegistered<SessionStore>()) {
      return getIt<SessionStore>();
    }
    return null;
  }

  bool _isAuthPath(String path) {
    const authPaths = <String>[
      'auth/refresh',
      'auth/request-otp',
      'auth/verify-otp',
      'auth/login',
      'auth/signup',
      'auth/social',
      'auth/forgot-password',
    ];
    return authPaths.any(path.contains);
  }

  String? _bearerToken(RequestOptions options) {
    final header = options.headers['Authorization'];
    if (header is String && header.startsWith('Bearer ')) {
      return header.substring('Bearer '.length);
    }
    return null;
  }
}
