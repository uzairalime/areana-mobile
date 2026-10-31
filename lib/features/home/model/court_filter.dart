import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'sport_game.dart';

enum CourtSortOption { recommended, priceHighLow, priceLowHigh, newest }

extension CourtSortOptionX on CourtSortOption {
  String get label => switch (this) {
    .recommended => 'Recommended',
    .priceHighLow => 'Price (High → Low)',
    .priceLowHigh => 'Price (Low → High)',
    .newest => 'Newest',
  };
}

class CourtAreaPreset extends Equatable {
  const CourtAreaPreset({
    required this.id,
    required this.label,
    this.icon = Icons.location_on_outlined,
  });

  final String id;
  final String label;
  final IconData icon;

  @override
  List<Object?> get props => [id, label];
}

/// Static options for the court filter sheet (Pitchside domain).
abstract final class CourtFilterPresets {
  static const sortOptions = CourtSortOption.values;

  static const priceMin = 500;
  static const priceMax = 15000;
  static const priceDivisions = 29; // 500 PKR steps

  static const areas = <CourtAreaPreset>[
    CourtAreaPreset(id: 'dha', label: 'DHA'),
    CourtAreaPreset(id: 'gulberg', label: 'Gulberg'),
    CourtAreaPreset(id: 'bahria', label: 'Bahria'),
    CourtAreaPreset(id: 'model_town', label: 'Model Town'),
    CourtAreaPreset(id: 'johar', label: 'Johar Town'),
  ];

  static List<SportGame> get sports =>
      SportGame.catalog.where((s) => !s.isAll).toList(growable: false);
}

/// Mutable selection held while the sheet is open; emit via [copyWith].
class CourtFilterDraft extends Equatable {
  const CourtFilterDraft({
    this.sort = .recommended,
    this.sportId,
    this.areaId,
    this.minPrice = CourtFilterPresets.priceMin,
    this.maxPrice = CourtFilterPresets.priceMax,
  });

  final CourtSortOption sort;
  final String? sportId;
  final String? areaId;

  /// Inclusive PKR bounds for hourly rate.
  final int minPrice;
  final int maxPrice;

  bool get isFullPriceRange =>
      minPrice <= CourtFilterPresets.priceMin &&
      maxPrice >= CourtFilterPresets.priceMax;

  bool get isEmpty =>
      sort == .recommended &&
      sportId == null &&
      areaId == null &&
      isFullPriceRange;

  int get activeCount {
    var n = 0;
    if (sort != .recommended) n++;
    if (sportId != null) n++;
    if (areaId != null) n++;
    if (!isFullPriceRange) n++;
    return n;
  }

  RangeValues get priceRange =>
      RangeValues(minPrice.toDouble(), maxPrice.toDouble());

  CourtFilterDraft copyWith({
    CourtSortOption? sort,
    String? sportId,
    String? areaId,
    int? minPrice,
    int? maxPrice,
    bool clearSport = false,
    bool clearArea = false,
  }) {
    return CourtFilterDraft(
      sort: sort ?? this.sort,
      sportId: clearSport ? null : (sportId ?? this.sportId),
      areaId: clearArea ? null : (areaId ?? this.areaId),
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }

  CourtFilterDraft cleared() => const CourtFilterDraft();

  CourtFilterDraft toggleSport(String id) =>
      copyWith(sportId: id, clearSport: sportId == id);

  CourtFilterDraft toggleArea(String id) =>
      copyWith(areaId: id, clearArea: areaId == id);

  CourtFilterDraft withPriceRange(RangeValues values) {
    var start = values.start.round();
    var end = values.end.round();
    if (start > end) {
      final swap = start;
      start = end;
      end = swap;
    }
    start = start.clamp(
      CourtFilterPresets.priceMin,
      CourtFilterPresets.priceMax,
    );
    end = end.clamp(CourtFilterPresets.priceMin, CourtFilterPresets.priceMax);
    return copyWith(minPrice: start, maxPrice: end);
  }

  @override
  List<Object?> get props => [sort, sportId, areaId, minPrice, maxPrice];
}
