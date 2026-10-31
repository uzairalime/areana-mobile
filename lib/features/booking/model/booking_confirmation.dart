import 'package:equatable/equatable.dart';

class BookingConfirmation extends Equatable {
  const BookingConfirmation({
    required this.code,
    required this.venueName,
    required this.sport,
    required this.location,
    required this.dateLabel,
    required this.timeLabel,
    required this.courtLabel,
    required this.durationLabel,
    required this.amountDue,
    required this.payAtGround,
  });

  factory BookingConfirmation.fromJson(Map<String, dynamic> json) {
    return BookingConfirmation(
      code: json['code'] as String? ?? '',
      venueName: json['venue_name'] as String? ?? '',
      sport: json['sport'] as String? ?? '',
      location: json['location'] as String? ?? '',
      dateLabel: json['date_label'] as String? ?? '',
      timeLabel: json['time_label'] as String? ?? '',
      courtLabel: json['court_label'] as String? ?? '',
      durationLabel: json['duration_label'] as String? ?? '',
      amountDue: (json['amount_due'] as num?)?.toInt() ?? 0,
      payAtGround: json['pay_at_ground'] as bool? ?? true,
    );
  }

  final String code;
  final String venueName;
  final String sport;
  final String location;
  final String dateLabel;
  final String timeLabel;
  final String courtLabel;
  final String durationLabel;
  final int amountDue;
  final bool payAtGround;

  @override
  List<Object?> get props => [code, venueName, amountDue];
}
