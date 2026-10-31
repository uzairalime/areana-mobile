import 'package:equatable/equatable.dart';

class BookingDate extends Equatable {
  const BookingDate({
    required this.id,
    required this.weekday,
    required this.day,
    required this.month,
    required this.fullLabel,
  });

  factory BookingDate.fromJson(Map<String, dynamic> json) {
    return BookingDate(
      id: json['id']?.toString() ?? '',
      weekday: json['weekday'] as String? ?? '',
      day: json['day'] as String? ?? '',
      month: json['month'] as String? ?? '',
      fullLabel: json['full_label'] as String? ?? '',
    );
  }

  final String id;
  final String weekday;
  final String day;
  final String month;
  final String fullLabel;

  @override
  List<Object?> get props => [id, weekday, day, month, fullLabel];
}
