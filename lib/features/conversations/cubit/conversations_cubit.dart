import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/app_loading.dart';
import '../../../core/services/session_aware_cubit.dart';
import '../../../core/services/session_cubit.dart';
import '../model/conversation_models.dart';
import 'conversations_repository.dart';
import 'conversations_state.dart';

class ConversationsCubit extends Cubit<ConversationsState>
    with SessionAwareCubit<ConversationsState> {
  ConversationsCubit(this._repository, [this.authSession])
    : super(const ConversationsState()) {
    bindAuth(onSignedIn: () { load(); }, onSignedOut: reset);
  }

  final ConversationsRepository _repository;
  @override
  final SessionCubit? authSession;
  var _requestId = 0;
  Timer? _searchDebounce;

  Future<void> load() => _loadFirst(showLoading: true);

  Future<void> refresh() => _loadFirst(showLoading: false);

  void setFilter(ConversationInboxFilter filter) {
    if (filter == state.filter) return;
    emit(state.copyWith(filter: filter));
  }

  void search(String query) {
    _searchDebounce?.cancel();
    emit(state.copyWith(query: query));
    _searchDebounce = Timer(const Duration(milliseconds: 280), () {
      _loadFirst(showLoading: true);
    });
  }

  void reset() {
    _requestId++;
    _searchDebounce?.cancel();
    if (!isClosed) emit(const ConversationsState());
  }

  Future<void> _loadFirst({required bool showLoading}) async {
    if (!canUseAuthedApi) {
      reset();
      return;
    }
    final id = ++_requestId;
    emit(
      state.copyWith(
        status: showLoading ? AppLoading.loading : state.status,
        errorMessage: '',
        threads: showLoading ? const [] : state.threads,
        clearCursor: true,
        isLoadingMore: false,
      ),
    );
    final result = await _repository.fetchThreads(q: state.query);
    if (isClosed || id != _requestId) return;
    result.when(
      success: (page) {
        emit(
          state.copyWith(
            status: AppLoading.success,
            threads: page.items,
            nextCursor: page.nextCursor,
            clearCursor: page.nextCursor == null,
            errorMessage: '',
          ),
        );
      },
      failure: (error) {
        emit(
          state.copyWith(
            status: showLoading ? AppLoading.error : state.status,
            errorMessage: error.message,
          ),
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (!canUseAuthedApi) return;
    if (state.isLoadingMore || !state.hasMore) return;
    final requestId = _requestId;
    emit(state.copyWith(isLoadingMore: true, errorMessage: ''));
    final result = await _repository.fetchThreads(
      cursor: state.nextCursor,
      q: state.query,
    );
    if (isClosed || requestId != _requestId) return;
    result.when(
      success: (page) {
        emit(
          state.copyWith(
            threads: [...state.threads, ...page.items],
            nextCursor: page.nextCursor,
            clearCursor: page.nextCursor == null,
            isLoadingMore: false,
          ),
        );
      },
      failure: (error) {
        emit(state.copyWith(isLoadingMore: false, errorMessage: error.message));
      },
    );
  }

  Future<ConversationThread?> openWithVenue({
    required String venueId,
    String? bookingId,
  }) async {
    if (!canUseAuthedApi) return null;
    final result = await _repository.openThread(
      venueId: venueId,
      bookingId: bookingId,
    );
    return result.when(
      success: (thread) => thread,
      failure: (_) => null,
    );
  }

  @override
  Future<void> close() async {
    _searchDebounce?.cancel();
    await unbindAuth();
    return super.close();
  }
}
