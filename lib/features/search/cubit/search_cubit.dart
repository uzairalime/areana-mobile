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
    final trimmed = value.trim();
    emit(
      state.copyWith(
        query: value,
        errorMessage: '',
        places: trimmed.isEmpty ? const [] : state.places,
        venues: trimmed.isEmpty ? const [] : state.venues,
        status: trimmed.isEmpty ? AppLoading.initial : state.status,
      ),
    );
    _debounce?.cancel();
    if (trimmed.isEmpty) return;
    _debounce = Timer(debounceDuration, () => search(trimmed));
  }

  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      emit(
        state.copyWith(
          status: AppLoading.initial,
          places: const [],
          venues: const [],
          errorMessage: '',
        ),
      );
      return;
    }

    final id = ++_requestId;
    emit(state.copyWith(status: AppLoading.loading, errorMessage: ''));
    final result = await _repository.search(trimmed);
    if (isClosed || id != _requestId) return;

    result.when(
      success: (bundle) {
        emit(
          state.copyWith(
            status: AppLoading.success,
            places: bundle.places,
            venues: bundle.venues,
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
            venues: const [],
          ),
        );
      },
    );
  }

  Future<void> submitCurrent() async {
    _debounce?.cancel();
    final query = queryController.text.trim();
    if (query.isEmpty) return;
    await _persistRecent(query);
    await search(query);
  }

  Future<void> selectRecent(String query) async {
    queryController
      ..text = query
      ..selection = TextSelection.collapsed(offset: query.length);
    emit(state.copyWith(query: query));
    _debounce?.cancel();
    await _persistRecent(query);
    await search(query);
  }

  Future<PlaceSearchResult?> pickPlace(PlaceSuggestion place) async {
    if (!place.isNearby) {
      await _persistRecent(place.primaryText);
    }
    return PlaceSearchResult(place);
  }

  Future<void> removeRecent(String query) async {
    final recents = await _repository.removeRecent(query);
    if (isClosed) return;
    emit(state.copyWith(recents: recents));
  }

  Future<void> clearRecents() async {
    await _repository.clearRecent();
    if (isClosed) return;
    emit(state.copyWith(recents: const []));
  }

  Future<void> rememberSelection(String query) => _persistRecent(query);

  Future<void> _persistRecent(String query) async {
    final recents = await _repository.remember(query);
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
