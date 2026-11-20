import 'google_oauth.dart';

/// Runtime config from `--dart-define-from-file=config.*.json`.
class AppConfig {
  AppConfig._();

  static const String flavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'production',
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.31.147.229:3000/api/',
  );

  /// Native applicationId / bundle id. Production is
  /// `com.zorixsolutions.arana`; development uses the `.dev` suffix.
  static const String applicationId = String.fromEnvironment(
    'APPLICATION_ID',
    defaultValue: 'com.zorixsolutions.arana',
  );

  /// When true, repositories serve delayed mock data instead of Dio.
  /// Flip to false in config when the real API is ready.
  static const bool useMockApi = bool.fromEnvironment(
    'USE_MOCK_API',
    defaultValue: false,
  );

  /// Optional Web client ID. When set, both platforms request an ID
  /// token whose `aud` is this value.
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );

  static const String googleAndroidClientId = String.fromEnvironment(
    'GOOGLE_ANDROID_CLIENT_ID',
    defaultValue: GoogleOAuth.androidClientId,
  );

  static const String googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue: GoogleOAuth.iosClientId,
  );

  static bool get isGoogleSignInConfigured =>
      googleAndroidClientId.trim().isNotEmpty ||
      googleIosClientId.trim().isNotEmpty ||
      googleServerClientId.trim().isNotEmpty;

  /// Audience passed to `GoogleSignIn.initialize(serverClientId:)`.
  /// Android needs this to mint an ID token; iOS uses [googleIosClientId].
  static String get googleIdTokenAudience {
    final web = googleServerClientId.trim();
    if (web.isNotEmpty) return web;
    return googleAndroidClientId.trim();
  }

  static bool get isDevelopment => flavor == 'development';

  static bool get isProduction => flavor == 'production';

  /// Microsoft Clarity project used for session replay / heatmaps.
  static const String clarityProjectId = String.fromEnvironment(
    'CLARITY_PROJECT_ID',
    defaultValue: 'zgjyrvq7up',
  );

  static bool get isClarityEnabled => clarityProjectId.trim().isNotEmpty;
}
