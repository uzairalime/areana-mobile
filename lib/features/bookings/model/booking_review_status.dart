/// Review state for a completed booking.
/// Cancelled bookings never expose review UI.
enum BookingReviewStatus { none, recommended, notRecommended }

extension BookingReviewStatusX on BookingReviewStatus {
  static BookingReviewStatus fromJson(String? raw) => switch (raw) {
    'recommended' || 'positive' || 'up' => .recommended,
    'not_recommended' || 'negative' || 'down' => .notRecommended,
    _ => .none,
  };

  String get apiValue => switch (this) {
    .none => 'none',
    .recommended => 'recommended',
    .notRecommended => 'not_recommended',
  };

  bool get isReviewed => this != .none;
}
