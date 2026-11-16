import 'dart:convert';

import 'package:arana360/core/logger/logger.dart';
import 'package:arana360/core/services/api_dio.dart';
import 'package:arana360/core/services/api_log_interceptor.dart';
import 'package:arana360/core/services/dio_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_http_adapter.dart';

void main() {
  late Dio dio;
  late List<String> logs;

  setUp(() {
    logs = [];
    Logger.isEnabled = true;
    Logger.showTimestamp = false;
    Logger.output = logs.add;
    dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/'))
      ..interceptors.add(ApiLogInterceptor());
  });

  tearDown(() {
    dio.close(force: true);
    Logger.isEnabled = true;
    Logger.showTimestamp = true;
    Logger.output = null;
  });

  test('main and refresh transports both install HTTP logging', () {
    final clients = [DioService.create(), createApiDio()];
    for (final client in clients) {
      expect(client.interceptors.whereType<ApiLogInterceptor>(), hasLength(1));
      client.close(force: true);
    }
  });

  test(
    'request and complete response bodies have tagged console logs',
    () async {
      final longText = List.filled(3000, 'x').join();
      dio.httpClientAdapter = FakeHttpAdapter(
        (request) => jsonResponse({
          'items': [
            {'id': 'venue', 'description': longText},
          ],
        }),
      );
      final response = await dio.get<dynamic>(
        'venues',
        queryParameters: {'sport': 'Football'},
      );
      expect(logs, hasLength(2));
      final output = logs.join('\n');
      expect(output, contains('[HTTP_REQUEST]'));
      expect(output, contains('[HTTP_RESPONSE]'));
      expect(output, contains('"statusCode": 200'));
      expect(output, contains('"elapsedMs":'));
      expect(output, contains('Football'));
      expect(output, contains(longText));
      expect(response.data['items'][0]['description'], longText);
    },
  );

  test('credentials are masked in URLs, nested bodies and raw JSON', () async {
    final request = {
      'code': 'otp-secret',
      'profile': {'password': 'password-secret', 'name': 'Player'},
    };
    dio.httpClientAdapter = FakeHttpAdapter(
      (_) => jsonResponse({
        'accessToken': 'access-secret',
        'nested': [
          {'refresh_token': 'refresh-secret'},
        ],
        'user': {'name': 'Player'},
      }),
    );
    final response = await dio.post<dynamic>(
      'auth/verify-otp',
      data: jsonEncode(request),
      queryParameters: {'token': 'query-secret'},
      options: Options(headers: {'Authorization': 'Bearer header-secret'}),
    );
    final output = logs.join('\n');
    for (final secret in [
      'otp-secret',
      'password-secret',
      'access-secret',
      'refresh-secret',
      'query-secret',
      'header-secret',
    ]) {
      expect(output, isNot(contains(secret)));
    }
    expect(output, contains('REDACTED'));
    expect(output, contains('Player'));
    expect(request['code'], 'otp-secret');
    expect(response.data['accessToken'], 'access-secret');
  });

  test('HTTP failures log status and sanitized server errors', () async {
    dio.httpClientAdapter = FakeHttpAdapter(
      (_) => jsonResponse({
        'message': 'Invalid code',
        'otp': 'hidden-otp',
      }, statusCode: 400),
    );
    await expectLater(
      dio.post<dynamic>('auth/verify-otp'),
      throwsA(isA<DioException>()),
    );
    final output = logs.join('\n');
    expect(output, contains('[HTTP_ERROR]'));
    expect(output, contains('"statusCode": 400'));
    expect(output, contains('Invalid code'));
    expect(output, isNot(contains('hidden-otp')));
  });

  test('multipart logs metadata without consuming file content', () async {
    final form = FormData.fromMap({
      'password': 'form-secret',
      'name': 'Player',
      'file': MultipartFile.fromString(
        'private-file-content',
        filename: 'photo.txt',
      ),
    });
    dio.httpClientAdapter = FakeHttpAdapter((_) => jsonResponse({'ok': true}));
    await dio.post<dynamic>('upload', data: form);
    final output = logs.join('\n');
    expect(output, contains('photo.txt'));
    expect(output, contains('Player'));
    expect(output, isNot(contains('form-secret')));
    expect(output, isNot(contains('private-file-content')));
    expect(form.fields.first.value, 'form-secret');
  });

  test('logging can be disabled without changing network results', () async {
    Logger.isEnabled = false;
    dio.httpClientAdapter = FakeHttpAdapter((_) => jsonResponse({'ok': true}));
    final response = await dio.get<dynamic>('venues');
    expect(response.data, {'ok': true});
    expect(logs, isEmpty);
  });
}
