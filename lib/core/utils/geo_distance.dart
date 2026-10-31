import '../services/location/location_service.dart';

abstract final class GeoDistance {
  static double metersBetween({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) {
    return LocationService.distanceMeters(
      fromLat: fromLat,
      fromLng: fromLng,
      toLat: toLat,
      toLng: toLng,
    );
  }

  /// Human label: `450 m` or `1.2 km`.
  static String format(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }
    final km = meters / 1000;
    final rounded = km >= 10 ? km.round().toString() : km.toStringAsFixed(1);
    return '$rounded km';
  }
}
