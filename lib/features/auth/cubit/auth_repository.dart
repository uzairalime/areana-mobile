import '../../../core/config/app_config.dart';
import '../../../core/mock/mock_auth_data.dart';
import '../../../core/mock/mock_delay.dart';
import '../../../core/services/api_result.dart';
import '../../../core/services/session_cubit.dart';
import '../../../core/services/social_auth_service.dart';
import '../model/auth_session.dart';
import '../model/social_credential.dart';
import '../model/social_provider.dart';
import 'auth_client.dart';

class AuthRepository {
  const AuthRepository(this._client, this._session, this._socialAuth);

  final AuthClient _client;
  final SessionCubit _session;
  final SocialAuthService _socialAuth;

  Future<ApiResult<AuthSession>> login({
    required String identifier,
    required String password,
  }) async {
    final result = AppConfig.useMockApi
        ? await MockDelay.run(
            () => ApiSuccess(MockAuthData.login(identifier: identifier)),
          )
        : await _client.login(identifier: identifier, password: password);
    return _persistIfSuccess(result);
  }

  Future<ApiResult<void>> signup({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) {
    if (AppConfig.useMockApi) {
      return MockDelay.run(() => const ApiSuccess(null));
    }
    return _client.signup(
      name: name,
      phone: phone,
      email: email,
      password: password,
    );
  }

  Future<ApiResult<AuthSession>> verifySignupOtp({
    required String email,
    required String otp,
    required String name,
    required String phone,
  }) async {
    final result = AppConfig.useMockApi
        ? await MockDelay.run(() {
            if (!MockAuthData.isValidOtp(otp)) {
              return const ApiError<AuthSession>(
                message: 'Invalid or expired code',
              );
            }
            return ApiSuccess(
              MockAuthData.signupVerified(
                name: name,
                phone: phone,
                email: email,
              ),
            );
          })
        : await _client.verifySignupOtp(email: email, otp: otp);
    return _persistIfSuccess(result);
  }

  Future<ApiResult<AuthSession>> socialSignIn(SocialProvider provider) async {
    try {
      final credential = await _socialAuth.signIn(provider);
      if (credential == null) {
        return const ApiError(message: 'Sign in cancelled');
      }
      return await socialWithCredential(credential);
    } catch (error) {
      return ApiError(message: error.toString(), error: error);
    }
  }

  Future<ApiResult<AuthSession>> socialWithCredential(
    SocialCredential credential,
  ) async {
    final result = AppConfig.useMockApi
        ? await MockDelay.run(() => ApiSuccess(MockAuthData.social(credential)))
        : await _client.social(credential);
    return _persistIfSuccess(result);
  }

  Future<ApiResult<void>> sendForgotOtp({required String email}) {
    if (AppConfig.useMockApi) {
      return MockDelay.run(() => const ApiSuccess(null));
    }
    return _client.sendForgotOtp(email: email);
  }

  Future<ApiResult<void>> verifyForgotOtp({
    required String email,
    required String otp,
  }) {
    if (AppConfig.useMockApi) {
      return MockDelay.run(() {
        if (!MockAuthData.isValidOtp(otp)) {
          return const ApiError<void>(message: 'Invalid or expired code');
        }
        return const ApiSuccess(null);
      });
    }
    return _client.verifyForgotOtp(email: email, otp: otp);
  }

  Future<ApiResult<AuthSession>> resetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    final result = AppConfig.useMockApi
        ? await MockDelay.run(() {
            if (!MockAuthData.isValidOtp(otp)) {
              return const ApiError<AuthSession>(
                message: 'Invalid or expired code',
              );
            }
            return ApiSuccess(MockAuthData.resetPassword(email: email));
          })
        : await _client.resetPassword(
            email: email,
            otp: otp,
            password: password,
          );
    return _persistIfSuccess(result);
  }

  Future<void> logout() => _session.clear();

  Future<ApiResult<AuthSession>> _persistIfSuccess(
    ApiResult<AuthSession> result,
  ) async {
    final session = result.dataOrNull;
    if (session != null && session.accessToken.isNotEmpty) {
      await _session.applySession(session);
    }
    return result;
  }
}
