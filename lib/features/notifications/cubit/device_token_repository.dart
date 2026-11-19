import '../../../core/services/api_result.dart';
import 'device_token_client.dart';

class DeviceTokenRepository {
  const DeviceTokenRepository(this._client);

  final DeviceTokenClient _client;

  Future<ApiResult<void>> register({
    required String token,
    required String platform,
  }) => _client.register(token: token, platform: platform);
}
