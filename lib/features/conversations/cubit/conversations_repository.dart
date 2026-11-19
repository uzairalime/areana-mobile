import '../../../core/services/api_result.dart';
import '../../../core/services/pagination.dart';
import '../model/conversation_models.dart';
import 'conversations_client.dart';

class ConversationsRepository {
  const ConversationsRepository(this._client);

  final ConversationsClient _client;

  Future<ApiResult<CursorPage<ConversationThread>>> fetchThreads({
    String? cursor,
    String? q,
  }) => _client.fetchThreads(cursor: cursor, q: q);

  Future<ApiResult<ConversationThread>> openThread({
    required String venueId,
    String? bookingId,
  }) => _client.openThread(venueId: venueId, bookingId: bookingId);

  Future<ApiResult<ConversationThread>> fetchThread(String id) =>
      _client.fetchThread(id);

  Future<ApiResult<CursorPage<ChatMessage>>> fetchMessages({
    required String conversationId,
    String? cursor,
  }) => _client.fetchMessages(conversationId: conversationId, cursor: cursor);

  Future<ApiResult<ChatMessage>> sendMessage({
    required String conversationId,
    required String body,
  }) => _client.sendMessage(conversationId: conversationId, body: body);

  Future<ApiResult<void>> markRead(String conversationId) =>
      _client.markRead(conversationId);
}
