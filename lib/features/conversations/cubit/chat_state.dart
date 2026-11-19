import 'package:equatable/equatable.dart';

import '../../../core/enums/app_loading.dart';
import '../model/conversation_models.dart';

class ChatState extends Equatable {
  const ChatState({
    this.status = AppLoading.initial,
    this.errorMessage = '',
    this.thread,
    this.messages = const [],
    this.nextCursor,
    this.isLoadingMore = false,
    this.sending = false,
  });

  final AppLoading status;
  final String errorMessage;
  final ConversationThread? thread;
  final List<ChatMessage> messages;
  final String? nextCursor;
  final bool isLoadingMore;
  final bool sending;

  bool get hasMore => nextCursor != null;

  ChatState copyWith({
    AppLoading? status,
    String? errorMessage,
    ConversationThread? thread,
    List<ChatMessage>? messages,
    String? nextCursor,
    bool clearCursor = false,
    bool? isLoadingMore,
    bool? sending,
  }) {
    return ChatState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      thread: thread ?? this.thread,
      messages: messages ?? this.messages,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      sending: sending ?? this.sending,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    thread,
    messages,
    nextCursor,
    isLoadingMore,
    sending,
  ];
}
