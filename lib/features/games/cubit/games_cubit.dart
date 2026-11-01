import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/app_loading.dart';
import 'games_repository.dart';
import 'games_state.dart';

class GamesCubit extends Cubit<GamesState> {
  GamesCubit(this._repository) : super(const GamesState()) {
    load();
  }

  final GamesRepository _repository;
  var _requestId = 0;

  Future<void> load() async {
    final id = ++_requestId;
    emit(
      state.copyWith(
        status: AppLoading.loading,
        errorMessage: '',
        games: const [],
        page: 1,
        hasMore: true,
      ),
    );
    final result = await _repository.fetchGames(
      sport: state.sport,
      city: state.city,
      date: state.date,
    );
    if (isClosed || id != _requestId) return;
    result.when(
      success: (page) {
        emit(
          state.copyWith(
            status: AppLoading.success,
            games: page.items,
            page: page.page,
            hasMore: page.hasMore,
            errorMessage: '',
          ),
        );
      },
      failure: (error) {
        emit(
          state.copyWith(
            status: AppLoading.error,
            errorMessage: error.message,
          ),
        );
      },
    );
  }

  Future<void> refresh() async {
    final id = ++_requestId;
    final result = await _repository.fetchGames(
      sport: state.sport,
      city: state.city,
      date: state.date,
    );
    if (isClosed || id != _requestId) return;
    result.when(
      success: (page) {
        emit(
          state.copyWith(
            status: AppLoading.success,
            games: page.items,
            page: page.page,
            hasMore: page.hasMore,
            errorMessage: '',
          ),
        );
      },
      failure: (error) {
        emit(state.copyWith(errorMessage: error.message));
      },
    );
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    emit(state.copyWith(isLoadingMore: true));
    final result = await _repository.fetchGames(
      sport: state.sport,
      city: state.city,
      date: state.date,
      page: state.page + 1,
    );
    if (isClosed) return;
    result.when(
      success: (page) {
        emit(
          state.copyWith(
            games: [...state.games, ...page.items],
            page: page.page,
            hasMore: page.hasMore,
            isLoadingMore: false,
          ),
        );
      },
      failure: (_) {
        emit(state.copyWith(isLoadingMore: false));
      },
    );
  }

  void setFilters({String? sport, String? city, String? date}) {
    emit(
      state.copyWith(
        sport: sport ?? state.sport,
        city: city ?? state.city,
        date: date ?? state.date,
      ),
    );
    load();
  }

  void clearFilters() {
    emit(state.copyWith(sport: '', city: '', date: ''));
    load();
  }

  Future<void> loadDetail(String id) async {
    emit(state.copyWith(detailStatus: AppLoading.loading));
    final result = await _repository.fetchGame(id);
    if (isClosed) return;
    result.when(
      success: (detail) {
        emit(
          state.copyWith(detail: detail, detailStatus: AppLoading.success),
        );
      },
      failure: (error) {
        emit(
          state.copyWith(
            detailStatus: AppLoading.error,
            errorMessage: error.message,
          ),
        );
      },
    );
  }

  Future<void> loadPostableBookings() async {
    emit(state.copyWith(postableStatus: AppLoading.loading));
    final result = await _repository.fetchPostableBookings();
    if (isClosed) return;
    result.when(
      success: (bookings) {
        emit(
          state.copyWith(
            postableBookings: bookings,
            postableStatus: AppLoading.success,
          ),
        );
      },
      failure: (error) {
        emit(
          state.copyWith(
            postableStatus: AppLoading.error,
            errorMessage: error.message,
          ),
        );
      },
    );
  }

  Future<bool> _manage(
    String id,
    Future<bool> Function() run,
  ) async {
    if (state.managingId.isNotEmpty) return false;
    emit(state.copyWith(managingId: id, errorMessage: ''));
    final ok = await run();
    if (isClosed) return false;
    emit(state.copyWith(managingId: ''));
    return ok;
  }

  // Join may be instant or a host-approved request (server rule
  // unverified), so refresh from the server instead of guessing
  // the resulting join state.
  Future<bool> joinGame(String id) => _manage(id, () async {
    final result = await _repository.joinGame(id);
    if (isClosed) return false;
    return result.when(
      success: (_) async {
        await refresh();
        return true;
      },
      failure: (error) {
        emit(state.copyWith(errorMessage: error.message));
        return false;
      },
    );
  });

  Future<bool> leaveGame(String id) => _manage(id, () async {
    final result = await _repository.leaveGame(id);
    if (isClosed) return false;
    return result.when(
      success: (_) async {
        await refresh();
        return true;
      },
      failure: (error) {
        emit(state.copyWith(errorMessage: error.message));
        return false;
      },
    );
  });

  Future<bool> deleteGame(String id) => _manage(id, () async {
    final result = await _repository.deleteGame(id);
    if (isClosed) return false;
    return result.when(
      success: (_) {
        emit(
          state.copyWith(
            games: state.games.where((g) => g.id != id).toList(),
          ),
        );
        return true;
      },
      failure: (error) {
        emit(state.copyWith(errorMessage: error.message));
        return false;
      },
    );
  });

  Future<bool> createGame({
    required String bookingId,
    required int playersNeeded,
    int? squadSize,
    String? level,
    String? note,
  }) async {
    final result = await _repository.createGame(
      bookingId: bookingId,
      playersNeeded: playersNeeded,
      squadSize: squadSize,
      level: level,
      note: note,
    );
    if (isClosed) return false;
    return result.when(
      success: (post) {
        emit(state.copyWith(games: [post, ...state.games]));
        return true;
      },
      failure: (error) {
        emit(state.copyWith(errorMessage: error.message));
        return false;
      },
    );
  }
}
