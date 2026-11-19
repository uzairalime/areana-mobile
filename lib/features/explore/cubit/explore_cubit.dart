import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/app_loading.dart';
import '../../../core/services/explore_session_store.dart';
import '../../home/cubit/home_repository.dart';
import '../../home/model/court_filter.dart';
import '../../home/model/sport_game.dart';
import '../model/explore_models.dart';
import 'explore_state.dart';

class ExploreCubit extends Cubit<ExploreState> {
  ExploreCubit(this._repository, this._session)
    : super(
        ExploreState(
          search: _session.search,
          pageTab: _session.pageTab,
          selectedSportId: _session.selectedSportId,
        ),
      ) {
    load();
  }

  final HomeRepository _repository;
  final ExploreSessionStore _session;
  int _requestId = 0;

  Future<void> load() async {
    final requestId = ++_requestId;
    emit(state.copyWith(status: AppLoading.loading, errorMessage: ''));
    final result = await _repository.fetchVenues(
      sport: SportGame.apiName(state.selectedSportId),
      sort: state.search.hasCoordinates && state.filter.sort == .recommended
          ? 'distance'
          : state.filter.apiSort,
      minPrice: state.filter.apiMinPrice,
      maxPrice: state.filter.apiMaxPrice,
      lat: state.search.lat,
      lng: state.search.lng,
      radiusKm: state.search.hasCoordinates ? state.search.radiusKm : null,
      page: 1,
      limit: state.search.hasCoordinates ? 50 : 20,
    );
    if (isClosed || requestId != _requestId) return;
    result.when(
      success: (page) {
        emit(
          state.copyWith(
            status: AppLoading.success,
            venues: page.items.map((v) => v.toVenue()).toList(),
            search: _session.search,
            pageTab: _session.pageTab,
            selectedSportId: _session.selectedSportId,
            clearSport: _session.selectedSportId == null,
            errorMessage: '',
          ),
        );
      },
      failure: (error) {
        emit(
          state.copyWith(
            status: AppLoading.error,
            errorMessage: error.message,
            search: _session.search,
          ),
        );
      },
    );
  }

  void setPageTab(ExplorePageTab tab) {
    if (tab == state.pageTab) return;
    _session.savePageTab(tab);
    emit(state.copyWith(pageTab: tab));
  }

  void resetAfterLeave() {
    if (!state.search.hasLocation &&
        state.selectedSportId == null &&
        state.pageTab == .courts) {
      return;
    }
    _session
      ..clearSearch()
      ..savePageTab(.courts)
      ..saveSportId(null);
    emit(
      state.copyWith(
        search: const ExploreSearchCriteria(),
        pageTab: .courts,
        clearSport: true,
      ),
    );
  }

  Future<void> selectSport(String? sportId) async {
    if (sportId == null || sportId == state.selectedSportId) {
      _session.saveSportId(null);
      emit(
        state.copyWith(
          clearSport: true,
          filter: state.filter.copyWith(clearSport: true),
        ),
      );
    } else {
      _session.saveSportId(sportId);
      emit(
        state.copyWith(
          selectedSportId: sportId,
          filter: state.filter.copyWith(sportId: sportId),
        ),
      );
    }
    await load();
  }

  Future<void> applyArea({
    required String location,
    String placeId = '',
    double? lat,
    double? lng,
    double radiusKm = ExploreSearchCriteria.defaultRadiusKm,
  }) async {
    final search = ExploreSearchCriteria(
      location: location,
      placeId: placeId,
      lat: lat,
      lng: lng,
      radiusKm: radiusKm,
    );
    _session
      ..saveSearch(search)
      ..savePageTab(.courts);
    emit(state.copyWith(search: search, pageTab: .courts));
    await load();
  }

  void clearPlace() {
    _session.clearSearch();
    emit(state.copyWith(search: const ExploreSearchCriteria()));
    load();
  }

  Future<void> applyFilter(CourtFilterDraft filter) async {
    if (filter == state.filter) return;
    _session.saveSportId(filter.sportId);
    emit(
      state.copyWith(
        filter: filter,
        selectedSportId: filter.sportId,
        clearSport: filter.sportId == null,
      ),
    );
    await load();
  }
}
