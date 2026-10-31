/// Runtime config from `--dart-define-from-file=config.*.json`.
class AppConfig {
  AppConfig._();

  static const String flavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'production',
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.com/',
  );

  /// When true, repositories serve delayed mock data instead of Dio.
  /// Flip to false in config when the real API is ready.
  static const bool useMockApi = bool.fromEnvironment(
    'USE_MOCK_API',
    defaultValue: true,
  );

  static bool get isDevelopment => flavor == 'development';

  static bool get isProduction => flavor == 'production';
}
