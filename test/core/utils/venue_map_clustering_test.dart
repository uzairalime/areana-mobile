import 'package:arana360/core/utils/venue_map_clustering.dart';
import 'package:arana360/features/explore/model/explore_models.dart';
import 'package:arana360/features/home/model/venue.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('empty and single venues skip clustering', () {
    expect(VenueMapClustering.build(venues: const [], zoom: 12), isEmpty);
    final one = VenueMapClustering.build(venues: [_venue('a', 31.52, 74.35)], zoom: 10);
    expect(one, hasLength(1));
    expect(one.single.isSingle, isTrue);
  });

  test('nearby pins collapse when zoomed out and split when zoomed in', () {
    final venues = [
      _venue('a', 31.520, 74.350),
      _venue('b', 31.525, 74.355),
    ];
    final out = VenueMapClustering.build(venues: venues, zoom: 8);
    expect(out, hasLength(1));
    expect(out.single.count, 2);

    final inn = VenueMapClustering.build(venues: venues, zoom: 16);
    expect(inn, hasLength(2));
    expect(inn.every((cluster) => cluster.isSingle), isTrue);
  });

  test('never draws more than 15 markers', () {
    final venues = [
      for (var i = 0; i < 40; i++)
        _venue('v$i', 31.4 + (i % 8) * 0.04, 74.2 + (i ~/ 8) * 0.04),
    ];
    final clusters = VenueMapClustering.build(venues: venues, zoom: 16);
    expect(clusters.length, lessThanOrEqualTo(VenueMapClustering.maxMarkers));
    expect(
      clusters.fold<int>(0, (sum, cluster) => sum + cluster.count),
      venues.length,
    );
  });

  test('origin card appears only after the map leaves the search pin', () {
    const lahore = MapViewport(
      minLat: 31.4,
      maxLat: 31.7,
      minLng: 74.2,
      maxLng: 74.5,
      centerLat: 31.52,
      centerLng: 74.35,
      zoom: 12,
    );
    const away = MapViewport(
      minLat: 33.6,
      maxLat: 33.8,
      minLng: 72.9,
      maxLng: 73.2,
      centerLat: 33.7,
      centerLng: 73.05,
      zoom: 12,
    );
    expect(lahore.leftOrigin(31.5204, 74.3587), isFalse);
    expect(away.leftOrigin(31.5204, 74.3587), isTrue);
    expect(ExplorePageTab.venues.label, 'Venues');
  });
}

Venue _venue(String id, double lat, double lng) => Venue(
  id: id,
  name: id,
  sport: 'Football',
  location: 'Lahore',
  priceFrom: 4000,
  amenities: const [],
  nextSlot: '',
  heroColor: Colors.green,
  latitude: lat,
  longitude: lng,
);
