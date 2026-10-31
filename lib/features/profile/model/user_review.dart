import 'package:equatable/equatable.dart';

class UserReview extends Equatable {
  const UserReview({
    required this.id,
    required this.venueId,
    required this.venueName,
    required this.dateLabel,
    required this.body,
    this.rating = 0,
    this.recommended = true,
    this.pending = false,
    this.promptTitle = '',
    this.promptBody = '',
  });

  factory UserReview.fromJson(Map<String, dynamic> json) {
    return UserReview(
      id: json['id']?.toString() ?? '',
      venueId: json['venue_id']?.toString() ?? '',
      venueName: json['venue_name'] as String? ?? '',
      dateLabel: json['date_label'] as String? ?? '',
      body: json['body'] as String? ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      recommended: json['recommended'] as bool? ?? true,
      pending: json['pending'] as bool? ?? false,
      promptTitle: json['prompt_title'] as String? ?? '',
      promptBody: json['prompt_body'] as String? ?? '',
    );
  }

  final String id;
  final String venueId;
  final String venueName;
  final String dateLabel;
  final String body;

  /// 1–5 star score; `0` when not set (pending prompts).
  final int rating;
  final bool recommended;
  final bool pending;
  final String promptTitle;
  final String promptBody;

  /// Clamped display score for star UI.
  int get displayRating => rating.clamp(0, 5);

  Map<String, dynamic> toJson() => {
    'id': id,
    'venue_id': venueId,
    'venue_name': venueName,
    'date_label': dateLabel,
    'body': body,
    'rating': rating,
    'recommended': recommended,
    'pending': pending,
    'prompt_title': promptTitle,
    'prompt_body': promptBody,
  };

  @override
  List<Object?> get props => [
    id,
    venueId,
    venueName,
    dateLabel,
    body,
    rating,
    recommended,
    pending,
  ];
}
