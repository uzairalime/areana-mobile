import 'package:equatable/equatable.dart';

import '../../../core/utils/geo_distance.dart';
import 'venue.dart';

class NearbyVenue extends Equatable {
  const NearbyVenue({required this.venue, required this.distanceMeters});

  final Venue venue;
  final double distanceMeters;

  String get distanceLabel => GeoDistance.format(distanceMeters);

  @override
  List<Object?> get props => [venue, distanceMeters];
}

abstract final class NearbyVenueSorter {
  static const defaultLimit = 8;
  static const defaultMaxKm = 25.0;

  static List<NearbyVenue> fromVenues({
    required List<Venue> venues,
    required double latitude,
    required double longitude,
    int limit = defaultLimit,
    double maxKm = defaultMaxKm,
  }) {
    final maxMeters = maxKm * 1000;
    final ranked = <NearbyVenue>[];

    for (final venue in venues) {
      if (!venue.hasCoordinates) continue;
      final meters = GeoDistance.metersBetween(
        fromLat: latitude,
        fromLng: longitude,
        toLat: venue.latitude,
        toLng: venue.longitude,
      );
      if (meters > maxMeters) continue;
      ranked.add(NearbyVenue(venue: venue, distanceMeters: meters));
    }

    ranked.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    if (ranked.length <= limit) return ranked;
    return ranked.sublist(0, limit);
  }
}
