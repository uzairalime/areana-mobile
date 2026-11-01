import 'package:equatable/equatable.dart';

import '../../../core/enums/app_loading.dart';
import '../../bookings/model/user_booking.dart';
import '../model/game_post.dart';

class GamesState extends Equatable {
  const GamesState({
    this.status = AppLoading.initial,
    this.errorMessage = '',
    this.games = const [],
    this.sport = '',
    this.city = '',
    this.date = '',
    this.page = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.managingId = '',
    this.detail,
    this.detailStatus = AppLoading.initial,
    this.postableBookings = const [],
    this.postableStatus = AppLoading.initial,
  });

  final AppLoading status;
  final String errorMessage;
  final List<GamePost> games;
  final String sport;
  final String city;
  final String date;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final String managingId;
  final GamePostDetail? detail;
  final AppLoading detailStatus;
  final List<UserBooking> postableBookings;
  final AppLoading postableStatus;

  bool isManaging(String id) => managingId == id;

  GamesState copyWith({
    AppLoading? status,
    String? errorMessage,
    List<GamePost>? games,
    String? sport,
    String? city,
    String? date,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    String? managingId,
    GamePostDetail? detail,
    AppLoading? detailStatus,
    List<UserBooking>? postableBookings,
    AppLoading? postableStatus,
  }) {
    return GamesState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      games: games ?? this.games,
      sport: sport ?? this.sport,
      city: city ?? this.city,
      date: date ?? this.date,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      managingId: managingId ?? this.managingId,
      detail: detail ?? this.detail,
      detailStatus: detailStatus ?? this.detailStatus,
      postableBookings: postableBookings ?? this.postableBookings,
      postableStatus: postableStatus ?? this.postableStatus,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    games,
    sport,
    city,
    date,
    page,
    hasMore,
    isLoadingMore,
    managingId,
    detail,
    detailStatus,
    postableBookings,
    postableStatus,
  ];
}
