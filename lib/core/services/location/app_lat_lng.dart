import 'package:equatable/equatable.dart';

class AppLatLng extends Equatable {
  const AppLatLng({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  bool get isValid =>
      latitude.abs() <= 90 &&
      longitude.abs() <= 180 &&
      !(latitude == 0 && longitude == 0);

  @override
  List<Object?> get props => [latitude, longitude];
}
