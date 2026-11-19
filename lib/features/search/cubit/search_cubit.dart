import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/app_loading.dart';
import '../model/search_models.dart';
import 'search_repository.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._repository) : super(const SearchState()) {
    queryController = TextEditingController();
    loadRecents();
  }

  final SearchRepository _repository;
  late final TextEditingController queryController;
  Timer? _debounce;
  int _requestId = 0;

  static const debounceDuration = Duration(milliseconds: 400);

  Future<void> loadRecents() async {
    final recents = await _repository.loadRecent();
    if (isClosed) return;
    emit(state.copyWith(recents: recents));
  }

  void onQueryChanged(String value) {
    _requestId++;
    final trimmed = value.trim();
    emit(
      state.copyWith(
        query: value,
        errorMessage: '',
        places: trimmed.isEmpty ? const [] : state.places,
        status: trimmed.isEmpty ? AppLoading.initial : state.status,
      ),
    );
    _debounce?.cancel();
    if (trimmed.length < 2) return;
    _debounce = Timer(debounceDuration, () => search(trimmed));
  }

  Future<void> search(String query) async {
    _debounce?.cancel();
    final id = ++_requestId;
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      emit(
        state.copyWith(
          status: AppLoading.initial,
          places: const [],
          errorMessage: '',
        ),
      );
      return;
    }

    emit(state.copyWith(status: AppLoading.loading, errorMessage: ''));
    final result = await _repository.search(trimmed);
    if (isClosed || id != _requestId) return;

    result.when(
      success: (bundle) {
        emit(
          state.copyWith(
            status: AppLoading.success,
            places: bundle.places,
            errorMessage: '',
          ),
        );
      },
      failure: (error) {
        emit(
          state.copyWith(
            status: AppLoading.error,
            errorMessage: error.message,
            places: const [],
          ),
        );
      },
    );
  }

  Future<void> submitCurrent() async {
    _debounce?.cancel();
    final query = queryController.text.trim();
    if (query.length < 2) return;
    await search(query);
  }

  Future<PlaceSuggestion?> resolvePlace(PlaceSuggestion place) async {
    if (place.hasCoordinates) {
      await _persistRecent(place.toRecent());
      return place;
    }
    if (place.id.isEmpty) return null;
    final resolved = (await _repository.details(place.id)).dataOrNull;
    if (resolved == null) return null;
    await _persistRecent(resolved.toRecent());
    return resolved;
  }

  Future<PlaceSuggestion?> resolveRecent(RecentPlace recent) async {
    if (recent.hasCoordinates) {
      await _persistRecent(recent);
      return PlaceSuggestion(
        id: recent.placeId,
        primaryText: recent.label,
        label: recent.label,
        lat: recent.lat,
        lng: recent.lng,
      );
    }
    if (recent.placeId.isNotEmpty) {
      final resolved = (await _repository.details(recent.placeId)).dataOrNull;
      if (resolved != null) {
        await _persistRecent(resolved.toRecent());
        return resolved;
      }
    }
    final bundle = (await _repository.search(recent.label)).dataOrNull;
    if (bundle == null || bundle.places.isEmpty) return null;
    return resolvePlace(bundle.places.first);
  }

  Future<PlaceSuggestion?> reverseGeocode({
    required double lat,
    required double lng,
  }) async {
    final result = await _repository.reverse(lat: lat, lng: lng);
    return result.when(
      success: (place) {
        final label = place.displayLabel.trim();
        final blocked = label.toLowerCase() == 'nearby' ||
            label.toLowerCase() == 'near me';
        if (!blocked) return place;
        return PlaceSuggestion(
          id: place.id.isEmpty ? 'nearby' : place.id,
          primaryText: 'Current location',
          label: 'Current location',
          lat: lat,
          lng: lng,
        );
      },
      failure: (_) => PlaceSuggestion(
        id: 'nearby',
        primaryText: 'Current location',
        label: 'Current location',
        lat: lat,
        lng: lng,
      ),
    );
  }

  Future<void> removeRecent(RecentPlace place) async {
    final recents = await _repository.removeRecent(place);
    if (isClosed) return;
    emit(state.copyWith(recents: recents));
  }

  Future<void> clearRecents() async {
    await _repository.clearRecent();
    if (isClosed) return;
    emit(state.copyWith(recents: const []));
  }

  Future<void> _persistRecent(RecentPlace place) async {
    final recents = await _repository.remember(place);
    if (isClosed) return;
    emit(state.copyWith(recents: recents));
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    queryController.dispose();
    return super.close();
  }
}
