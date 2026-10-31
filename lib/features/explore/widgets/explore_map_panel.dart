import 'package:flutter/material.dart';

import '../../../core/widgets/venue_map_view.dart';
import '../../home/model/venue.dart';

/// Explore Map tab — edge-to-edge, clustered when many venues.
class ExploreMapPanel extends StatelessWidget {
  const ExploreMapPanel({
    super.key,
    required this.venues,
    required this.onVenueTap,
  });

  final List<Venue> venues;
  final ValueChanged<Venue> onVenueTap;

  @override
  Widget build(BuildContext context) {
    return VenueMapView(
      venues: venues,
      onVenueTap: onVenueTap,
      showControls: true,
      showPriceMarkers: true,
      enableClustering: true,
      controlsBottom: 100,
    );
  }
}
