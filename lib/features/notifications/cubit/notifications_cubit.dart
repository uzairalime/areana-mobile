import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/app_loading.dart';
import '../model/notification_filter_tab.dart';
import 'notifications_repository.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._repository) : super(const NotificationsState()) {
    load();
  }

  final NotificationsRepository _repository;
  var _requestId = 0;

  Future<void> load() async {
    final id = ++_requestId;
    emit(
      state.copyWith(
        status: AppLoading.loading,
        errorMessage: '',
        items: const [],
        clearCursor: true,
        hasMore: true,
      ),
    );
    final result = await _repository.fetchNotifications();
    if (isClosed || id != _requestId) return;
    result.when(
      success: (page) {
        emit(
          state.copyWith(
            status: AppLoading.success,
            items: page.items,
            nextCursor: page.nextCursor,
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
    final result = await _repository.fetchNotifications();
    if (isClosed || id != _requestId) return;
    result.when(
      success: (page) {
        emit(
          state.copyWith(
            status: AppLoading.success,
            items: page.items,
            nextCursor: page.nextCursor,
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
    final result = await _repository.fetchNotifications(
      cursor: state.nextCursor,
    );
    if (isClosed) return;
    result.when(
      success: (page) {
        emit(
          state.copyWith(
            items: [...state.items, ...page.items],
            nextCursor: page.nextCursor,
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

  void setTab(NotificationFilterTab tab) {
    if (tab == state.tab) return;
    emit(state.copyWith(tab: tab));
  }

  /// Optimistic read — list updates immediately; API/mock sync in background.
  Future<void> markRead(String id) async {
    final index = state.items.indexWhere((e) => e.id == id);
    if (index < 0 || state.items[index].isRead) return;

    final next = [...state.items];
    next[index] = next[index].copyWith(isRead: true);
    emit(state.copyWith(items: next));

    final result = await _repository.markRead(id);
    if (isClosed) return;
    result.when(
      success: (_) {},
      failure: (_) {
        // Keep optimistic UI; next refresh reconciles with server.
      },
    );
  }

  Future<void> markAllRead() async {
    if (!state.hasUnread || state.markingAllRead) return;

    final snapshot = state.items;
    emit(
      state.copyWith(
        markingAllRead: true,
        items: [
          for (final item in snapshot)
            item.isRead ? item : item.copyWith(isRead: true),
        ],
      ),
    );

    final result = await _repository.markAllRead();
    if (isClosed) return;
    result.when(
      success: (_) {
        emit(state.copyWith(markingAllRead: false));
      },
      failure: (error) {
        emit(
          state.copyWith(
            markingAllRead: false,
            items: snapshot,
            errorMessage: error.message,
          ),
        );
      },
    );
  }
}
