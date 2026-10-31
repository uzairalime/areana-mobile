import 'package:geolocator/geolocator.dart';

import 'app_lat_lng.dart';

/// Thin Geolocator wrapper — no Flutter UI, no cubit state.
class LocationService {
  const LocationService();

  Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();

  Future<LocationPermission> checkPermission() => Geolocator.checkPermission();

  Future<LocationPermission> requestPermission() =>
      Geolocator.requestPermission();

  Future<AppLatLng?> currentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration timeLimit = const Duration(seconds: 12),
  }) async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        timeLimit: timeLimit,
      ),
    );
    return AppLatLng(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  static double distanceMeters({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) {
    return Geolocator.distanceBetween(fromLat, fromLng, toLat, toLng);
  }
}
