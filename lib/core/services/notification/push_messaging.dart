import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../../features/notifications/cubit/device_token_repository.dart';
import '../../deep_link/deep_link_service.dart';
import '../session_store.dart';
import 'device_token_rules.dart';
import 'notification_payload.dart';
import 'push_display_policy.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // OS already presented the notification payload while the app is
  // backgrounded or killed. Do not show a second local banner.
}

/// FCM on Android + iOS, modeled on ReelStay:
/// permission, APNs wait, token upload, tap → deep link.
/// Difference: while the app is open, banners are suppressed.
class PushMessagingService {
  PushMessagingService({
    required this.tokens,
    required this.session,
    required this.deepLinks,
    this.messaging,
  });

  static const _tag = 'PushMessaging';
  static const _apnsAttempts = 10;
  static const _apnsPoll = Duration(milliseconds: 500);

  final DeviceTokenRepository tokens;
  final SessionStore session;
  final DeepLinkService deepLinks;
  final FirebaseMessaging? messaging;

  var _initialized = false;
  String? _token;
  String? _registeredKey;
  StreamSubscription<String>? _tokenSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedSub;

  String? get cachedToken => _token;

  FirebaseMessaging get _fcm => messaging ?? FirebaseMessaging.instance;

  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;
    if (!await _ensureFirebase()) return;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _fcm.requestPermission(alert: true, badge: true, sound: true);
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    _foregroundSub = FirebaseMessaging.onMessage.listen(_onForeground);
    _openedSub = FirebaseMessaging.onMessageOpenedApp.listen(_onOpened);
    final initial = await _fcm.getInitialMessage();
    if (initial != null) _onOpened(initial);

    _tokenSub = _fcm.onTokenRefresh.listen(_onToken);
    if (!kIsWeb && Platform.isIOS) await _waitForApnsToken();
    await _onToken(await _safeToken());

    _initialized = true;
    debugPrint('[$_tag] Initialized');
  }

  Future<void> sync() async {
    await _onToken(_token ?? await _safeToken());
  }

  void reset() {
    _registeredKey = null;
    _token = null;
  }

  Future<void> dispose() async {
    await _tokenSub?.cancel();
    await _foregroundSub?.cancel();
    await _openedSub?.cancel();
  }

  /// Test seam: FCM `onMessage` while the app is open.
  @visibleForTesting
  bool handleForegroundPush(Map<String, dynamic> data) {
    if (!shouldPresentPushBanner(appOpen: true)) {
      debugPrint('[$_tag] Foreground push suppressed type=${data['type']}');
      return false;
    }
    return true;
  }

  /// Test seam: user tapped a tray notification.
  @visibleForTesting
  void handleOpenedPush(Map<String, dynamic> data) {
    final link = NotificationPayload.fromRemoteData(data).link;
    if (link.isEmpty) return;
    unawaited(deepLinks.handleRaw(link));
  }

  void _onForeground(RemoteMessage message) {
    handleForegroundPush(Map<String, dynamic>.from(message.data));
  }

  void _onOpened(RemoteMessage message) {
    handleOpenedPush(Map<String, dynamic>.from(message.data));
  }

  Future<void> _onToken(String? token) async {
    final value = token?.trim();
    if (value == null || value.isEmpty) return;
    _token = value;
    if (!shouldUploadDeviceToken(
      isAuthenticated: session.isAuthenticated,
      userId: session.user?.id,
      token: value,
      registeredKey: _registeredKey,
    )) {
      return;
    }
    final userId = session.user!.id;
    final result = await tokens.register(
      token: value,
      platform: _platformName(),
    );
    if (result.isSuccess) {
      _registeredKey = deviceTokenKey(userId, value);
    }
  }

  Future<String?> _safeToken() async {
    try {
      return await _fcm.getToken();
    } catch (error) {
      debugPrint('[$_tag] getToken failed: $error');
      return _token;
    }
  }

  Future<void> _waitForApnsToken() async {
    for (var i = 0; i < _apnsAttempts; i++) {
      if (await _fcm.getAPNSToken() != null) return;
      await Future<void>.delayed(_apnsPoll);
    }
    debugPrint('[$_tag] APNs token not ready');
  }

  Future<bool> _ensureFirebase() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      return true;
    } catch (error, stack) {
      debugPrint('[$_tag] Firebase not configured: $error\n$stack');
      return false;
    }
  }

  String _platformName() {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'other';
  }
}
