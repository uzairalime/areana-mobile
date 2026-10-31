import 'package:flutter/material.dart';

enum MessageFilterTab { all, unread }

extension MessageFilterTabX on MessageFilterTab {
  String get label => switch (this) {
    .all => 'All',
    .unread => 'Unread',
  };

  String get emptyTitle => switch (this) {
    .all => 'No messages yet',
    .unread => 'All caught up',
  };

  String get emptyBody => switch (this) {
    .all => 'Venue chats and booking updates will show up here.',
    .unread => 'You have no unread conversations right now.',
  };

  IconData get emptyIcon => switch (this) {
    .all => Icons.chat_bubble_outline_rounded,
    .unread => Icons.mark_chat_read_outlined,
  };
}
