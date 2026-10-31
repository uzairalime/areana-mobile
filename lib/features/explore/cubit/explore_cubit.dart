import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/app_loading.dart';
import '../../../core/services/explore_session_store.dart';
import '../../home/cubit/home_repository.dart';
import '../../home/model/court_filter.dart';
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

  Future<void> load() async {
    emit(state.copyWith(status: AppLoading.loading, errorMessage: ''));
    final result = await _repository.fetchPopularVenues();
    if (isClosed) return;
    result.when(
      success: (venues) {
        emit(
          state.copyWith(
            status: AppLoading.success,
            venues: venues,
            // Re-apply session snapshot in case a remount raced load().
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

  /// Courts / Map only — does not clear place search.
  void setPageTab(ExplorePageTab tab) {
    if (tab == state.pageTab) return;
    _session.savePageTab(tab);
    emit(state.copyWith(pageTab: tab));
  }

  /// Called when user leaves Explore via bottom nav — back = default catalog.
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

  void selectSport(String? sportId) {
    if (sportId == null) {
      _session.saveSportId(null);
      emit(state.copyWith(clearSport: true));
      return;
    }
    if (sportId == state.selectedSportId) {
      _session.saveSportId(null);
      emit(state.copyWith(clearSport: true));
      return;
    }
    _session.saveSportId(sportId);
    emit(state.copyWith(selectedSportId: sportId));
  }

  void applySearch(ExploreSearchCriteria search) {
    if (search == state.search) return;
    _session.saveSearch(search);
    emit(state.copyWith(search: search));
  }

  void applyPlace({required String location, String placeId = ''}) {
    final search = state.search.copyWith(
      location: location,
      placeId: placeId,
    );
    _session
      ..saveSearch(search)
      ..savePageTab(.courts);
    emit(state.copyWith(search: search, pageTab: .courts));
  }

  /// GPS-based Explore filter — does not use a city string match.
  void applyNearby() {
    applyPlace(location: 'Nearby', placeId: 'nearby');
  }

  void clearPlace() {
    _session.clearSearch();
    emit(
      state.copyWith(
        search: const ExploreSearchCriteria(),
      ),
    );
  }

  void applyFilter(CourtFilterDraft filter) {
    if (filter == state.filter) return;
    _session.saveSportId(filter.sportId);
    emit(
      state.copyWith(
        filter: filter,
        selectedSportId: filter.sportId,
        clearSport: filter.sportId == null,
      ),
    );
  }
}
