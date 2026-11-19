import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/app_loading.dart';
import '../model/conversation_models.dart';
import 'chat_state.dart';
import 'conversations_repository.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(
    this._repository, {
    required this.conversationId,
    ConversationThread? seed,
  }) : super(ChatState(thread: seed)) {
    load();
  }

  final ConversationsRepository _repository;
  final String conversationId;
  var _requestId = 0;

  Future<void> load() async {
    final id = ++_requestId;
    emit(state.copyWith(status: AppLoading.loading, errorMessage: ''));
    final thread = _repository.fetchThread(conversationId);
    final messages = _repository.fetchMessages(conversationId: conversationId);
    final threadResult = await thread;
    final messageResult = await messages;
    if (isClosed || id != _requestId) return;
    ConversationThread? nextThread = state.thread;
    threadResult.when(
      success: (value) => nextThread = value,
      failure: (_) {},
    );
    messageResult.when(
      success: (page) {
        emit(
          state.copyWith(
            status: AppLoading.success,
            thread: nextThread,
            messages: page.items,
            nextCursor: page.nextCursor,
            clearCursor: page.nextCursor == null,
            errorMessage: '',
          ),
        );
      },
      failure: (error) {
        emit(
          state.copyWith(
            status: AppLoading.error,
            thread: nextThread,
            errorMessage: error.message,
          ),
        );
      },
    );
    unawaited(_repository.markRead(conversationId));
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    final requestId = _requestId;
    emit(state.copyWith(isLoadingMore: true));
    final result = await _repository.fetchMessages(
      conversationId: conversationId,
      cursor: state.nextCursor,
    );
    if (isClosed || requestId != _requestId) return;
    result.when(
      success: (page) {
        emit(
          state.copyWith(
            messages: [...state.messages, ...page.items],
            nextCursor: page.nextCursor,
            clearCursor: page.nextCursor == null,
            isLoadingMore: false,
          ),
        );
      },
      failure: (_) {
        emit(state.copyWith(isLoadingMore: false));
      },
    );
  }

  Future<bool> send(String raw) async {
    final body = raw.trim();
    if (body.isEmpty || state.sending) return false;
    emit(state.copyWith(sending: true, errorMessage: ''));
    final result = await _repository.sendMessage(
      conversationId: conversationId,
      body: body,
    );
    if (isClosed) return false;
    return result.when(
      success: (message) {
        emit(
          state.copyWith(
            sending: false,
            messages: [message, ...state.messages],
            thread: state.thread?.copyWith(unreadCount: 0),
          ),
        );
        return true;
      },
      failure: (error) {
        emit(state.copyWith(sending: false, errorMessage: error.message));
        return false;
      },
    );
  }

}
