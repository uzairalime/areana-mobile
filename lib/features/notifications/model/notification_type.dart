import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';

/// Server `type` values for a notification row.
enum NotificationType { booking, reminder, offer, update, cancel }

extension NotificationTypeX on NotificationType {
  static NotificationType fromJson(String? raw) => switch (raw) {
    'reminder' => .reminder,
    'offer' => .offer,
    'update' => .update,
    'cancel' => .cancel,
    'booking' || _ => .booking,
  };

  String get apiValue => switch (this) {
    .booking => 'booking',
    .reminder => 'reminder',
    .offer => 'offer',
    .update => 'update',
    .cancel => 'cancel',
  };

  /// Filter chip category — booking-related vs offers.
  NotificationFilterCategory get category => switch (this) {
    .offer => .offer,
    .booking || .reminder || .update || .cancel => .booking,
  };

  Color get iconBg => switch (this) {
    .booking => AppColors.footballSoft,
    .reminder => AppColors.padelSoft,
    .offer => AppColors.cricketSoft,
    .update => AppColors.courtsSoft,
    .cancel => const Color(0xFFFEE4E2),
  };

  Color get iconFg => switch (this) {
    .booking => AppColors.football,
    .reminder => AppColors.padel,
    .offer => AppColors.cricket,
    .update => AppColors.courts,
    .cancel => const Color(0xFFB42318),
  };

  IconData get icon => switch (this) {
    .booking => Icons.event_available_rounded,
    .reminder => Icons.schedule_rounded,
    .offer => Icons.local_offer_outlined,
    .update => Icons.sync_rounded,
    .cancel => Icons.cancel_outlined,
  };
}

/// Chip filter categories used by the notifications screen.
enum NotificationFilterCategory { booking, offer }
