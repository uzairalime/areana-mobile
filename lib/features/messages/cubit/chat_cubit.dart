import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/app_loading.dart';
import 'chat_state.dart';
import 'messages_repository.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(this._repository, {required this.threadId})
    : super(const ChatState()) {
    load();
  }

  final MessagesRepository _repository;
  final String threadId;
  var _requestId = 0;

  Future<void> load() async {
    final id = ++_requestId;
    emit(state.copyWith(status: AppLoading.loading, errorMessage: ''));

    final threadResult = await _repository.fetchThread(threadId);
    if (isClosed || id != _requestId) return;

    final thread = threadResult.dataOrNull;
    if (thread == null) {
      emit(
        state.copyWith(
          status: AppLoading.error,
          errorMessage: threadResult.errorOrNull?.message ?? 'Not found',
        ),
      );
      return;
    }

    final messagesResult = await _repository.fetchMessages(threadId);
    if (isClosed || id != _requestId) return;

    messagesResult.when(
      success: (messages) {
        emit(
          state.copyWith(
            status: AppLoading.success,
            thread: thread.copyWith(unreadCount: 0),
            messages: messages,
            errorMessage: '',
          ),
        );
      },
      failure: (error) {
        emit(
          state.copyWith(
            status: AppLoading.error,
            thread: thread,
            errorMessage: error.message,
          ),
        );
      },
    );

    await _repository.markRead(threadId);
  }

  Future<void> send(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || state.sendStatus == AppLoading.loading) return;

    emit(state.copyWith(sendStatus: AppLoading.loading, errorMessage: ''));
    final result = await _repository.sendMessage(
      threadId: threadId,
      text: text,
    );
    if (isClosed) return;

    result.when(
      success: (message) {
        emit(
          state.copyWith(
            sendStatus: AppLoading.success,
            messages: [...state.messages, message],
            thread: state.thread?.copyWith(
              preview: message.text,
              timeLabel: message.timeLabel,
              unreadCount: 0,
            ),
          ),
        );
      },
      failure: (error) {
        emit(
          state.copyWith(
            sendStatus: AppLoading.error,
            errorMessage: error.message,
          ),
        );
      },
    );
  }
}
