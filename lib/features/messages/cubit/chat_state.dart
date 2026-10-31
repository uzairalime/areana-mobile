import 'package:equatable/equatable.dart';

import '../../../core/enums/app_loading.dart';
import '../model/chat_message.dart';
import '../model/chat_thread.dart';

class ChatState extends Equatable {
  const ChatState({
    this.status = AppLoading.initial,
    this.sendStatus = AppLoading.initial,
    this.errorMessage = '',
    this.thread,
    this.messages = const [],
  });

  final AppLoading status;
  final AppLoading sendStatus;
  final String errorMessage;
  final ChatThread? thread;
  final List<ChatMessage> messages;

  ChatState copyWith({
    AppLoading? status,
    AppLoading? sendStatus,
    String? errorMessage,
    ChatThread? thread,
    List<ChatMessage>? messages,
    bool clearThread = false,
  }) {
    return ChatState(
      status: status ?? this.status,
      sendStatus: sendStatus ?? this.sendStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      thread: clearThread ? null : (thread ?? this.thread),
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [
    status,
    sendStatus,
    errorMessage,
    thread,
    messages,
  ];
}
