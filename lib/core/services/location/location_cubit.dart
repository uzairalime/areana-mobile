import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import 'location_service.dart';
import 'location_state.dart';

/// ReelStay-style permission + one-shot position for Near me / maps.
class LocationCubit extends Cubit<LocationState> {
  LocationCubit(this._service) : super(const LocationState());

  final LocationService _service;
  var _ensuring = false;

  Future<void> checkPermission() => ensurePermission(fetchLocation: true);

  Future<void> ensurePermission({bool fetchLocation = false}) async {
    if (_ensuring) return;
    _ensuring = true;
    emit(
      state.copyWith(
        isLoading: fetchLocation,
        clearError: true,
      ),
    );

    try {
      var permission = await _service.checkPermission();
      if (isClosed) return;

      if (!_isGranted(permission)) {
        permission = await _service.requestPermission();
        if (isClosed) return;
      }

      if (!_isGranted(permission)) {
        _fail(
          permission == LocationPermission.deniedForever
              ? 'Location access is turned off. Enable it in Settings to see courts near you.'
              : 'Allow location access to see courts near you.',
          permission: permission,
        );
        return;
      }

      final serviceEnabled = await _service.isServiceEnabled();
      if (!serviceEnabled) {
        _fail(
          'Location services are off. Turn them on to find nearby courts.',
          permission: permission,
        );
        return;
      }

      emit(state.copyWith(permission: permission, clearError: true));
      if (fetchLocation) await _readPosition();
    } finally {
      _ensuring = false;
    }
  }

  Future<void> refreshPosition() async {
    if (!state.isGranted) {
      await ensurePermission(fetchLocation: true);
      return;
    }
    await _readPosition();
  }

  Future<void> openSettings() async {
    if (state.isDeniedForever) {
      await _service.openAppSettings();
    } else {
      await _service.openLocationSettings();
    }
  }

  Future<void> _readPosition() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final position = await _service.currentPosition();
      if (isClosed) return;
      if (position == null || !position.isValid) {
        _fail('Could not read your current location.');
        return;
      }
      emit(
        state.copyWith(
          position: position,
          isLoading: false,
          clearError: true,
        ),
      );
    } catch (_) {
      _fail('Could not read your current location.');
    }
  }

  void _fail(String message, {LocationPermission? permission}) {
    if (isClosed) return;
    emit(
      state.copyWith(
        permission: permission,
        isLoading: false,
        errorMessage: message,
      ),
    );
  }

  static bool _isGranted(LocationPermission permission) =>
      permission == LocationPermission.whileInUse ||
      permission == LocationPermission.always;
}
