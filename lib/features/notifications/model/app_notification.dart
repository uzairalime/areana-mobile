import 'package:equatable/equatable.dart';

import 'notification_type.dart';

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.group,
    this.isRead = false,
    this.link = '',
  });

  /// Server shape (user-web `PlayerNotification`): id, type, title,
  /// body, data, readAt, createdAt. Group + time labels are derived
  /// from createdAt — the server sends no group or link field.
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final createdAt =
        DateTime.tryParse(json['createdAt'] as String? ?? '') ??
        DateTime.now();
    final data = json['data'];
    final dataMap = data is Map ? Map<String, dynamic>.from(data) : const {};
    final link =
        dataMap['link']?.toString() ?? dataMap['url']?.toString() ?? '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(createdAt.year, createdAt.month, createdAt.day);
    final group = day == today
        ? 'Today'
        : day == today.subtract(const Duration(days: 1))
            ? 'Yesterday'
            : '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
    return AppNotification(
      id: json['id']?.toString() ?? '',
      type: NotificationTypeX.fromJson(json['type'] as String?),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      timeLabel:
          '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}',
      group: group,
      isRead: json['readAt'] != null,
      link: link,
    );
  }

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String timeLabel;
  final String group;
  final bool isRead;

  /// Path or absolute URL opened via [DeepLinkService] (ReelStay-style).
  final String link;

  bool get isUnread => !isRead;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.apiValue,
    'title': title,
    'body': body,
    'time_label': timeLabel,
    'group': group,
    'is_read': isRead,
    'link': link,
  };

  AppNotification copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? body,
    String? timeLabel,
    String? group,
    bool? isRead,
    String? link,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      timeLabel: timeLabel ?? this.timeLabel,
      group: group ?? this.group,
      isRead: isRead ?? this.isRead,
      link: link ?? this.link,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    title,
    body,
    timeLabel,
    group,
    isRead,
    link,
  ];
}
