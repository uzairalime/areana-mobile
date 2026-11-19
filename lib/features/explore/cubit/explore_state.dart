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

  List<Venue> get visibleVenues => venues;

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
