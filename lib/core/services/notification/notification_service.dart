import 'dart:async' show unawaited;
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../../features/notifications/model/notification_type.dart';
import '../../deep_link/deep_link_service.dart';
import '../locator.dart';
import 'notification_details.dart';
import 'notification_payload.dart';

/// Local notifications setup (ReelStay-shaped, FCM-ready).
///
/// Today: permission + channels + show/schedule + tap → [DeepLinkService].
/// Later: map API/FCM `type`/`link` through [NotificationPayload.fromRemoteData]
/// and call [show] / [schedule] — no channel rework needed.
class NotificationService {
  NotificationService();

  static const _tag = 'NotificationService';

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  var _initialized = false;
  var _timezoneReady = false;

  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await _ensureTimezone();
      final granted = await requestPermission();
      await _setupPlugin();
      if (granted) {
        await _createChannels();
      }

      final launch = await _local.getNotificationAppLaunchDetails();
      final response = launch?.notificationResponse;
      if (launch?.didNotificationLaunchApp == true && response != null) {
        _onLocalTap(response);
      }

      _initialized = true;
      debugPrint('[$_tag] Initialized (permission=$granted)');
    } catch (error, stack) {
      debugPrint('[$_tag] Init failed: $error\n$stack');
    }
  }

  Future<bool> requestPermission() async {
    if (kIsWeb) return false;

    if (Platform.isIOS) {
      final ios = _local
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final granted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    if (Platform.isAndroid) {
      final android = _local
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? true;
    }

    return true;
  }

  Future<void> _setupPlugin() async {
    await _local.initialize(
      settings: NotificationDetailsProvider.initializeSettings,
      onDidReceiveNotificationResponse: _onLocalTap,
    );
  }

  Future<void> _createChannels() async {
    final android = _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return;
    for (final channel in NotificationDetailsProvider.allChannels) {
      await android.createNotificationChannel(channel);
    }
  }

  Future<void> _ensureTimezone() async {
    if (_timezoneReady) return;
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (error) {
      debugPrint('[$_tag] Timezone fallback UTC: $error');
      tz.setLocalLocation(tz.UTC);
    }
    _timezoneReady = true;
  }

  void _onLocalTap(NotificationResponse response) {
    final payload = NotificationPayload.parse(response.payload);
    debugPrint(
      '[$_tag] Tapped type=${payload.type.apiValue} link=${payload.link}',
    );
    if (payload.link.isEmpty) return;
    if (!getIt.isRegistered<DeepLinkService>()) return;
    unawaited(getIt<DeepLinkService>().handleRaw(payload.link));
  }

  /// Immediate banner. Prefer this for foreground push when FCM lands.
  Future<void> show({
    required NotificationType type,
    required String title,
    required String body,
    String? link,
    String? id,
    int? notificationId,
  }) async {
    if (!_initialized) await initialize();

    final payload = NotificationPayload(
      type: type,
      link: link ?? '',
      id: id ?? '',
    );

    await _local.show(
      id: notificationId ?? _stableId(id ?? '${type.apiValue}-$title'),
      title: title,
      body: body,
      notificationDetails: NotificationDetailsProvider.forType(
        type,
        body: body,
      ),
      payload: payload.encode(),
    );
  }

  /// Schedule a one-shot reminder (e.g. 1h before court time).
  Future<void> schedule({
    required NotificationType type,
    required DateTime when,
    required String title,
    required String body,
    required int notificationId,
    String? link,
    String? id,
  }) async {
    if (!_initialized) await initialize();
    await _ensureTimezone();
    if (!when.isAfter(DateTime.now())) return;

    final payload = NotificationPayload(
      type: type,
      link: link ?? '',
      id: id ?? '',
    );

    await _local.zonedSchedule(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(when, tz.local),
      notificationDetails: NotificationDetailsProvider.forType(
        type,
        body: body,
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload.encode(),
    );
  }

  Future<void> cancel(int notificationId) =>
      _local.cancel(id: notificationId);

  Future<void> cancelAll() => _local.cancelAll();

  /// Stable positive 32-bit id from a string (booking id, etc.).
  static int _stableId(String raw) {
    var hash = 0;
    for (final unit in raw.codeUnits) {
      hash = 0x1fffffff & (hash + unit);
      hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
      hash ^= hash >> 6;
    }
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    hash ^= hash >> 11;
    hash = 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
    return hash == 0 ? 1 : hash;
  }
}
