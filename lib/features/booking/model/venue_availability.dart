import 'package:equatable/equatable.dart';

import 'booking_date.dart';
import 'court_option.dart';
import 'time_slot.dart';

class VenueAvailability extends Equatable {
  const VenueAvailability({
    required this.courts,
    required this.dates,
    required this.durations,
    required this.slots,
  });

  factory VenueAvailability.fromJson(Map<String, dynamic> json) {
    return VenueAvailability(
      courts: (json['courts'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((item) => CourtOption.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      dates: (json['dates'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((item) => BookingDate.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      durations: (json['durations'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      slots: (json['slots'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((item) => TimeSlot.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }

  final List<CourtOption> courts;
  final List<BookingDate> dates;
  final List<String> durations;
  final List<TimeSlot> slots;

  @override
  List<Object?> get props => [courts, dates, durations, slots];
}
