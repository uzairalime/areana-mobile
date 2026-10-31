import 'package:equatable/equatable.dart';

import '../../../core/enums/app_loading.dart';
import '../model/court_filter.dart';
import '../model/sport_game.dart';
import '../model/venue.dart';

class HomeState extends Equatable {
  const HomeState({
    this.status = AppLoading.initial,
    this.errorMessage = '',
    this.query = '',
    this.selectedSportId = 'all',
    this.venues = const [],
    this.sports = const [],
    this.filter = const CourtFilterDraft(),
  });

  final AppLoading status;
  final String errorMessage;
  final String query;

  /// Defaults to [SportGame.all.id].
  final String selectedSportId;
  final List<Venue> venues;
  final List<SportGame> sports;
  final CourtFilterDraft filter;

  bool get isAllSports => selectedSportId == SportGame.all.id;

  HomeState copyWith({
    AppLoading? status,
    String? errorMessage,
    String? query,
    String? selectedSportId,
    List<Venue>? venues,
    List<SportGame>? sports,
    CourtFilterDraft? filter,
  }) {
    return HomeState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      query: query ?? this.query,
      selectedSportId: selectedSportId ?? this.selectedSportId,
      venues: venues ?? this.venues,
      sports: sports ?? this.sports,
      filter: filter ?? this.filter,
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
  ];
}
