import 'package:equatable/equatable.dart';

import '../../../core/enums/app_loading.dart';
import '../model/app_notification.dart';
import '../model/notification_filter_tab.dart';

class NotificationsState extends Equatable {
  const NotificationsState({
    this.status = AppLoading.initial,
    this.errorMessage = '',
    this.tab = .all,
    this.items = const [],
    this.markingAllRead = false,
  });

  final AppLoading status;
  final String errorMessage;
  final NotificationFilterTab tab;
  final List<AppNotification> items;
  final bool markingAllRead;

  int get unreadCount => items.where((e) => e.isUnread).length;

  bool get hasUnread => unreadCount > 0;

  String get unreadText =>
      hasUnread ? '$unreadCount unread' : 'No unread notifications';

  List<AppNotification> get visibleItems => [
    for (final item in items)
      if (tab.matches(item.type)) item,
  ];

  /// Sectioned list: group header + rows, preserving server order.
  List<NotificationListEntry> get listEntries {
    final visible = visibleItems;
    if (visible.isEmpty) return const [];

    final entries = <NotificationListEntry>[];
    String? prevGroup;
    for (final item in visible) {
      if (item.group != prevGroup) {
        entries.add(NotificationListEntry.header(item.group));
        prevGroup = item.group;
      }
      entries.add(NotificationListEntry.item(item));
    }
    return entries;
  }

  NotificationsState copyWith({
    AppLoading? status,
    String? errorMessage,
    NotificationFilterTab? tab,
    List<AppNotification>? items,
    bool? markingAllRead,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      tab: tab ?? this.tab,
      items: items ?? this.items,
      markingAllRead: markingAllRead ?? this.markingAllRead,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    tab,
    items,
    markingAllRead,
  ];
}

sealed class NotificationListEntry {
  const NotificationListEntry();

  const factory NotificationListEntry.header(String title) =
      NotificationGroupHeader;
  const factory NotificationListEntry.item(AppNotification notification) =
      NotificationRowEntry;
}

final class NotificationGroupHeader extends NotificationListEntry {
  const NotificationGroupHeader(this.title);

  final String title;
}

final class NotificationRowEntry extends NotificationListEntry {
  const NotificationRowEntry(this.notification);

  final AppNotification notification;
}
