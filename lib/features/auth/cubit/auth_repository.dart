import '../../../core/config/app_config.dart';
import '../../../core/mock/mock_auth_data.dart';
import '../../../core/mock/mock_delay.dart';
import '../../../core/services/api_result.dart';
import '../../../core/services/session_cubit.dart';
import '../../../core/services/session_store.dart';
import '../model/auth_session.dart';
import '../model/otp_models.dart';
import '../model/user_model.dart';
import 'auth_client.dart';

/// Authenticates with email OTP and saves profile details using the session.
class AuthRepository {
  const AuthRepository(this._client, this._session, this._store);

  final AuthClient _client;
  final SessionCubit _session;
  final SessionStore _store;

  UserModel? get currentUser => _store.isAuthenticated ? _store.user : null;

  Future<ApiResult<OtpRequestResponse>> requestOtp({required String email}) {
    if (AppConfig.useMockApi) {
      return MockDelay.run(
        () => const ApiSuccess(
          OtpRequestResponse(message: 'Code sent', ttlSeconds: 600),
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

  Future<ApiResult<ProfileCompletionResponse>> completeProfile({
    required String name,
    required String phone,
    String? city,
    String? referralCode,
  }) async {
    final current = currentUser;
    if (current == null) {
      return const ApiError(message: 'Please sign in again to complete your profile.');
    }
    final result = AppConfig.useMockApi
        ? await MockDelay.run(() => ApiSuccess(ProfileCompletionResponse(
            user: current.copyWith(
              name: name, phone: phone, city: city, isProfileCompleted: true,
            ),
            referralStatus: referralCode == null ? ReferralStatus.none : ReferralStatus.applied,
          )))
        : await _client.completeProfile(
            name: name, phone: phone, city: city, referralCode: referralCode,
          );
    final completion = result.dataOrNull;
    if (completion == null) return result;
    if (currentUser?.id != current.id || completion.user.id != current.id) {
      return const ApiError(message: 'Your session changed. Please sign in again.');
    }
    try {
      await _session.applyUser(completion.user);
      return result;
    } catch (error) {
      return ApiError(message: 'Could not save your profile. Please try again.', error: error);
    }
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
  Future<ApiResult<AuthSession>> persistVerify(OtpVerifyResponse verify) async {
    final session = AuthClient.sessionFromVerify(verify);
    if (session.accessToken.isEmpty || session.user.id.isEmpty) {
      return const ApiError(
        message: 'The server did not return a valid session.',
      );
    }
    try {
      await _session.applySession(session);
      return ApiSuccess(session);
    } catch (error) {
      // Do not leave a half-persisted login in memory after storage failure.
      // A newer account, if one was applied meanwhile, remains untouched.
      if (_store.accessToken == session.accessToken) {
        try {
          await _session.clear();
        } catch (_) {
          // clear() resets memory before attempting secure storage cleanup.
        }
      }
      return ApiError(
        message: 'Could not save your session. Please sign in again.',
        error: error,
      );
    }
  }
}
