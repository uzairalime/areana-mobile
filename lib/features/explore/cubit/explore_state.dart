import 'package:equatable/equatable.dart';

import '../../../core/enums/app_loading.dart';
import '../../home/model/court_filter.dart';
import '../../home/model/venue.dart';
import '../model/explore_models.dart';

class ExploreState extends Equatable {
  const ExploreState({
    this.status = AppLoading.initial,
    this.errorMessage = '',
    this.venues = const [],
    this.pageTab = .courts,
    this.selectedSportId,
    this.search = const ExploreSearchCriteria(),
    this.filter = const CourtFilterDraft(),
  });

  final AppLoading status;
  final String errorMessage;
  final List<Venue> venues;
  final ExplorePageTab pageTab;
  final String? selectedSportId;
  final ExploreSearchCriteria search;
  final CourtFilterDraft filter;

  List<Venue> get visibleVenues {
    Iterable<Venue> list = venues;
    // Near me keeps the full catalog (sorted elsewhere / map uses GPS).
    if (!search.isNearby) {
      final location = search.location.trim().toLowerCase();
      if (location.isNotEmpty) {
        final city = location.split(',').first.trim();
        list = list.where((v) {
          final loc = v.location.toLowerCase();
          return loc.contains(city) || loc.contains(location);
        });
      }
    }
    final sportId = selectedSportId;
    if (sportId != null) {
      final needle = _sportNeedle(sportId);
      if (needle.isNotEmpty) {
        list = list.where((v) => v.sport.toLowerCase().contains(needle));
      }
    }
    return list.toList();
  }

  static String _sportNeedle(String id) => switch (id) {
    'football' => 'football',
    'padel' => 'padel',
    'indoor_cricket' => 'cricket',
    'courts' => '',
    _ => id,
  };

  ExploreState copyWith({
    AppLoading? status,
    String? errorMessage,
    List<Venue>? venues,
    ExplorePageTab? pageTab,
    String? selectedSportId,
    bool clearSport = false,
    ExploreSearchCriteria? search,
    CourtFilterDraft? filter,
  }) {
    return ExploreState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      venues: venues ?? this.venues,
      pageTab: pageTab ?? this.pageTab,
      selectedSportId: clearSport
          ? null
          : (selectedSportId ?? this.selectedSportId),
      search: search ?? this.search,
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    venues,
    pageTab,
    selectedSportId,
    search,
    filter,
  ];
}
