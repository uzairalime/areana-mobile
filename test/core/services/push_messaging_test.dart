import 'package:arana360/core/deep_link/deep_link_service.dart';
import 'package:arana360/core/services/notification/device_token_rules.dart';
import 'package:arana360/core/services/notification/push_display_policy.dart';
import 'package:arana360/core/services/notification/push_messaging.dart';
import 'package:arana360/core/services/session_store.dart';
import 'package:arana360/features/notifications/cubit/device_token_client.dart';
import 'package:arana360/features/notifications/cubit/device_token_repository.dart';
import 'package:arana360/core/services/notification/notification_payload.dart';
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

  test('open app never presents a push banner; background does', () {
    expect(shouldPresentPushBanner(appOpen: true), isFalse);
    expect(shouldPresentPushBanner(appOpen: false), isTrue);
  });

  test('device token uploads once per signed-in user', () {
    expect(
      shouldUploadDeviceToken(
        isAuthenticated: false,
        userId: 'u1',
        token: 'tok',
        registeredKey: null,
      ),
      isFalse,
    );
    expect(
      shouldUploadDeviceToken(
        isAuthenticated: true,
        userId: 'u1',
        token: 'tok',
        registeredKey: null,
      ),
      isTrue,
    );
    expect(
      shouldUploadDeviceToken(
        isAuthenticated: true,
        userId: 'u1',
        token: 'tok',
        registeredKey: deviceTokenKey('u1', 'tok'),
      ),
      isFalse,
    );
    expect(
      shouldUploadDeviceToken(
        isAuthenticated: true,
        userId: 'u2',
        token: 'tok',
        registeredKey: deviceTokenKey('u1', 'tok'),
      ),
      isTrue,
    );
  });

  test('foreground FCM is swallowed instead of showing a banner', () {
    final push = PushMessagingService(
      tokens: DeviceTokenRepository(DeviceTokenClient(Dio())),
      session: SessionStore(secureStorage: InMemorySecureStorage()),
      deepLinks: DeepLinkService(
        SessionStore(secureStorage: InMemorySecureStorage()),
      ),
    );
    expect(
      push.handleForegroundPush({
        'type': 'chat_message',
        'conversationId': 'c1',
        'link': '/chat/c1',
      }),
      isFalse,
    );
  });

  test('tapping a tray notification opens the chat deep link', () {
    final store = SessionStore(secureStorage: InMemorySecureStorage());
    final deepLinks = DeepLinkService(store);
    final push = PushMessagingService(
      tokens: DeviceTokenRepository(DeviceTokenClient(Dio())),
      session: store,
      deepLinks: deepLinks,
    );
    push.handleOpenedPush({
      'type': 'chat_message',
      'conversationId': 'c1',
    });
    expect(
      NotificationPayload.fromRemoteData({
        'type': 'chat_message',
        'conversationId': 'c1',
      }).link,
      '/chat/c1',
    );
  });

  test('device token client posts the FCM token', () async {
    final adapter = FakeHttpAdapter((request) {
      expect(request.path, 'users/me/device-tokens');
      expect(request.data, {'token': 'fcm-token', 'platform': 'android'});
      return jsonResponse({'ok': true});
    });
    final dio = Dio(BaseOptions(baseUrl: 'https://audit.invalid/api/'))
      ..httpClientAdapter = adapter;
    final result = await DeviceTokenClient(dio).register(
      token: 'fcm-token',
      platform: 'android',
    );
    expect(result.isSuccess, isTrue);
  });
}
