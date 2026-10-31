import 'package:equatable/equatable.dart';

enum SlotStatus { open, booked }

class TimeSlot extends Equatable {
  const TimeSlot({
    required this.id,
    required this.label,
    required this.price,
    this.status = SlotStatus.open,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id']?.toString() ?? '',
      label: json['label'] as String? ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      status: (json['status'] as String?) == 'booked'
          ? SlotStatus.booked
          : SlotStatus.open,
    );
  }

  final String id;
  final String label;
  final int price;
  final SlotStatus status;

  bool get isBooked => status == SlotStatus.booked;

  @override
  List<Object?> get props => [id, label, price, status];
}
