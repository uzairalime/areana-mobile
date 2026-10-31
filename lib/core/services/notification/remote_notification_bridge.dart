import '../../../features/notifications/model/notification_type.dart';
import 'notification_payload.dart';
import 'notification_service.dart';

/// Thin adapter for when FCM / API push is wired.
///
/// Pass the remote `data` map as-is; [NotificationPayload.fromRemoteData]
/// already maps `type`, `link`/`url`/`deep_link`, and `id`.
class RemoteNotificationBridge {
  const RemoteNotificationBridge(this._notifications);

  final NotificationService _notifications;

  Future<void> showFromRemoteData({
    required Map<String, dynamic> data,
    String? title,
    String? body,
  }) {
    final payload = NotificationPayload.fromRemoteData(data);
    return _notifications.show(
      type: payload.type,
      title: title?.trim().isNotEmpty == true
          ? title!.trim()
          : _fallbackTitle(payload.type),
      body: body?.trim() ?? '',
      link: payload.link,
      id: payload.id,
    );
  }

  static String _fallbackTitle(NotificationType type) => switch (type) {
    .booking => 'Booking update',
    .reminder => 'Court reminder',
    .offer => 'New offer',
    .update => 'Slot update',
    .cancel => 'Booking cancelled',
  };
}
