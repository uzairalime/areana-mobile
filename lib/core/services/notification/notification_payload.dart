import 'dart:convert';

import '../../../features/notifications/model/notification_type.dart';

/// Wire format stored in the local notification `payload`.
///
/// When push/API arrives, map server fields into this once:
/// `type` → [NotificationType], `link` → deep link, `id` → server id.
class NotificationPayload {
  const NotificationPayload({
    required this.type,
    this.link = '',
    this.id = '',
  });

  factory NotificationPayload.fromJson(Map<String, dynamic> json) {
    return NotificationPayload(
      type: NotificationTypeX.fromJson(json['type'] as String?),
      link: json['link'] as String? ?? json['url'] as String? ?? '',
      id: json['id']?.toString() ?? '',
    );
  }

  /// Accepts either our JSON payload or a bare deep-link path/URL.
  factory NotificationPayload.parse(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) {
      return const NotificationPayload(type: .booking);
    }
    if (value.startsWith('{')) {
      try {
        final map = jsonDecode(value);
        if (map is Map) {
          return NotificationPayload.fromJson(
            Map<String, dynamic>.from(map),
          );
        }
      } catch (_) {
        // Fall through to treat as deep link.
      }
    }
    return NotificationPayload(type: .booking, link: value);
  }

  /// Build from a future FCM / API data map (same keys ReelStay uses).
  factory NotificationPayload.fromRemoteData(Map<String, dynamic> data) {
    final link = data['link'] ?? data['url'] ?? data['deep_link'];
    return NotificationPayload(
      type: NotificationTypeX.fromJson(data['type'] as String?),
      link: link?.toString() ?? '',
      id: data['id']?.toString() ??
          data['notification_id']?.toString() ??
          '',
    );
  }

  final NotificationType type;
  final String link;
  final String id;

  Map<String, dynamic> toJson() => {
    'type': type.apiValue,
    'link': link,
    'id': id,
  };

  String encode() => jsonEncode(toJson());
}
