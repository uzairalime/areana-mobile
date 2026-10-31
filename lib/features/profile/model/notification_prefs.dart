import 'package:equatable/equatable.dart';

class NotificationPrefs extends Equatable {
  const NotificationPrefs({
    this.pushBooking = true,
    this.pushOffers = true,
    this.pushChat = true,
    this.emailReceipts = true,
    this.emailUpdates = true,
  });

  factory NotificationPrefs.fromJson(Map<String, dynamic> json) {
    return NotificationPrefs(
      pushBooking: json['push_booking'] as bool? ?? true,
      pushOffers: json['push_offers'] as bool? ?? true,
      pushChat: json['push_chat'] as bool? ?? true,
      emailReceipts: json['email_receipts'] as bool? ?? true,
      emailUpdates: json['email_updates'] as bool? ?? true,
    );
  }

  final bool pushBooking;
  final bool pushOffers;
  final bool pushChat;
  final bool emailReceipts;
  final bool emailUpdates;

  NotificationPrefs copyWith({
    bool? pushBooking,
    bool? pushOffers,
    bool? pushChat,
    bool? emailReceipts,
    bool? emailUpdates,
  }) {
    return NotificationPrefs(
      pushBooking: pushBooking ?? this.pushBooking,
      pushOffers: pushOffers ?? this.pushOffers,
      pushChat: pushChat ?? this.pushChat,
      emailReceipts: emailReceipts ?? this.emailReceipts,
      emailUpdates: emailUpdates ?? this.emailUpdates,
    );
  }

  Map<String, dynamic> toJson() => {
    'push_booking': pushBooking,
    'push_offers': pushOffers,
    'push_chat': pushChat,
    'email_receipts': emailReceipts,
    'email_updates': emailUpdates,
  };

  @override
  List<Object?> get props => [
    pushBooking,
    pushOffers,
    pushChat,
    emailReceipts,
    emailUpdates,
  ];
}
