import 'package:equatable/equatable.dart';

enum ExplorePageTab { courts, map }

extension ExplorePageTabX on ExplorePageTab {
  String get label => switch (this) {
    .courts => 'Courts',
    .map => 'Map',
  };
}

/// Criteria applied back from search (empty until user picks a place).
class ExploreSearchCriteria extends Equatable {
  const ExploreSearchCriteria({
    this.location = '',
    this.placeId = '',
    this.dateLabel = '',
    this.players,
  });

  final String location;
  final String placeId;
  final String dateLabel;
  final int? players;

  bool get hasLocation => location.trim().isNotEmpty;

  bool get isNearby {
    final id = placeId.trim().toLowerCase();
    if (id == 'nearby') return true;
    final label = location.trim().toLowerCase();
    return label == 'nearby' || label == 'near me';
  }

  String get playersLabel {
    final count = players;
    if (count == null) return '';
    return count == 1 ? '1 player' : '$count players';
  }

  /// Compact pill text — never invents placeholder cities.
  String get pillSummary {
    if (!hasLocation) return '';
    final parts = <String>[location.split(',').first.trim()];
    if (players != null) parts.add(playersLabel);
    if (dateLabel.trim().isNotEmpty) parts.add(dateLabel.trim());
    return parts.join(' · ');
  }

  ExploreSearchCriteria copyWith({
    String? location,
    String? placeId,
    String? dateLabel,
    int? players,
    bool clearPlayers = false,
  }) {
    return ExploreSearchCriteria(
      location: location ?? this.location,
      placeId: placeId ?? this.placeId,
      dateLabel: dateLabel ?? this.dateLabel,
      players: clearPlayers ? null : (players ?? this.players),
    );
  }

  @override
  List<Object?> get props => [location, placeId, dateLabel, players];
}

enum ExploreSearchSection { where, when, who }
