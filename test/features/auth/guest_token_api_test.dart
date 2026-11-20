import 'package:arana360/core/enums/app_loading.dart';
import 'package:arana360/core/services/session_cubit.dart';
import 'package:arana360/core/services/session_store.dart';
import 'package:arana360/features/bookings/cubit/bookings_client.dart';
import 'package:arana360/features/bookings/cubit/bookings_cubit.dart';
import 'package:arana360/features/bookings/cubit/bookings_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_http_adapter.dart';
import '../../support/in_memory_secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('guest bookings cubit does not call token APIs', () async {
    final adapter = FakeHttpAdapter(
      (_) => throw StateError('bookings/me must not run while signed out'),
    );
    final dio = Dio(BaseOptions(baseUrl: 'https://audit.invalid/api/'))
      ..httpClientAdapter = adapter;
    final session = SessionCubit(
      SessionStore(secureStorage: InMemorySecureStorage()),
    );
    addTearDown(session.close);
    final cubit = BookingsCubit(
      BookingsRepository(BookingsClient(dio)),
      session,
    );
    addTearDown(cubit.close);
    await Future<void>.delayed(Duration.zero);
    expect(adapter.requests, isEmpty);
    expect(cubit.state.status, AppLoading.initial);
    expect(cubit.state.bookings, isEmpty);
  });
}
