import 'package:equatable/equatable.dart';

enum ExplorePageTab { venues, map }

extension ExplorePageTabX on ExplorePageTab {
  String get label => switch (this) {
    .venues => 'Venues',
    .map => 'Map',
  };
}

/// Criteria applied back from search (empty until user picks a place).
class ExploreSearchCriteria extends Equatable {
  const ExploreSearchCriteria({
    this.location = '',
    this.placeId = '',
    this.lat,
    this.lng,
    this.radiusKm = defaultRadiusKm,
    this.dateLabel = '',
    this.players,
  });

  static const defaultRadiusKm = 50.0;

  final String location;
  final String placeId;
  final double? lat;
  final double? lng;
  final double radiusKm;
  final String dateLabel;
  final int? players;

  bool get hasLocation => location.trim().isNotEmpty;

  bool get hasCoordinates => lat != null && lng != null;

  String get playersLabel {
    final count = players;
    if (count == null) return '';
    return count == 1 ? '1 player' : '$count players';
  }

  /// Compact pill text — never invents placeholder cities.
  String get pillSummary {
    if (!hasLocation) return '';
    final parts = <String>[location.trim()];
    if (players != null) parts.add(playersLabel);
    if (dateLabel.trim().isNotEmpty) parts.add(dateLabel.trim());
    return parts.join(' · ');
  }

  ExploreSearchCriteria copyWith({
    String? location,
    String? placeId,
    double? lat,
    double? lng,
    double? radiusKm,
    String? dateLabel,
    int? players,
    bool clearPlayers = false,
    bool clearCoordinates = false,
  }) {
    return ExploreSearchCriteria(
      location: location ?? this.location,
      placeId: placeId ?? this.placeId,
      lat: clearCoordinates ? null : (lat ?? this.lat),
      lng: clearCoordinates ? null : (lng ?? this.lng),
      radiusKm: radiusKm ?? this.radiusKm,
      dateLabel: dateLabel ?? this.dateLabel,
      players: clearPlayers ? null : (players ?? this.players),
    );
  }

  @override
  List<Object?> get props => [
    location,
    placeId,
    lat,
    lng,
    radiusKm,
    dateLabel,
    players,
  ];
}
