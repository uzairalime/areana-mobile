import 'dart:convert';

import 'package:equatable/equatable.dart';

/// Place suggestion from `GET /places/autocomplete` / details / reverse.
class PlaceSuggestion extends Equatable {
  const PlaceSuggestion({
    required this.id,
    required this.primaryText,
    this.secondaryText = '',
    this.label = '',
    this.lat,
    this.lng,
  });

  /// Idle-row for GPS search — never written to recent history.
  static const nearby = PlaceSuggestion(
    id: 'nearby',
    primaryText: 'Near me',
    secondaryText: 'Find courts around you',
  );

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    final primary =
        json['primaryText'] as String? ??
        json['primary_text'] as String? ??
        json['name'] as String? ??
        json['label'] as String? ??
        '';
    final secondary =
        json['secondaryText'] as String? ??
        json['secondary_text'] as String? ??
        json['address'] as String? ??
        '';
    final rawLabel = (json['label'] as String?)?.trim() ?? '';
    return PlaceSuggestion(
      id: json['id']?.toString() ?? json['placeId']?.toString() ?? '',
      primaryText: primary,
      secondaryText: secondary,
      label: rawLabel.isNotEmpty
          ? rawLabel
          : (secondary.isEmpty
                ? primary
                : '$primary, ${secondary.split(',').first.trim()}'),
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }

  final String id;
  final String primaryText;
  final String secondaryText;
  final String label;
  final double? lat;
  final double? lng;

  bool get isNearby => id == nearby.id;

  bool get hasCoordinates => lat != null && lng != null;

  String get displayLabel {
    final named = label.trim();
    if (named.isNotEmpty) return named;
    if (secondaryText.isEmpty) return primaryText;
    return '$primaryText, ${secondaryText.split(',').first.trim()}';
  }

  RecentPlace toRecent() => RecentPlace(
    label: displayLabel,
    placeId: id,
    lat: lat,
    lng: lng,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'primaryText': primaryText,
    'secondaryText': secondaryText,
    'label': displayLabel,
    'lat': lat,
    'lng': lng,
  };

  @override
  List<Object?> get props => [id, primaryText, secondaryText, label, lat, lng];
}

class RecentPlace extends Equatable {
  const RecentPlace({
    required this.label,
    this.placeId = '',
    this.lat,
    this.lng,
  });

  factory RecentPlace.fromStored(String raw) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('{')) {
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map) {
          return RecentPlace.fromJson(Map<String, dynamic>.from(decoded));
        }
      } catch (_) {}
    }
    return RecentPlace(label: trimmed);
  }

  factory RecentPlace.fromJson(Map<String, dynamic> json) {
    return RecentPlace(
      label: (json['label'] as String? ?? json['primaryText'] as String? ?? '')
          .trim(),
      placeId: json['placeId']?.toString() ?? json['id']?.toString() ?? '',
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }

  final String label;
  final String placeId;
  final double? lat;
  final double? lng;

  bool get hasCoordinates => lat != null && lng != null;

  String get encoded => jsonEncode({
    'label': label,
    'placeId': placeId,
    'lat': lat,
    'lng': lng,
  });

  @override
  List<Object?> get props => [label, placeId, lat, lng];
}

class SearchBundle extends Equatable {
  const SearchBundle({this.places = const []});

  final List<PlaceSuggestion> places;

  bool get isEmpty => places.isEmpty;

  @override
  List<Object?> get props => [places];
}

class PlaceSearchResult extends Equatable {
  const PlaceSearchResult(this.place);

  final PlaceSuggestion place;

  @override
  List<Object?> get props => [place];
}
