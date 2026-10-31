import '../../../core/config/app_config.dart';
import '../../../core/mock/mock_delay.dart';
import '../../../core/mock/mock_notification_data.dart';
import '../../../core/services/api_result.dart';
import '../model/app_notification.dart';
import 'notifications_client.dart';

class NotificationsRepository {
  const NotificationsRepository(this._client);

  final NotificationsClient _client;

  Future<ApiResult<List<AppNotification>>> fetchNotifications() {
    if (AppConfig.useMockApi) {
      return MockDelay.run(() => ApiSuccess(MockNotificationData.items));
    }
    return _client.fetchNotifications();
  }

  Future<ApiResult<void>> markRead(String id) {
    if (AppConfig.useMockApi) {
      MockNotificationData.markRead(id);
      return Future.value(const ApiSuccess(null));
    }
    return _client.markRead(id);
  }

  Future<ApiResult<void>> markAllRead() {
    if (AppConfig.useMockApi) {
      MockNotificationData.markAllRead();
      return Future.value(const ApiSuccess(null));
    }
    return _client.markAllRead();
  }
}
