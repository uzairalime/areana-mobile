import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import 'booking_review_status.dart';

/// Upcoming tab: [confirmed], [pending]
/// Past tab: [completed], [cancelled]
enum UserBookingStatus { confirmed, pending, completed, cancelled }

extension UserBookingStatusX on UserBookingStatus {
  String get label => switch (this) {
    .confirmed => 'Confirmed',
    .pending => 'Pending',
    .completed => 'Completed',
    .cancelled => 'Cancelled',
  };

  static UserBookingStatus fromJson(String? raw) => switch (raw) {
    'pending' => .pending,
    'completed' => .completed,
    'cancelled' => .cancelled,
    'confirmed' || 'upcoming' => .confirmed,
    _ => .confirmed,
  };

  String get apiValue => switch (this) {
    .confirmed => 'confirmed',
    .pending => 'pending',
    .completed => 'completed',
    .cancelled => 'cancelled',
  };

  bool get isUpcomingTab => this == .confirmed || this == .pending;

  bool get isPastTab => this == .completed || this == .cancelled;
}

class UserBooking extends Equatable {
  const UserBooking({
    required this.id,
    required this.code,
    required this.venueId,
    required this.venueName,
    required this.sport,
    required this.location,
    required this.dateLabel,
    required this.timeLabel,
    required this.courtLabel,
    required this.durationLabel,
    required this.amountDue,
    required this.status,
    required this.heroColor,
    required this.occurredAt,
    this.payAtGround = true,
    this.imageUrl = '',
    this.reviewStatus = .none,
  });

  factory UserBooking.fromJson(Map<String, dynamic> json) {
    return UserBooking(
      id: json['id']?.toString() ?? '',
      code: json['code'] as String? ?? '',
      venueId: json['venue_id']?.toString() ?? '',
      venueName: json['venue_name'] as String? ?? '',
      sport: json['sport'] as String? ?? '',
      location: json['location'] as String? ?? '',
      dateLabel: json['date_label'] as String? ?? '',
      timeLabel: json['time_label'] as String? ?? '',
      courtLabel: json['court_label'] as String? ?? '',
      durationLabel: json['duration_label'] as String? ?? '',
      amountDue: (json['amount_due'] as num?)?.toInt() ?? 0,
      payAtGround: json['pay_at_ground'] as bool? ?? true,
      status: UserBookingStatusX.fromJson(json['status'] as String?),
      heroColor:
          _colorFromHex(json['hero_color'] as String?) ?? AppColors.primary,
      imageUrl: json['image_url'] as String? ?? '',
      reviewStatus: BookingReviewStatusX.fromJson(
        json['review_status'] as String?,
      ),
      occurredAt:
          DateTime.tryParse(json['occurred_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  final String id;
  final String code;
  final String venueId;
  final String venueName;
  final String sport;
  final String location;
  final String dateLabel;
  final String timeLabel;
  final String courtLabel;
  final String durationLabel;
  final int amountDue;
  final bool payAtGround;
  final UserBookingStatus status;
  final Color heroColor;
  final String imageUrl;
  final BookingReviewStatus reviewStatus;
  final DateTime occurredAt;

  bool get isUpcoming => status.isUpcomingTab;
  bool get isPast => status.isPastTab;

  /// Review CTA only for completed sessions that are not reviewed yet.
  bool get canAddReview =>
      status == .completed && reviewStatus == .none;

  bool get isReviewed =>
      status == .completed && reviewStatus.isReviewed;

  /// Confirmed / pending can reschedule or cancel.
  bool get canModify => status == .confirmed || status == .pending;

  String get scheduleLine => '$dateLabel · $timeLabel';

  int get year => occurredAt.year;

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'venue_id': venueId,
    'venue_name': venueName,
    'sport': sport,
    'location': location,
    'date_label': dateLabel,
    'time_label': timeLabel,
    'court_label': courtLabel,
    'duration_label': durationLabel,
    'amount_due': amountDue,
    'pay_at_ground': payAtGround,
    'status': status.apiValue,
    'hero_color':
        '#${heroColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
    'image_url': imageUrl,
    'review_status': reviewStatus.apiValue,
    'occurred_at': occurredAt.toIso8601String(),
  };

  UserBooking copyWith({
    String? id,
    String? code,
    String? venueId,
    String? venueName,
    String? sport,
    String? location,
    String? dateLabel,
    String? timeLabel,
    String? courtLabel,
    String? durationLabel,
    int? amountDue,
    bool? payAtGround,
    UserBookingStatus? status,
    Color? heroColor,
    String? imageUrl,
    BookingReviewStatus? reviewStatus,
    DateTime? occurredAt,
  }) {
    return UserBooking(
      id: id ?? this.id,
      code: code ?? this.code,
      venueId: venueId ?? this.venueId,
      venueName: venueName ?? this.venueName,
      sport: sport ?? this.sport,
      location: location ?? this.location,
      dateLabel: dateLabel ?? this.dateLabel,
      timeLabel: timeLabel ?? this.timeLabel,
      courtLabel: courtLabel ?? this.courtLabel,
      durationLabel: durationLabel ?? this.durationLabel,
      amountDue: amountDue ?? this.amountDue,
      payAtGround: payAtGround ?? this.payAtGround,
      status: status ?? this.status,
      heroColor: heroColor ?? this.heroColor,
      imageUrl: imageUrl ?? this.imageUrl,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      occurredAt: occurredAt ?? this.occurredAt,
    );
  }

  static Color? _colorFromHex(String? value) {
    if (value == null || value.isEmpty) return null;
    var hex = value.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    final parsed = int.tryParse(hex, radix: 16);
    if (parsed == null) return null;
    return Color(parsed);
  }

  @override
  List<Object?> get props => [
    id,
    code,
    status,
    dateLabel,
    timeLabel,
    reviewStatus,
    occurredAt,
  ];
}

class PastBookingYearGroup extends Equatable {
  const PastBookingYearGroup({required this.year, required this.bookings});

  final int year;
  final List<UserBooking> bookings;

  @override
  List<Object?> get props => [year, bookings];
}
