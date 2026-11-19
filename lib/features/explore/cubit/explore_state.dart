import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/enums/app_loading.dart';
import '../../../core/utils/venue_map_clustering.dart';
import '../../home/model/court_filter.dart';
import '../../home/model/venue.dart';
import '../model/explore_models.dart';

class ExploreState extends Equatable {
  const ExploreState({
    this.status = AppLoading.initial,
    this.errorMessage = '',
    this.venues = const [],
    this.mapVenues = const [],
    this.pageTab = .venues,
    this.selectedSportId,
    this.search = const ExploreSearchCriteria(),
    this.filter = const CourtFilterDraft(),
    this.showBackToOrigin = false,
    this.cameraFitNonce = 0,
    this.mapViewport,
  });

  final AppLoading status;
  final String errorMessage;
  final List<Venue> venues;
  final List<Venue> mapVenues;
  final ExplorePageTab pageTab;
  final String? selectedSportId;
  final ExploreSearchCriteria search;
  final CourtFilterDraft filter;
  final bool showBackToOrigin;
  final int cameraFitNonce;
  final MapViewport? mapViewport;

  List<Venue> get visibleVenues => venues;

  List<Venue> get visibleMapVenues => mapVenues;

  String get backToOriginLabel {
    final place = search.location.trim();
    if (place.isEmpty) return 'Back to search';
    return 'Back to $place';
  }

  LatLng? get originFocus {
    final lat = search.lat;
    final lng = search.lng;
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  ExploreState copyWith({
    AppLoading? status,
    String? errorMessage,
    List<Venue>? venues,
    List<Venue>? mapVenues,
    ExplorePageTab? pageTab,
    String? selectedSportId,
    bool clearSport = false,
    ExploreSearchCriteria? search,
    CourtFilterDraft? filter,
    bool? showBackToOrigin,
    int? cameraFitNonce,
    MapViewport? mapViewport,
    bool clearMapViewport = false,
  }) {
    return ExploreState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      venues: venues ?? this.venues,
      mapVenues: mapVenues ?? this.mapVenues,
      pageTab: pageTab ?? this.pageTab,
      selectedSportId: clearSport
          ? null
          : (selectedSportId ?? this.selectedSportId),
      search: search ?? this.search,
      filter: filter ?? this.filter,
      showBackToOrigin: showBackToOrigin ?? this.showBackToOrigin,
      cameraFitNonce: cameraFitNonce ?? this.cameraFitNonce,
      mapViewport: clearMapViewport ? null : (mapViewport ?? this.mapViewport),
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    venues,
    mapVenues,
    pageTab,
    selectedSportId,
    search,
    filter,
    showBackToOrigin,
    cameraFitNonce,
    mapViewport,
  ];
}
