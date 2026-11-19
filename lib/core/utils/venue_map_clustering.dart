import 'package:latlong2/latlong.dart';

import '../../features/home/model/venue.dart';

/// Grid clustering for map markers.
///
/// Up to [maxMarkers] venues stay as individual price chips. Above that,
/// overlapping cells merge, then closest groups collapse so at most
/// [maxMarkers] pins are drawn. Zoom in uses a finer grid (clusters
/// expand back into chips); zoom out coarsens them.
abstract final class VenueMapClustering {
  static const int maxMarkers = 20;
  static const double searchZoom = 12.5;
  static const double myLocationZoom = 15;

  static List<VenueCluster> build({
    required List<Venue> venues,
    required double zoom,
  }) {
    if (venues.isEmpty) return const [];
    if (venues.length <= maxMarkers) {
      return [for (final venue in venues) VenueCluster.single(venue)];
    }

    var clusters = _bucket(venues, _cellDegrees(zoom));
    if (clusters.length > maxMarkers) {
      clusters = _mergeClosest(clusters, maxMarkers);
    }
    return clusters;
  }

  static List<VenueCluster> _bucket(List<Venue> venues, double cell) {
    final buckets = <String, List<Venue>>{};
    for (final venue in venues) {
      final gx = (venue.latitude / cell).floor();
      final gy = (venue.longitude / cell).floor();
      (buckets['$gx:$gy'] ??= <Venue>[]).add(venue);
    }
    return [
      for (final group in buckets.values)
        if (group.length == 1)
          VenueCluster.single(group.first)
        else
          VenueCluster.group(group),
    ];
  }

  static List<VenueCluster> _mergeClosest(
    List<VenueCluster> input,
    int max,
  ) {
    final clusters = List<VenueCluster>.of(input);
    while (clusters.length > max) {
      var bestI = 0;
      var bestJ = 1;
      var best = double.infinity;
      for (var i = 0; i < clusters.length; i++) {
        final a = clusters[i].center;
        for (var j = i + 1; j < clusters.length; j++) {
          final b = clusters[j].center;
          final dLat = a.latitude - b.latitude;
          final dLng = a.longitude - b.longitude;
          final d = dLat * dLat + dLng * dLng;
          if (d < best) {
            best = d;
            bestI = i;
            bestJ = j;
          }
        }
      }
      final merged = VenueCluster.group([
        ...clusters[bestI].venues,
        ...clusters[bestJ].venues,
      ]);
      if (bestJ > bestI) {
        clusters.removeAt(bestJ);
        clusters.removeAt(bestI);
      } else {
        clusters.removeAt(bestI);
        clusters.removeAt(bestJ);
      }
      clusters.add(merged);
    }
    return clusters;
  }

  /// Coarser cells when zoomed out → more clustering.
  static double _cellDegrees(double zoom) {
    if (zoom < 8) return 1.2;
    if (zoom < 10) return 0.5;
    if (zoom < 12) return 0.22;
    if (zoom < 13) return 0.1;
    if (zoom < 14) return 0.045;
    if (zoom < 15) return 0.02;
    if (zoom < 16) return 0.01;
    return 0.004;
  }
}

class MapViewport {
  const MapViewport({
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
    required this.centerLat,
    required this.centerLng,
    required this.zoom,
  });

  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;
  final double centerLat;
  final double centerLng;
  final double zoom;

  bool contains(double lat, double lng) =>
      lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng;

  /// True when the origin is clearly off-screen (not a tiny pan).
  bool leftOrigin(double lat, double lng) {
    final latPad = (maxLat - minLat).abs() * 0.08;
    final lngPad = (maxLng - minLng).abs() * 0.08;
    return lat < minLat - latPad ||
        lat > maxLat + latPad ||
        lng < minLng - lngPad ||
        lng > maxLng + lngPad;
  }

  /// True after a real pan away from the searched pin (~1.3 km).
  bool movedFromOrigin(double lat, double lng) {
    return (centerLat - lat).abs() > 0.012 || (centerLng - lng).abs() > 0.012;
  }

  /// ~100m buckets so camera jitter does not refetch.
  String get quantizedKey =>
      '${minLat.toStringAsFixed(3)},${maxLat.toStringAsFixed(3)},'
      '${minLng.toStringAsFixed(3)},${maxLng.toStringAsFixed(3)}';

  MapViewport padded(double fraction) {
    final latPad = (maxLat - minLat).abs() * fraction;
    final lngPad = (maxLng - minLng).abs() * fraction;
    return MapViewport(
      minLat: minLat - latPad,
      maxLat: maxLat + latPad,
      minLng: minLng - lngPad,
      maxLng: maxLng + lngPad,
      centerLat: centerLat,
      centerLng: centerLng,
      zoom: zoom,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MapViewport &&
        minLat == other.minLat &&
        maxLat == other.maxLat &&
        minLng == other.minLng &&
        maxLng == other.maxLng &&
        centerLat == other.centerLat &&
        centerLng == other.centerLng &&
        zoom == other.zoom;
  }

  @override
  int get hashCode => Object.hash(
    minLat,
    maxLat,
    minLng,
    maxLng,
    centerLat,
    centerLng,
    zoom,
  );
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
