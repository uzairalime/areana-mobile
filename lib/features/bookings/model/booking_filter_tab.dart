import 'package:flutter/material.dart';

enum BookingFilterTab { upcoming, past, reviews }

extension BookingFilterTabX on BookingFilterTab {
  String get label => switch (this) {
    .upcoming => 'Upcoming',
    .past => 'Past',
    .reviews => 'Reviews',
  };

  String get emptyTitle => switch (this) {
    .upcoming => 'No upcoming bookings',
    .past => 'No past bookings',
    .reviews => 'No reviews yet',
  };

  String get emptyBody => switch (this) {
    .upcoming => 'When you lock a court, it will show up here.',
    .past => 'Finished sessions will land in this list.',
    .reviews => 'After you play, you can recommend venues here.',
  };

  IconData get emptyIcon => switch (this) {
    .upcoming => Icons.event_available_rounded,
    .past => Icons.history_rounded,
    .reviews => Icons.star_outline_rounded,
  };
}
