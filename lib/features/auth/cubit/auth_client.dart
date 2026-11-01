import 'package:dio/dio.dart';

import '../../../core/consts/api_endpoints.dart';
import '../../../core/services/api_result.dart';
import '../model/auth_session.dart';
import '../model/otp_models.dart';
import '../model/user_model.dart';

/// Areana player auth client — passwordless email OTP, same endpoints
/// as user-web `/auth`. No password, social, or forgot-password calls:
/// players have no password to forget, and a new account is created by
/// the first successful verify that carries name + phone.
class AuthClient {
  const AuthClient(this._dio);

  final Dio _dio;

  Future<ApiResult<OtpRequestResponse>> requestOtp({
    required String email,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiEndpoints.requestOtp,
        data: {'email': email},
      );
      final data = response.data;
      if (data is! Map) {
        return const ApiError(message: 'Unexpected response');
      }
      return ApiSuccess(
        OtpRequestResponse.fromJson(Map<String, dynamic>.from(data)),
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<OtpVerifyResponse>> verifyOtp({
    required String email,
    required String code,
    String? name,
    String? phone,
    String? city,
    String? referralCode,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiEndpoints.verifyOtp,
        data: {
          'email': email,
          'code': code,
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
          if (city != null) 'city': city,
          if (referralCode != null) 'referralCode': referralCode,
        },
      );
      final data = response.data;
      if (data is! Map) {
        return const ApiError(message: 'Unexpected response');
      }
      return ApiSuccess(
        OtpVerifyResponse.fromJson(Map<String, dynamic>.from(data)),
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  /// Best-effort server logout (web `revokePlayerSession`): revokes the
  /// refresh session. Callers clear local tokens regardless of result.
  Future<void> logout({required String refreshToken}) async {
    try {
      await _dio.post<dynamic>(
        ApiEndpoints.logout,
        data: {'refreshToken': refreshToken},
      );
    } catch (_) {
      // Best effort — local tokens are cleared regardless.
    }
  }

  /// Convenience for the repository: turns a verify response into the
  /// session the rest of the app already stores.
  static AuthSession sessionFromVerify(OtpVerifyResponse response) {
    return AuthSession(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken.isEmpty
          ? null
          : response.refreshToken,
      user: UserModel(
        id: response.userId,
        name: response.userName,
        email: response.userEmail,
        phone: response.userPhone,
        city: response.userCity,
      ),
    );
  }
}
