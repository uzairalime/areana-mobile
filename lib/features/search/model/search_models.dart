import 'package:equatable/equatable.dart';

import '../../home/model/venue.dart';

/// Place suggestion (mock Google Places / real Places later).
class PlaceSuggestion extends Equatable {
  const PlaceSuggestion({
    required this.id,
    required this.primaryText,
    required this.secondaryText,
  });

  /// Idle-row for GPS search — never written to recent history.
  static const nearby = PlaceSuggestion(
    id: 'nearby',
    primaryText: 'Near me',
    secondaryText: 'Find courts around you',
  );

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    return PlaceSuggestion(
      id: json['id']?.toString() ?? '',
      primaryText: json['primary_text'] as String? ?? '',
      secondaryText: json['secondary_text'] as String? ?? '',
    );
  }

  final String id;
  final String primaryText;
  final String secondaryText;

  bool get isNearby => id == nearby.id;

  String get displayLabel => secondaryText.isEmpty
      ? primaryText
      : '$primaryText, $secondaryText';

  Map<String, dynamic> toJson() => {
    'id': id,
    'primary_text': primaryText,
    'secondary_text': secondaryText,
  };

  @override
  List<Object?> get props => [id, primaryText, secondaryText];
}

class SearchBundle extends Equatable {
  const SearchBundle({
    this.places = const [],
    this.venues = const [],
  });

  factory SearchBundle.fromJson(Map<String, dynamic> json) {
    final placesRaw = json['places'];
    final venuesRaw = json['venues'];
    return SearchBundle(
      places: placesRaw is List
          ? placesRaw
                .whereType<Map>()
                .map((e) => PlaceSuggestion.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : const [],
      venues: venuesRaw is List
          ? venuesRaw
                .whereType<Map>()
                .map((e) => Venue.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : const [],
    );
  }

  final List<PlaceSuggestion> places;
  final List<Venue> venues;

  bool get isEmpty => places.isEmpty && venues.isEmpty;

  @override
  List<Object?> get props => [places, venues];
}

/// Returned to Explore when a city/area is picked on the search page.
class PlaceSearchResult extends Equatable {
  const PlaceSearchResult(this.place);

  final PlaceSuggestion place;

  @override
  List<Object?> get props => [place];
}
