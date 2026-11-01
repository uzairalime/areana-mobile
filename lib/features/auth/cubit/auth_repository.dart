import '../../../core/config/app_config.dart';
import '../../../core/mock/mock_auth_data.dart';
import '../../../core/mock/mock_delay.dart';
import '../../../core/services/api_result.dart';
import '../../../core/services/session_cubit.dart';
import '../../../core/services/session_store.dart';
import '../model/auth_session.dart';
import '../model/otp_models.dart';
import 'auth_client.dart';

/// Areana player auth — same flow as user-web `/auth`:
/// email → 6-digit code → (signup fields, only when the server says the
/// account does not exist yet) → session. No password, no social.
class AuthRepository {
  const AuthRepository(this._client, this._session, this._store);

  final AuthClient _client;
  final SessionCubit _session;
  final SessionStore _store;

  Future<ApiResult<OtpRequestResponse>> requestOtp({
    required String email,
  }) {
    if (AppConfig.useMockApi) {
      return MockDelay.run(
        () => const ApiSuccess(
          OtpRequestResponse(
            message: 'Code sent',
            ttlSeconds: 600,
          ),
        ),
      );
    }
    return _client.requestOtp(email: email);
  }

  Future<ApiResult<OtpVerifyResponse>> verifyOtp({
    required String email,
    required String code,
    String? name,
    String? phone,
    String? city,
    String? referralCode,
  }) async {
    if (AppConfig.useMockApi) {
      return MockDelay.run(() {
        if (!MockAuthData.isValidOtp(code)) {
          return const ApiError<OtpVerifyResponse>(
            message: 'Invalid or expired code',
          );
        }
        // Mock rule, mirroring the web flow: the one mock account is
        // alex@pitchside.app. Any other email without name + phone is
        // a new account, so the Cubit must show the signup step.
        if ((name == null || name.isEmpty || phone == null || phone.isEmpty) &&
            email != 'alex@pitchside.app') {
          return const ApiError<OtpVerifyResponse>(
            message: 'name and phone are required for new accounts',
          );
        }
        return ApiSuccess(
          MockAuthData.verifyOtp(
            email: email,
            name: name,
            phone: phone,
            city: city,
            referralCode: referralCode,
          ),
        );
      });
    }
    return _client.verifyOtp(
      email: email,
      code: code,
      name: name,
      phone: phone,
      city: city,
      referralCode: referralCode,
    );
  }

  /// Best-effort server logout, then local clear regardless — same as
  /// web `revokePlayerSession` + `clearPlayerTokens`.
  Future<void> logout() async {
    final refreshToken = _store.refreshToken;
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _client.logout(refreshToken: refreshToken);
    }
    await _session.clear();
  }

  /// Single persist step, called by the Cubit after a successful
  /// verify (mock and real alike) — the repository itself never
  /// persists a verify result, so a session is stored exactly once.
  Future<ApiResult<AuthSession>> persistVerify(
    OtpVerifyResponse verify,
  ) async {
    final session = AuthClient.sessionFromVerify(verify);
    if (session.accessToken.isNotEmpty) {
      await _session.applySession(session);
    }
    return ApiSuccess(session);
  }
}
