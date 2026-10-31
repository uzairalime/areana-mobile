import 'package:latlong2/latlong.dart';

import '../../features/home/model/venue.dart';

/// Grid clustering for map markers. Pure / allocation-light.
abstract final class VenueMapClustering {
  /// Below this count we never cluster — every venue is its own marker.
  static const int clusterThreshold = 20;

  static List<VenueCluster> build({
    required List<Venue> venues,
    required double zoom,
  }) {
    if (venues.isEmpty) return const [];

    if (venues.length <= clusterThreshold) {
      return [for (final v in venues) VenueCluster.single(v)];
    }

    final cell = _cellDegrees(zoom);
    final buckets = <String, List<Venue>>{};
    for (final v in venues) {
      final gx = (v.latitude / cell).floor();
      final gy = (v.longitude / cell).floor();
      (buckets['$gx:$gy'] ??= <Venue>[]).add(v);
    }

    return [
      for (final group in buckets.values)
        if (group.length == 1)
          VenueCluster.single(group.first)
        else
          VenueCluster.group(group),
    ];
  }

  /// Coarser cells when zoomed out → more clustering.
  static double _cellDegrees(double zoom) {
    if (zoom < 6) return 2.5;
    if (zoom < 8) return 1.2;
    if (zoom < 10) return 0.45;
    if (zoom < 12) return 0.18;
    if (zoom < 14) return 0.06;
    if (zoom < 16) return 0.02;
    return 0.006;
  }
}

class VenueCluster {
  const VenueCluster._({
    required this.center,
    required this.venues,
  });

  factory VenueCluster.single(Venue venue) {
    return VenueCluster._(
      center: LatLng(venue.latitude, venue.longitude),
      venues: [venue],
    );
  }

  factory VenueCluster.group(List<Venue> venues) {
    assert(venues.isNotEmpty);
    var lat = 0.0;
    var lng = 0.0;
    for (final v in venues) {
      lat += v.latitude;
      lng += v.longitude;
    }
    final n = venues.length;
    return VenueCluster._(
      center: LatLng(lat / n, lng / n),
      venues: List<Venue>.unmodifiable(venues),
    );
  }

  final LatLng center;
  final List<Venue> venues;

  bool get isSingle => venues.length == 1;
  int get count => venues.length;
  Venue get first => venues.first;
}
