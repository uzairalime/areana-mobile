import '../../features/auth/model/auth_session.dart';
import '../../features/auth/model/social_credential.dart';
import '../../features/auth/model/user_model.dart';

class MockAuthData {
  const MockAuthData._();

  /// Mock OTP accepted by verify endpoints.
  static const String validOtp = '123456';

  static bool isValidOtp(String otp) => otp.trim() == validOtp;

  static AuthSession login({required String identifier}) {
    return AuthSession(
      accessToken: 'mock_access_token_login',
      user: UserModel(
        id: 'user_1',
        name: 'Alex Player',
        email: identifier.contains('@') ? identifier : 'alex@pitchside.app',
        phone: identifier.contains('@') ? '03001234567' : identifier,
        provider: 'email',
      ),
    );
  }

  static AuthSession signupVerified({
    required String name,
    required String phone,
    required String email,
  }) {
    return AuthSession(
      accessToken: 'mock_access_token_signup',
      user: UserModel(
        id: 'user_1',
        name: name,
        email: email,
        phone: phone,
        provider: 'email',
      ),
    );
  }

  static AuthSession social(SocialCredential credential) {
    return AuthSession(
      accessToken: 'mock_access_token_social_${credential.provider.apiValue}',
      user: UserModel(
        id: 'user_${credential.providerUid}',
        name: credential.name.isEmpty ? 'Pitchside player' : credential.name,
        email: credential.email,
        phone: '',
        avatarUrl: credential.avatarUrl,
        provider: credential.provider.apiValue,
      ),
    );
  }

  static AuthSession resetPassword({required String email}) {
    return AuthSession(
      accessToken: 'mock_access_token_reset',
      user: UserModel(
        id: 'user_1',
        name: 'Alex Player',
        email: email,
        phone: '03001234567',
        provider: 'email',
      ),
    );
  }
}
