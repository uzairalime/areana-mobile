import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/app_loading.dart';
import '../../../core/services/api_result.dart';
import '../../../core/services/explore_session_store.dart';
import '../../../core/services/pagination.dart';
import '../../../core/utils/venue_map_clustering.dart';
import '../../home/cubit/home_repository.dart';
import '../../home/model/areana_models.dart';
import '../../home/model/court_filter.dart';
import '../../home/model/sport_game.dart';
import '../model/explore_models.dart';
import 'explore_state.dart';

class ExploreCubit extends Cubit<ExploreState> {
  ExploreCubit(
    this._repository,
    this._session, {
    this.mapDebounce = const Duration(milliseconds: 280),
  }) : super(
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
  final Duration mapDebounce;

  int _requestId = 0;
  int _mapRequestId = 0;
  Timer? _mapDebounce;
  String? _fetchedBoxKey;
  bool _mapPrimed = false;

  Future<void> load() async {
    final requestId = ++_requestId;
    emit(state.copyWith(status: AppLoading.loading, errorMessage: ''));
    final result = await _listVenues(
      lat: state.search.lat,
      lng: state.search.lng,
      radiusKm: state.search.hasCoordinates ? state.search.radiusKm : null,
      limit: state.search.hasCoordinates ? 50 : 20,
    );
    if (isClosed || requestId != _requestId) return;
    result.when(
      success: (page) {
        final venues = page.items.map((v) => v.toVenue()).toList();
        final pannedAway = state.showBackToOrigin;
        emit(
          state.copyWith(
            status: AppLoading.success,
            venues: venues,
            mapVenues: pannedAway ? state.mapVenues : venues,
            search: _session.search,
            pageTab: _session.pageTab,
            selectedSportId: _session.selectedSportId,
            clearSport: _session.selectedSportId == null,
            errorMessage: '',
          ),
        );
        if (pannedAway && state.mapViewport != null) {
          unawaited(_fetchMapVenues(state.mapViewport!, force: true));
        }
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
        state.pageTab == .venues) {
      return;
    }
    _mapDebounce?.cancel();
    _mapPrimed = false;
    _fetchedBoxKey = null;
    _session
      ..clearSearch()
      ..savePageTab(.venues)
      ..saveSportId(null);
    emit(
      state.copyWith(
        search: const ExploreSearchCriteria(),
        pageTab: .venues,
        clearSport: true,
        showBackToOrigin: false,
        mapVenues: const [],
        clearMapViewport: true,
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
    _mapDebounce?.cancel();
    _mapPrimed = false;
    _fetchedBoxKey = null;
    _session
      ..saveSearch(search)
      ..savePageTab(.venues);
    emit(
      state.copyWith(
        search: search,
        pageTab: .venues,
        showBackToOrigin: false,
        cameraFitNonce: state.cameraFitNonce + 1,
        clearMapViewport: true,
      ),
    );
    await load();
  }

  void clearPlace() {
    _mapDebounce?.cancel();
    _mapPrimed = false;
    _fetchedBoxKey = null;
    _session.clearSearch();
    emit(
      state.copyWith(
        search: const ExploreSearchCriteria(),
        showBackToOrigin: false,
        cameraFitNonce: state.cameraFitNonce + 1,
        clearMapViewport: true,
      ),
    );
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

  /// Camera settled. List tab stays on the search result; map refetches
  /// the visible box after the first paint.
  void onMapViewport(MapViewport viewport) {
    final away =
        state.search.hasCoordinates &&
        viewport.leftOrigin(state.search.lat!, state.search.lng!);
    emit(
      state.copyWith(
        mapViewport: viewport,
        showBackToOrigin: state.search.hasLocation && away,
      ),
    );
    if (!_mapPrimed) {
      _mapPrimed = true;
      _fetchedBoxKey = viewport.quantizedKey;
      return;
    }
    if (viewport.quantizedKey == _fetchedBoxKey) return;
    _mapDebounce?.cancel();
    if (mapDebounce == Duration.zero) {
      unawaited(_fetchMapVenues(viewport));
      return;
    }
    _mapDebounce = Timer(mapDebounce, () {
      unawaited(_fetchMapVenues(viewport));
    });
  }

  void returnToOrigin() {
    _mapDebounce?.cancel();
    _mapPrimed = false;
    _fetchedBoxKey = null;
    emit(
      state.copyWith(
        mapVenues: state.venues,
        showBackToOrigin: false,
        cameraFitNonce: state.cameraFitNonce + 1,
        clearMapViewport: true,
      ),
    );
  }

  Future<void> _fetchMapVenues(
    MapViewport viewport, {
    bool force = false,
  }) async {
    final box = viewport.padded(0.08);
    final key = viewport.quantizedKey;
    if (!force && key == _fetchedBoxKey) return;
    _fetchedBoxKey = key;
    final requestId = ++_mapRequestId;
    final result = await _listVenues(
      lat: box.centerLat,
      lng: box.centerLng,
      minLat: box.minLat,
      maxLat: box.maxLat,
      minLng: box.minLng,
      maxLng: box.maxLng,
      limit: 50,
    );
    if (isClosed || requestId != _mapRequestId) return;
    result.when(
      success: (page) {
        emit(
          state.copyWith(
            mapVenues: page.items.map((v) => v.toVenue()).toList(),
          ),
        );
      },
      failure: (_) {},
    );
  }

  Future<ApiResult<OffsetPage<AreanaVenue>>> _listVenues({
    double? lat,
    double? lng,
    double? radiusKm,
    double? minLat,
    double? maxLat,
    double? minLng,
    double? maxLng,
    required int limit,
  }) {
    final boxed = minLat != null;
    final sort = boxed
        ? (state.filter.sort == .recommended
              ? 'distance'
              : state.filter.apiSort)
        : (state.search.hasCoordinates && state.filter.sort == .recommended
              ? 'distance'
              : state.filter.apiSort);
    return _repository.fetchVenues(
      sport: SportGame.apiName(state.selectedSportId),
      sort: sort,
      minPrice: state.filter.apiMinPrice,
      maxPrice: state.filter.apiMaxPrice,
      lat: lat,
      lng: lng,
      radiusKm: radiusKm,
      minLat: minLat,
      maxLat: maxLat,
      minLng: minLng,
      maxLng: maxLng,
      page: 1,
      limit: limit,
    );
  }

  @override
  Future<void> close() {
    _mapDebounce?.cancel();
    return super.close();
  }
}
