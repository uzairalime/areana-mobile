import 'package:equatable/equatable.dart';

import '../../../core/enums/app_loading.dart';
import '../model/areana_models.dart';
import '../model/court_filter.dart';
import '../model/sport_game.dart';
import '../model/venue.dart';

/// Home/discovery state. `venues` are the UI-mapped rows (see
/// [AreanaVenue.toVenue]) so existing cards keep working; `courts`
/// are the raw Areana court list items for the Courts tab.
class HomeState extends Equatable {
  const HomeState({
    this.status = AppLoading.initial,
    this.errorMessage = '',
    this.query = '',
    this.selectedSportId = 'all',
    this.venues = const [],
    this.sports = const [],
    this.filter = const CourtFilterDraft(),
    this.courts = const [],
    this.cities = const [],
    this.selectedCity,
    this.sort,
    this.lat,
    this.lng,
    this.showingCourts = false,
    this.page = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.banners = const [],
  });

  final AppLoading status;
  final String errorMessage;
  final String query;

  /// Defaults to [SportGame.all.id].
  final String selectedSportId;
  final List<Venue> venues;
  final List<SportGame> sports;
  final CourtFilterDraft filter;
  final List<AreanaCourtListItem> courts;
  final List<String> cities;
  final String? selectedCity;

  /// Server sort: `rating` (default), `price_asc`, `price_desc`,
  /// `name`, `distance` (requires lat+lng).
  final String? sort;
  final double? lat;
  final double? lng;
  final bool showingCourts;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final List<AreanaBanner> banners;

  bool get isAllSports => selectedSportId == SportGame.all.id;

  bool get hasLocation => lat != null && lng != null;

  String? get selectedSportName {
    if (isAllSports) return null;
    for (final sport in sports) {
      if (sport.id == selectedSportId) return sport.label;
    }
    return selectedSportId;
  }

  HomeState copyWith({
    AppLoading? status,
    String? errorMessage,
    String? query,
    String? selectedSportId,
    List<Venue>? venues,
    List<SportGame>? sports,
    CourtFilterDraft? filter,
    List<AreanaCourtListItem>? courts,
    List<String>? cities,
    String? selectedCity,
    String? sort,
    double? lat,
    double? lng,
    bool? showingCourts,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    List<AreanaBanner>? banners,
    bool clearCity = false,
    bool clearLocation = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      query: query ?? this.query,
      selectedSportId: selectedSportId ?? this.selectedSportId,
      venues: venues ?? this.venues,
      sports: sports ?? this.sports,
      filter: filter ?? this.filter,
      courts: courts ?? this.courts,
      cities: cities ?? this.cities,
      selectedCity: clearCity ? null : selectedCity ?? this.selectedCity,
      sort: sort ?? this.sort,
      lat: clearLocation ? null : lat ?? this.lat,
      lng: clearLocation ? null : lng ?? this.lng,
      showingCourts: showingCourts ?? this.showingCourts,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      banners: banners ?? this.banners,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    query,
    selectedSportId,
    venues,
    sports,
    filter,
    courts,
    cities,
    selectedCity,
    sort,
    lat,
    lng,
    showingCourts,
    page,
    hasMore,
    isLoadingMore,
    banners,
  ];
}
