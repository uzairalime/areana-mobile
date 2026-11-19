import 'package:equatable/equatable.dart';

import '../../../core/enums/app_loading.dart';
import '../model/conversation_models.dart';

class ConversationsState extends Equatable {
  const ConversationsState({
    this.status = AppLoading.initial,
    this.errorMessage = '',
    this.threads = const [],
    this.nextCursor,
    this.isLoadingMore = false,
    this.query = '',
    this.filter = ConversationInboxFilter.all,
  });

  final AppLoading status;
  final String errorMessage;
  final List<ConversationThread> threads;
  final String? nextCursor;
  final bool isLoadingMore;
  final String query;
  final ConversationInboxFilter filter;

  bool get hasMore => nextCursor != null;

  int get unreadThreadCount =>
      threads.where((thread) => thread.hasUnread).length;

  List<ConversationThread> get visibleThreads => switch (filter) {
    .all => threads,
    .unread => threads.where((thread) => thread.hasUnread).toList(),
  };

  ConversationsState copyWith({
    AppLoading? status,
    String? errorMessage,
    List<ConversationThread>? threads,
    String? nextCursor,
    bool clearCursor = false,
    bool? isLoadingMore,
    String? query,
    ConversationInboxFilter? filter,
  }) {
    return ConversationsState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      threads: threads ?? this.threads,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      query: query ?? this.query,
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    threads,
    nextCursor,
    isLoadingMore,
    query,
    filter,
  ];
}
