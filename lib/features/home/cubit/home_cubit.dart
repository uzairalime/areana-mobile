import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/app_loading.dart';
import '../model/areana_models.dart';
import '../model/court_filter.dart';
import '../model/sport_game.dart';
import 'home_repository.dart';
import 'home_state.dart';

/// Discovery cubit. One public list: `GET /venues?type=all`.
/// Sport, sort, and budget from the filter sheet go on that query.
/// `distance` still needs lat and lng together.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository) : super(const HomeState()) {
    load();
  }

  final HomeRepository _repository;
  final searchController = TextEditingController();
  int _pageRequestId = 0;

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
    final clear = sportId == SportGame.all.id;
    emit(
      state.copyWith(
        selectedSportId: sportId,
        filter: state.filter.copyWith(
          sportId: clear ? null : sportId,
          clearSport: clear,
        ),
      ),
    );
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

  Future<void> loadMore() async {
    if (state.status.isLoading || state.isLoadingMore || !state.hasMore) return;
    await _loadPage(page: state.page + 1, showLoading: false, append: true);
  }

  Future<void> refresh() => _loadPage(page: 1, showLoading: false);

  Future<void> _loadPage({
    required int page,
    bool showLoading = true,
    bool append = false,
  }) async {
    final requestId = ++_pageRequestId;
    if (showLoading) {
      emit(
        state.copyWith(
          status: AppLoading.loading,
          errorMessage: '',
          isLoadingMore: false,
        ),
      );
    } else if (append) {
      emit(state.copyWith(isLoadingMore: true));
    }
    final sport = state.selectedSportName;
    final query = state.query.trim().isEmpty ? null : state.query.trim();
    final result = await _repository.fetchVenues(
      q: query,
      city: state.selectedCity,
      sport: sport,
      sort: state.sort ?? state.filter.apiSort,
      minPrice: state.filter.apiMinPrice,
      maxPrice: state.filter.apiMaxPrice,
      lat: state.lat,
      lng: state.lng,
      page: page,
      limit: 20,
    );
    if (isClosed || requestId != _pageRequestId) return;
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

  Future<void> applyFilter(CourtFilterDraft filter) async {
    if (filter == state.filter) return;
    emit(
      state.copyWith(
        filter: filter,
        selectedSportId: filter.sportId ?? SportGame.all.id,
        sort: filter.apiSort,
      ),
    );
    await _loadPage(page: 1);
  }

  Future<AreanaVenueDetail?> fetchVenueDetail(String id) async {
    final result = await _repository.fetchVenueDetail(id);
    if (isClosed) return null;
    return result.when(success: (detail) => detail, failure: (_) => null);
  }

  Future<AreanaCourtDetail?> fetchCourtDetail(String id) async {
    final result = await _repository.fetchCourtDetail(id);
    if (isClosed) return null;
    return result.when(success: (detail) => detail, failure: (_) => null);
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
