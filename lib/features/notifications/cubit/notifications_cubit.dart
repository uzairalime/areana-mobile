import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/app_loading.dart';
import '../../../core/services/session_aware_cubit.dart';
import '../../../core/services/session_cubit.dart';
import '../model/app_notification.dart';
import '../model/notification_filter_tab.dart';
import 'notifications_repository.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState>
    with SessionAwareCubit<NotificationsState> {
  NotificationsCubit(this._repository, [this.authSession])
    : super(const NotificationsState()) {
    bindAuth(
      onSignedIn: () {
        unawaited(refreshUnread());
        load();
      },
      onSignedOut: reset,
    );
  }

  final NotificationsRepository _repository;
  @override
  final SessionCubit? authSession;
  var _requestId = 0;
  bool _isRefreshing = false;

  Future<void> load() => _loadFirstPage(showLoading: true);

  Future<void> refresh() => _loadFirstPage(showLoading: false);

  void reset() {
    _requestId++;
    _isRefreshing = false;
    if (!isClosed) emit(const NotificationsState());
  }

  Future<void> _loadFirstPage({required bool showLoading}) async {
    if (!canUseAuthedApi) {
      reset();
      return;
    }
    final id = ++_requestId;
    _isRefreshing = true;
    emit(
      state.copyWith(
        status: showLoading ? AppLoading.loading : state.status,
        errorMessage: '',
        items: showLoading ? const [] : state.items,
        clearCursor: showLoading,
        hasMore: showLoading ? true : state.hasMore,
        isLoadingMore: false,
      ),
    );
    final result = await _repository.fetchNotifications();
    if (isClosed || id != _requestId) return;
    _isRefreshing = false;
    result.when(
      success: (page) {
        emit(
          state.copyWith(
            status: AppLoading.success,
            items: page.items,
            unreadCount: _unreadIn(page.items),
            nextCursor: page.nextCursor,
            clearCursor: page.nextCursor == null,
            hasMore: page.hasMore,
            errorMessage: '',
          ),
        );
        unawaited(refreshUnread());
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
    if (_isRefreshing || state.isLoadingMore || !state.hasMore) return;
    final requestId = _requestId;
    emit(state.copyWith(isLoadingMore: true, errorMessage: ''));
    final result = await _repository.fetchNotifications(
      cursor: state.nextCursor,
    );
    if (isClosed || requestId != _requestId) return;
    result.when(
      success: (page) {
        emit(
          state.copyWith(
            items: [...state.items, ...page.items],
            nextCursor: page.nextCursor,
            clearCursor: page.nextCursor == null,
            hasMore: page.hasMore,
            isLoadingMore: false,
          ),
        );
      },
      failure: (error) {
        emit(state.copyWith(isLoadingMore: false, errorMessage: error.message));
      },
    );
  }

  void setTab(NotificationFilterTab tab) {
    if (tab == state.tab) return;
    emit(state.copyWith(tab: tab));
  }

  @override
  Future<void> close() async {
    await unbindAuth();
    return super.close();
  }

  /// Inbox badge on the home/bookings app bar. Cheap GET; ignores failures.
  Future<void> refreshUnread() async {
    if (!canUseAuthedApi) {
      if (!isClosed && state.unreadCount != 0) {
        emit(state.copyWith(unreadCount: 0));
      }
      return;
    }
    final result = await _repository.fetchUnreadCount();
    if (isClosed) return;
    result.when(
      success: (count) {
        final next = count < 0 ? 0 : count;
        if (state.unreadCount == next) return;
        emit(state.copyWith(unreadCount: next));
      },
      failure: (_) {},
    );
  }

  /// Optimistic read — list updates immediately; API/mock sync in background.
  Future<void> markRead(String id) async {
    if (!canUseAuthedApi) return;
    final index = state.items.indexWhere((e) => e.id == id);
    if (index < 0 || state.items[index].isRead) return;

    final next = [...state.items];
    next[index] = next[index].copyWith(isRead: true);
    emit(
      state.copyWith(
        items: next,
        unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
      ),
    );

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
    if (!canUseAuthedApi) return;
    if (!state.hasUnread || state.markingAllRead) return;

    final snapshot = state.items;
    final previousUnread = state.unreadCount;
    emit(
      state.copyWith(
        markingAllRead: true,
        unreadCount: 0,
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
        emit(state.copyWith(markingAllRead: false, unreadCount: 0));
      },
      failure: (error) {
        emit(
          state.copyWith(
            markingAllRead: false,
            items: snapshot,
            unreadCount: previousUnread,
            errorMessage: error.message,
          ),
        );
      },
    );
  }

  int _unreadIn(List<AppNotification> items) =>
      items.where((item) => item.isUnread).length;
}
