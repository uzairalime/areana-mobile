import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../home/model/venue.dart';
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

String _fmtMinutes(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}

/// Player booking, mirroring user-web `PlayerBooking`.
/// UI labels are derived from the server fields, never invented.
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
    this.courtId = '',
    this.shareCode,
    this.hasReviewed = false,
    this.venueLat,
    this.venueLng,
    this.participantCount = 0,
    this.gamePostId,
    this.expiresAt,
  });

  factory UserBooking.fromJson(Map<String, dynamic> json) {
    final venue = json['venue'];
    final venueMap = venue is Map ? Map<String, dynamic>.from(venue) : const {};
    final court = json['court'];
    final courtMap = court is Map ? Map<String, dynamic>.from(court) : const {};
    final gamePost = json['gamePost'];
    final gameMap =
        gamePost is Map ? Map<String, dynamic>.from(gamePost) : const {};
    final images = venueMap['images'];
    final imageList = images is List
        ? images.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
        : const <String>[];
    final date = json['date']?.toString() ?? '';
    final start = (json['startMinutes'] as num?)?.toInt() ?? 0;
    final end = (json['endMinutes'] as num?)?.toInt() ?? start;
    final count = json['_count'];
    final countMap = count is Map ? Map<String, dynamic>.from(count) : const {};
    DateTime occurred;
    try {
      final parts = date.split('-');
      occurred = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
        start ~/ 60,
        start % 60,
      );
    } catch (_) {
      occurred = DateTime.now();
    }
    final hasReviewed = json['hasReviewed'] as bool? ?? false;
    return UserBooking(
      id: json['id']?.toString() ?? '',
      code: json['checkInCode']?.toString() ?? '',
      venueId: json['venueId']?.toString() ?? '',
      venueName: venueMap['name']?.toString() ?? '',
      sport: courtMap['sport']?.toString() ?? '',
      location: [
        venueMap['address']?.toString() ?? '',
        venueMap['city']?.toString() ?? '',
      ].where((e) => e.isNotEmpty).join(', '),
      dateLabel: date,
      timeLabel: '${_fmtMinutes(start)} – ${_fmtMinutes(end)}',
      courtLabel: courtMap['name']?.toString() ?? '',
      durationLabel: '${end - start} min',
      amountDue: (json['totalPrice'] as num?)?.toInt() ?? 0,
      payAtGround: true,
      status: UserBookingStatusX.fromJson(json['status'] as String?),
      heroColor: AppColors.primary,
      imageUrl: imageList.isEmpty ? '' : imageList.first,
      reviewStatus:
          hasReviewed ? BookingReviewStatus.recommended : .none,
      occurredAt: occurred,
      courtId: json['courtId']?.toString() ?? '',
      shareCode: json['shareCode'] as String?,
      hasReviewed: hasReviewed,
      venueLat: venueMap['lat'] is num
          ? (venueMap['lat'] as num).toDouble()
          : null,
      venueLng: venueMap['lng'] is num
          ? (venueMap['lng'] as num).toDouble()
          : null,
      participantCount: (countMap['participants'] as num?)?.toInt() ?? 0,
      gamePostId: gameMap['id']?.toString(),
      expiresAt: json['expiresAt'] as String?,
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
  final String courtId;
  final String? shareCode;
  final bool hasReviewed;
  final double? venueLat;
  final double? venueLng;
  final int participantCount;
  final String? gamePostId;
  final String? expiresAt;

  bool get isUpcoming => status.isUpcomingTab;
  bool get isPast => status.isPastTab;

  /// Review CTA only for completed bookings, one review per booking
  /// (server enforces it with a 409 on duplicates).
  bool get canAddReview => status == .completed && !hasReviewed;

  bool get isReviewed => status == .completed && hasReviewed;

  /// Confirmed / pending can reschedule or cancel.
  bool get canModify => status == .confirmed || status == .pending;

  String get scheduleLine => '$dateLabel · $timeLabel';

  int get year => occurredAt.year;

  bool get hasCoordinates => venueLat != null && venueLng != null;

  /// Venue row for rebook / map, filled from this booking's venue.
  Venue toVenue() => Venue(
    id: venueId,
    name: venueName,
    sport: sport,
    location: location,
    priceFrom: 0,
    amenities: const [],
    nextSlot: '',
    heroColor: AppColors.primary,
    latitude: venueLat ?? 0,
    longitude: venueLng ?? 0,
    imageUrls: imageUrl.isEmpty ? const [] : [imageUrl],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'checkInCode': code,
    'venueId': venueId,
    'venueName': venueName,
    'sport': sport,
    'location': location,
    'date': dateLabel,
    'time': timeLabel,
    'court': courtLabel,
    'amountDue': amountDue,
    'status': status.apiValue,
    'reviewStatus': reviewStatus.apiValue,
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
    String? courtId,
    String? shareCode,
    bool? hasReviewed,
    double? venueLat,
    double? venueLng,
    int? participantCount,
    String? gamePostId,
    String? expiresAt,
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
      courtId: courtId ?? this.courtId,
      shareCode: shareCode ?? this.shareCode,
      hasReviewed: hasReviewed ?? this.hasReviewed,
      venueLat: venueLat ?? this.venueLat,
      venueLng: venueLng ?? this.venueLng,
      participantCount: participantCount ?? this.participantCount,
      gamePostId: gamePostId ?? this.gamePostId,
      expiresAt: expiresAt ?? this.expiresAt,
    );
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
