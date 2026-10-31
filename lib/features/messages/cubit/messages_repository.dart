import '../../../core/config/app_config.dart';
import '../../../core/mock/mock_delay.dart';
import '../../../core/mock/mock_message_data.dart';
import '../../../core/services/api_result.dart';
import '../model/chat_message.dart';
import '../model/chat_thread.dart';
import 'messages_client.dart';

class MessagesRepository {
  const MessagesRepository(this._client);

  final MessagesClient _client;

  Future<ApiResult<List<ChatThread>>> fetchThreads() {
    if (AppConfig.useMockApi) {
      return MockDelay.run(() => ApiSuccess(MockMessageData.threads));
    }
    return _client.fetchThreads();
  }

  Future<ApiResult<ChatThread>> fetchThread(String id) {
    if (AppConfig.useMockApi) {
      return MockDelay.run(() {
        final thread = MockMessageData.threadById(id);
        if (thread == null) {
          return const ApiError(message: 'Conversation not found');
        }
        return ApiSuccess(thread);
      });
    }
    return _client.fetchThread(id);
  }

  Future<ApiResult<List<ChatMessage>>> fetchMessages(String threadId) {
    if (AppConfig.useMockApi) {
      return MockDelay.run(
        () => ApiSuccess(MockMessageData.messagesFor(threadId)),
      );
    }
    return _client.fetchMessages(threadId);
  }

  Future<ApiResult<ChatMessage>> sendMessage({
    required String threadId,
    required String text,
  }) {
    if (AppConfig.useMockApi) {
      return Future.value(
        ApiSuccess(MockMessageData.send(threadId, text)),
      );
    }
    return _client.sendMessage(threadId: threadId, text: text);
  }

  Future<ApiResult<void>> markRead(String threadId) {
    if (AppConfig.useMockApi) {
      MockMessageData.markThreadRead(threadId);
      return Future.value(const ApiSuccess(null));
    }
    return _client.markRead(threadId);
  }
}
