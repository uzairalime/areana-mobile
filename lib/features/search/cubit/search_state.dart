import 'package:equatable/equatable.dart';

import '../../../core/enums/app_loading.dart';
import '../model/search_models.dart';

class SearchState extends Equatable {
  const SearchState({
    this.status = AppLoading.initial,
    this.errorMessage = '',
    this.query = '',
    this.places = const [],
    this.recents = const [],
  });

  final AppLoading status;
  final String errorMessage;
  final String query;
  final List<PlaceSuggestion> places;
  final List<RecentPlace> recents;

  bool get showIdle => query.trim().isEmpty && places.isEmpty;

  bool get showEmptyResults =>
      query.trim().isNotEmpty &&
      status == AppLoading.success &&
      places.isEmpty;

  SearchState copyWith({
    AppLoading? status,
    String? errorMessage,
    String? query,
    List<PlaceSuggestion>? places,
    List<RecentPlace>? recents,
  }) {
    return SearchState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      query: query ?? this.query,
      places: places ?? this.places,
      recents: recents ?? this.recents,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, query, places, recents];
}
