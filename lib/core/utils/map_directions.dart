import 'package:url_launcher/url_launcher.dart';

import '../../features/home/model/venue.dart';

/// Opens the system maps app with turn-by-turn directions to a point.
abstract final class MapDirections {
  static Future<void> openVenue(Venue venue) {
    if (!venue.hasCoordinates) return Future<void>.value();
    return open(latitude: venue.latitude, longitude: venue.longitude);
  }

  static Future<void> open({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': '$latitude,$longitude',
      'travelmode': 'driving',
    });
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
