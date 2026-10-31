import '../../features/auth/model/social_credential.dart';
import '../../features/auth/model/social_provider.dart';
import '../config/app_config.dart';
import '../mock/mock_delay.dart';

/// Native Google / Apple SDK boundary. Swap [MockSocialAuthService] for a
/// real implementation when client IDs are ready — AuthCubit stays unchanged.
abstract class SocialAuthService {
  Future<SocialCredential?> signIn(SocialProvider provider);
}

class MockSocialAuthService implements SocialAuthService {
  const MockSocialAuthService();

  @override
  Future<SocialCredential?> signIn(SocialProvider provider) {
    return MockDelay.run(() {
      return switch (provider) {
        SocialProvider.google => const SocialCredential(
          provider: SocialProvider.google,
          providerUid: 'google_uid_mock_48213',
          email: 'alex.google@pitchside.app',
          name: 'Alex Google',
          avatarUrl: null,
          idToken: 'mock_google_id_token',
        ),
        SocialProvider.apple => const SocialCredential(
          provider: SocialProvider.apple,
          providerUid: 'apple_uid_mock_48213',
          email: 'alex.apple@pitchside.app',
          name: 'Alex Apple',
          avatarUrl: null,
          idToken: 'mock_apple_id_token',
        ),
      };
    });
  }
}

SocialAuthService createSocialAuthService() {
  // Real Google/Apple SDKs plug in here when USE_MOCK_API is false and
  // native keys exist. Until then mock keeps the flow end-to-end testable.
  if (AppConfig.useMockApi) {
    return const MockSocialAuthService();
  }
  return const MockSocialAuthService();
}
