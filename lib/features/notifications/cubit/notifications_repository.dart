import '../../../core/services/api_result.dart';
import '../../../core/services/pagination.dart';
import '../model/app_notification.dart';
import 'notifications_client.dart';

class NotificationsRepository {
  const NotificationsRepository(this._client);

  final NotificationsClient _client;

  Future<ApiResult<CursorPage<AppNotification>>> fetchNotifications({
    String? cursor,
  }) => _client.fetchNotifications(cursor: cursor);

  Future<ApiResult<int>> fetchUnreadCount() => _client.fetchUnreadCount();

  Future<ApiResult<void>> markRead(String id) => _client.markRead(id);

  Future<ApiResult<void>> markAllRead() => _client.markAllRead();
}
