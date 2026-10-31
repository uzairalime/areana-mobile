import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

import 'app_lat_lng.dart';

class LocationState extends Equatable {
  const LocationState({
    this.permission = LocationPermission.unableToDetermine,
    this.position,
    this.isLoading = false,
    this.errorMessage = '',
  });

  final LocationPermission permission;
  final AppLatLng? position;
  final bool isLoading;
  final String errorMessage;

  bool get isGranted =>
      permission == LocationPermission.whileInUse ||
      permission == LocationPermission.always;

  bool get isDeniedForever => permission == LocationPermission.deniedForever;

  bool get hasPosition => position?.isValid ?? false;

  LocationState copyWith({
    LocationPermission? permission,
    AppLatLng? position,
    bool? isLoading,
    String? errorMessage,
    bool clearPosition = false,
    bool clearError = false,
  }) {
    return LocationState(
      permission: permission ?? this.permission,
      position: clearPosition ? null : position ?? this.position,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? '' : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [permission, position, isLoading, errorMessage];
}
