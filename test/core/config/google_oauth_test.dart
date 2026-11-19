import 'package:arana360/core/config/app_config.dart';
import 'package:arana360/core/config/google_oauth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GoogleOAuth', () {
    test('keeps Android and iOS client IDs distinct', () {
      expect(GoogleOAuth.androidClientId, contains('7e8rtcsr5p29ne8vbsbp2h57opmq79p2'));
      expect(GoogleOAuth.iosClientId, contains('morcmf0fm6lbhotqq1mo4n5op1nvdo46'));
      expect(GoogleOAuth.androidClientId, isNot(GoogleOAuth.iosClientId));
    });

    test('reversed iOS URL scheme matches the iOS client ID', () {
      const suffix = '.apps.googleusercontent.com';
      expect(GoogleOAuth.iosClientId, endsWith(suffix));
      final prefix = GoogleOAuth.iosClientId.substring(
        0,
        GoogleOAuth.iosClientId.length - suffix.length,
      );
      expect(
        GoogleOAuth.iosReversedClientId,
        'com.googleusercontent.apps.$prefix',
      );
    });

    test('audience list is the Android and iOS clients', () {
      expect(
        GoogleOAuth.audienceList.split(','),
        [GoogleOAuth.androidClientId, GoogleOAuth.iosClientId],
      );
    });
  });

  group('AppConfig Google Sign-In', () {
    test('is configured from the compiled Android and iOS client IDs', () {
      expect(AppConfig.isGoogleSignInConfigured, isTrue);
      expect(AppConfig.googleAndroidClientId, GoogleOAuth.androidClientId);
      expect(AppConfig.googleIosClientId, GoogleOAuth.iosClientId);
    });

    test('ID-token audience prefers the Android client when no Web client is set', () {
      expect(AppConfig.googleServerClientId, isEmpty);
      expect(AppConfig.googleIdTokenAudience, GoogleOAuth.androidClientId);
    });
  });
}
