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

  /// When true, repositories serve delayed mock data instead of Dio.
  /// Flip to false in config when the real API is ready.
  static const bool useMockApi = bool.fromEnvironment(
    'USE_MOCK_API',
    defaultValue: false,
  );

  static bool get isDevelopment => flavor == 'development';

  static bool get isProduction => flavor == 'production';
}
