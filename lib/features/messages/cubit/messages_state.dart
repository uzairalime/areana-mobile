import 'package:equatable/equatable.dart';

import '../../../core/enums/app_loading.dart';
import '../model/chat_thread.dart';
import '../model/message_filter_tab.dart';

class MessagesState extends Equatable {
  const MessagesState({
    this.status = AppLoading.initial,
    this.errorMessage = '',
    this.tab = .all,
    this.threads = const [],
  });

  final AppLoading status;
  final String errorMessage;
  final MessageFilterTab tab;
  final List<ChatThread> threads;

  List<ChatThread> get visibleThreads => switch (tab) {
    .all => threads,
    .unread => [
      for (final thread in threads)
        if (thread.hasUnread) thread,
    ],
  };

  MessagesState copyWith({
    AppLoading? status,
    String? errorMessage,
    MessageFilterTab? tab,
    List<ChatThread>? threads,
  }) {
    return MessagesState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      tab: tab ?? this.tab,
      threads: threads ?? this.threads,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, tab, threads];
}
