import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/app_loading.dart';
import '../model/court_filter.dart';
import '../model/sport_game.dart';
import 'home_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository) : super(const HomeState()) {
    load();
  }

  final HomeRepository _repository;
  final searchController = TextEditingController();

  Future<void> load() async {
    emit(state.copyWith(status: AppLoading.loading, errorMessage: ''));

    final sportsResult = await _repository.fetchSports();
    if (isClosed) return;

    sportsResult.when(
      success: (sports) {
        final withAll = _ensureAllFirst(sports);
        emit(state.copyWith(sports: withAll));
      },
      failure: (_) {
        emit(state.copyWith(sports: SportGame.defaults));
      },
    );

    await _loadVenues(showLoading: false);
  }

  Future<void> selectSport(String sportId) async {
    if (sportId == state.selectedSportId) return;
    emit(state.copyWith(selectedSportId: sportId));
    await _loadVenues();
  }

  Future<void> _loadVenues({bool showLoading = true}) async {
    if (showLoading) {
      emit(state.copyWith(status: AppLoading.loading, errorMessage: ''));
    }

    final result = await _repository.fetchPopularVenues(
      sportId: state.selectedSportId,
    );
    if (isClosed) return;

    result.when(
      success: (venues) {
        emit(
          state.copyWith(
            status: AppLoading.success,
            venues: venues,
            errorMessage: '',
          ),
        );
      },
      failure: (error) {
        emit(
          state.copyWith(
            status: AppLoading.error,
            errorMessage: error.message,
          ),
        );
      },
    );
  }

  void updateQuery(String value) {
    if (value == state.query) return;
    emit(state.copyWith(query: value));
  }

  void applyFilter(CourtFilterDraft filter) {
    if (filter == state.filter) return;
    emit(state.copyWith(filter: filter));
  }

  static List<SportGame> _ensureAllFirst(List<SportGame> sports) {
    final cleaned = [
      for (final sport in sports)
        if (!sport.isAll) sport,
    ];
    return [SportGame.all, ...cleaned];
  }

  @override
  Future<void> close() {
    searchController.dispose();
    return super.close();
  }
}
