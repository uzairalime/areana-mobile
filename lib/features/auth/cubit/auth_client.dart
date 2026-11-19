import 'package:dio/dio.dart';

import '../../../core/consts/api_endpoints.dart';
import '../../../core/services/api_result.dart';
import '../model/auth_session.dart';
import '../model/otp_models.dart';
import '../model/user_model.dart';

/// Passwordless authentication followed by authenticated profile completion.
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
          'name': ?name,
          'phone': ?phone,
          'city': ?city,
          'referralCode': ?referralCode,
        },
      );
      final data = response.data;
      if (data is! Map || data['success'] == false) {
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

  Future<ApiResult<OtpVerifyResponse>> socialLogin({
    required String provider,
    required String idToken,
    String? name,
    String? referralCode,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiEndpoints.social,
        data: {
          'provider': provider,
          'idToken': idToken,
          'name': ?name,
          'referralCode': ?referralCode,
        },
      );
      final data = response.data;
      if (data is! Map || data['success'] == false) {
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

  Future<ApiResult<ProfileCompletionResponse>> completeProfile({
    required String name,
    required String phone,
    String? city,
    String? referralCode,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiEndpoints.completeProfile,
        data: {
          'name': name,
          'phone': phone,
          'city': ?city,
          'referralCode': ?referralCode,
        },
      );
      final data = response.data;
      if (data is! Map || data['success'] == false) {
        return const ApiError(message: 'Could not complete your profile.');
      }
      final completion = ProfileCompletionResponse.fromJson(
        Map<String, dynamic>.from(data),
      );
      if (completion.user.id.isEmpty || !completion.user.isProfileCompleted) {
        return const ApiError(message: 'The server did not return a complete profile.');
      }
      return ApiSuccess(completion, statusCode: response.statusCode);
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
        avatarUrl: response.userProfileImage,
        provider: response.userProvider,
        isProfileCompleted: response.isProfileCompleted,
      ),
    );
  }
}
