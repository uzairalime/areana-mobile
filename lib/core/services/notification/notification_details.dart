import 'dart:ui' show Color;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../features/notifications/model/notification_type.dart';
import '../../consts/app_colors.dart';

/// Android channels + platform details keyed by [NotificationType].
///
/// When the API is ready, keep sending `type` as the channel key — no UI change.
class NotificationDetailsProvider {
  const NotificationDetailsProvider._();

  static const icon = '@drawable/ic_notification';
  static const accentColor = AppColors.primary;

  static const initializeSettings = InitializationSettings(
    android: AndroidInitializationSettings(icon),
    iOS: DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    ),
  );

  static AndroidNotificationChannel channelFor(NotificationType type) {
    return AndroidNotificationChannel(
      type.channelId,
      type.channelName,
      description: type.channelDescription,
      importance: Importance.high,
      playSound: true,
    );
  }

  static List<AndroidNotificationChannel> get allChannels => [
    for (final type in NotificationType.values) channelFor(type),
  ];

  static NotificationDetails forType(
    NotificationType type, {
    required String body,
  }) {
    final channel = channelFor(type);
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        showWhen: true,
        icon: icon,
        color: const Color(0xFF0F3D2B),
        styleInformation: BigTextStyleInformation(body),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }
}

extension NotificationTypeChannelX on NotificationType {
  String get channelId => 'pitchside_$apiValue';

  String get channelName => switch (this) {
    .booking => 'Bookings',
    .reminder => 'Reminders',
    .offer => 'Offers',
    .update => 'Updates',
    .cancel => 'Cancellations',
  };

  String get channelDescription => switch (this) {
    .booking => 'Booking confirmations and court updates',
    .reminder => 'Reminders before your slot starts',
    .offer => 'Venue deals and new openings',
    .update => 'Slot time and venue changes',
    .cancel => 'Cancelled bookings',
  };
}
