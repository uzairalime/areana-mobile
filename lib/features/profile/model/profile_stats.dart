import 'package:equatable/equatable.dart';

class ProfileStats extends Equatable {
  const ProfileStats({
    this.bookingsCount = 0,
    this.hoursPlayed = 0,
    this.reviewsCount = 0,
    this.savedVenuesCount = 0,
  });

  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    return ProfileStats(
      bookingsCount: (json['bookings_count'] as num?)?.toInt() ?? 0,
      hoursPlayed: (json['hours_played'] as num?)?.toInt() ?? 0,
      reviewsCount: (json['reviews_count'] as num?)?.toInt() ?? 0,
      savedVenuesCount: (json['saved_venues_count'] as num?)?.toInt() ?? 0,
    );
  }

  final int bookingsCount;
  final int hoursPlayed;
  final int reviewsCount;
  final int savedVenuesCount;

  String get hoursLabel => '$hoursPlayed h';

  ProfileStats copyWith({
    int? bookingsCount,
    int? hoursPlayed,
    int? reviewsCount,
    int? savedVenuesCount,
  }) {
    return ProfileStats(
      bookingsCount: bookingsCount ?? this.bookingsCount,
      hoursPlayed: hoursPlayed ?? this.hoursPlayed,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      savedVenuesCount: savedVenuesCount ?? this.savedVenuesCount,
    );
  }

  Map<String, dynamic> toJson() => {
    'bookings_count': bookingsCount,
    'hours_played': hoursPlayed,
    'reviews_count': reviewsCount,
    'saved_venues_count': savedVenuesCount,
  };

  @override
  List<Object?> get props => [
    bookingsCount,
    hoursPlayed,
    reviewsCount,
    savedVenuesCount,
  ];
}
