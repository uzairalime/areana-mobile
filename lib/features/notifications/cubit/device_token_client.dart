import 'package:dio/dio.dart';

import '../../../core/consts/api_endpoints.dart';
import '../../../core/services/api_result.dart';

class DeviceTokenClient {
  const DeviceTokenClient(this._dio);

  final Dio _dio;

  Future<ApiResult<void>> register({
    required String token,
    required String platform,
  }) async {
    try {
      await _dio.post<dynamic>(
        ApiEndpoints.usersMeDeviceTokens,
        data: {'token': token, 'platform': platform},
      );
      return const ApiSuccess(null);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }
}
