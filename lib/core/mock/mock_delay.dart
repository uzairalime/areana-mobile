/// Simulated network latency for mock API responses.
/// Remove mock repository branches when [AppConfig.useMockApi] is false.
class MockDelay {
  const MockDelay._();

  static const Duration duration = Duration(seconds: 2);

  static Future<T> run<T>(T Function() action) async {
    await Future<void>.delayed(duration);
    return action();
  }

  static Future<T> runAsync<T>(Future<T> Function() action) async {
    await Future<void>.delayed(duration);
    return action();
  }
}
