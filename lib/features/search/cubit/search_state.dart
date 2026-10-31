import 'package:equatable/equatable.dart';

import '../../../core/enums/app_loading.dart';
import '../../home/model/venue.dart';
import '../model/search_models.dart';

class SearchState extends Equatable {
  const SearchState({
    this.status = AppLoading.initial,
    this.errorMessage = '',
    this.query = '',
    this.places = const [],
    this.venues = const [],
    this.recents = const [],
  });

  final AppLoading status;
  final String errorMessage;
  final String query;
  final List<PlaceSuggestion> places;
  final List<Venue> venues;
  final List<String> recents;

  /// Idle surface: Near me + last [RecentSearchStore.maxItems] queries.
  bool get showIdle =>
      query.trim().isEmpty && places.isEmpty && venues.isEmpty;

  bool get showEmptyResults =>
      query.trim().isNotEmpty &&
      status == AppLoading.success &&
      places.isEmpty &&
      venues.isEmpty;

  SearchState copyWith({
    AppLoading? status,
    String? errorMessage,
    String? query,
    List<PlaceSuggestion>? places,
    List<Venue>? venues,
    List<String>? recents,
  }) {
    return SearchState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      query: query ?? this.query,
      places: places ?? this.places,
      venues: venues ?? this.venues,
      recents: recents ?? this.recents,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    query,
    places,
    venues,
    recents,
  ];
}
