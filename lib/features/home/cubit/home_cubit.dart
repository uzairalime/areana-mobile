import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/app_loading.dart';
import '../model/areana_models.dart';
import '../model/court_filter.dart';
import '../model/sport_game.dart';
import 'home_repository.dart';
import 'home_state.dart';

/// Discovery cubit: user-web home/browse flow.
/// `GET /venues` (offset paging) for arenas, `GET /courts` for the
/// Courts tab, `GET /sports` + `GET /venues/cities` for filters.
/// Server sort values are passed through unchanged; `distance`
/// requires a location (lat+lng), otherwise the server 400s.
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
        emit(state.copyWith(sports: _ensureAllFirst(sports)));
      },
      failure: (_) {
        emit(state.copyWith(sports: SportGame.defaults));
      },
    );

    final citiesResult = await _repository.fetchCities();
    if (isClosed) return;
    citiesResult.when(
      success: (cities) => emit(state.copyWith(cities: cities)),
      failure: (_) {},
    );

    final bannersResult = await _repository.fetchBanners(
      city: state.selectedCity,
    );
    if (isClosed) return;
    bannersResult.when(
      success: (banners) => emit(state.copyWith(banners: banners)),
      failure: (_) {},
    );

    await _loadPage(page: 1, showLoading: false);
  }

  Future<void> selectSport(String sportId) async {
    if (sportId == state.selectedSportId) return;
    emit(state.copyWith(selectedSportId: sportId));
    await _loadPage(page: 1);
  }

  Future<void> selectCity(String? city) async {
    emit(state.copyWith(selectedCity: city, clearCity: city == null));
    await _loadPage(page: 1);
  }

  Future<void> setSort(String? sort) async {
    emit(state.copyWith(sort: sort));
    await _loadPage(page: 1);
  }

  Future<void> setLocation(double? lat, double? lng) async {
    if (lat == null || lng == null) {
      emit(state.copyWith(clearLocation: true));
    } else {
      emit(state.copyWith(lat: lat, lng: lng));
    }
    await _loadPage(page: 1);
  }

  Future<void> setShowingCourts(bool value) async {
    if (value == state.showingCourts) return;
    emit(state.copyWith(showingCourts: value));
    await _loadPage(page: 1);
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    await _loadPage(page: state.page + 1, showLoading: false, append: true);
  }

  Future<void> refresh() => _loadPage(page: 1);

  Future<void> _loadPage({
    required int page,
    bool showLoading = true,
    bool append = false,
  }) async {
    if (showLoading) {
      emit(state.copyWith(status: AppLoading.loading, errorMessage: ''));
    } else if (append) {
      emit(state.copyWith(isLoadingMore: true));
    }
    final sport = state.selectedSportName;
    final query = state.query.trim().isEmpty ? null : state.query.trim();
    if (state.showingCourts) {
      final result = await _repository.fetchCourts(
        q: query,
        city: state.selectedCity,
        sport: sport,
        sort: state.sort ?? 'price_asc',
        lat: state.lat,
        lng: state.lng,
        page: page,
        limit: 20,
      );
      if (isClosed) return;
      result.when(
        success: (data) {
          emit(
            state.copyWith(
              status: AppLoading.success,
              courts: append ? [...state.courts, ...data.items] : data.items,
              page: data.page,
              hasMore: data.hasMore,
              isLoadingMore: false,
              errorMessage: '',
            ),
          );
        },
        failure: (error) {
          emit(
            state.copyWith(
              status: append ? AppLoading.success : AppLoading.error,
              isLoadingMore: false,
              errorMessage: error.message,
            ),
          );
        },
      );
      return;
    }
    final result = await _repository.fetchVenues(
      q: query,
      city: state.selectedCity,
      sport: sport,
      sort: state.sort,
      lat: state.lat,
      lng: state.lng,
      page: page,
      limit: 20,
    );
    if (isClosed) return;
    result.when(
      success: (data) {
        final mapped = data.items.map((v) => v.toVenue()).toList();
        emit(
          state.copyWith(
            status: AppLoading.success,
            venues: append ? [...state.venues, ...mapped] : mapped,
            page: data.page,
            hasMore: data.hasMore,
            isLoadingMore: false,
            errorMessage: '',
          ),
        );
      },
      failure: (error) {
        emit(
          state.copyWith(
            status: append ? AppLoading.success : AppLoading.error,
            isLoadingMore: false,
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

  Future<void> submitQuery() => _loadPage(page: 1);

  void applyFilter(CourtFilterDraft filter) {
    if (filter == state.filter) return;
    emit(state.copyWith(filter: filter));
  }

  Future<AreanaVenueDetail?> fetchVenueDetail(String id) async {
    final result = await _repository.fetchVenueDetail(id);
    if (isClosed) return null;
    return result.when(
      success: (detail) => detail,
      failure: (_) => null,
    );
  }

  Future<AreanaCourtDetail?> fetchCourtDetail(String id) async {
    final result = await _repository.fetchCourtDetail(id);
    if (isClosed) return null;
    return result.when(
      success: (detail) => detail,
      failure: (_) => null,
    );
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
