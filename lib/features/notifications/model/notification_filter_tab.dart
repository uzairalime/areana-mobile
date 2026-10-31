import 'package:flutter/material.dart';

import 'notification_type.dart';

enum NotificationFilterTab { all, bookings, offers }

extension NotificationFilterTabX on NotificationFilterTab {
  String get label => switch (this) {
    .all => 'All',
    .bookings => 'Bookings',
    .offers => 'Offers',
  };

  String get emptyTitle => switch (this) {
    .all => 'You are all caught up',
    .bookings => 'No booking updates',
    .offers => 'No offers yet',
  };

  String get emptyBody => switch (this) {
    .all => 'Booking updates, reminders and offers will show up here.',
    .bookings => 'Confirmations, reminders and slot changes will land here.',
    .offers => 'Venue deals and new openings near you will show up here.',
  };

  IconData get emptyIcon => switch (this) {
    .all => Icons.notifications_none_rounded,
    .bookings => Icons.event_available_rounded,
    .offers => Icons.local_offer_outlined,
  };

  bool matches(NotificationType type) => switch (this) {
    .all => true,
    .bookings => type.category == .booking,
    .offers => type.category == .offer,
  };
}
