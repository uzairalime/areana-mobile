import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/app_loading.dart';
import '../model/message_filter_tab.dart';
import 'messages_repository.dart';
import 'messages_state.dart';

class MessagesCubit extends Cubit<MessagesState> {
  MessagesCubit(this._repository) : super(const MessagesState()) {
    load();
  }

  final MessagesRepository _repository;
  var _requestId = 0;

  Future<void> load() async {
    final id = ++_requestId;
    emit(state.copyWith(status: AppLoading.loading, errorMessage: ''));
    final result = await _repository.fetchThreads();
    if (isClosed || id != _requestId) return;
    result.when(
      success: (threads) {
        emit(
          state.copyWith(
            status: AppLoading.success,
            threads: threads,
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
    final result = await _repository.fetchThreads();
    if (isClosed || id != _requestId) return;
    result.when(
      success: (threads) {
        emit(
          state.copyWith(
            status: AppLoading.success,
            threads: threads,
            errorMessage: '',
          ),
        );
      },
      failure: (error) {
        emit(state.copyWith(errorMessage: error.message));
      },
    );
  }

  void setTab(MessageFilterTab tab) {
    if (tab == state.tab) return;
    emit(state.copyWith(tab: tab));
  }

  void markLocalRead(String threadId) {
    final index = state.threads.indexWhere((e) => e.id == threadId);
    if (index < 0 || !state.threads[index].hasUnread) return;
    final next = [...state.threads];
    next[index] = next[index].copyWith(unreadCount: 0);
    emit(state.copyWith(threads: next));
  }
}
