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

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      type: NotificationTypeX.fromJson(json['type'] as String?),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      timeLabel: json['time_label'] as String? ?? json['time'] as String? ?? '',
      group: json['group'] as String? ?? 'Earlier',
      isRead: json['is_read'] as bool? ?? json['read'] as bool? ?? false,
      link: json['link'] as String? ?? '',
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
