import 'package:dio/dio.dart';

import '../../../core/consts/api_endpoints.dart';
import '../../../core/services/api_result.dart';
import '../model/auth_session.dart';
import '../model/social_credential.dart';

class AuthClient {
  const AuthClient(this._dio);

  final Dio _dio;

  Future<ApiResult<AuthSession>> login({
    required String identifier,
    required String password,
  }) {
    return _postSession(ApiEndpoints.login, {
      'identifier': identifier,
      'password': password,
    });
  }

  Future<ApiResult<void>> signup({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) {
    return _postEmpty(ApiEndpoints.signup, {
      'name': name,
      'phone': phone,
      'email': email,
      'password': password,
    });
  }

  Future<ApiResult<AuthSession>> verifySignupOtp({
    required String email,
    required String otp,
  }) {
    return _postSession(ApiEndpoints.signupVerifyOtp, {
      'email': email,
      'otp': otp,
    });
  }

  Future<ApiResult<AuthSession>> social(SocialCredential credential) {
    return _postSession(ApiEndpoints.social, credential.toJson());
  }

  Future<ApiResult<void>> sendForgotOtp({required String email}) {
    return _postEmpty(ApiEndpoints.forgotSendOtp, {'email': email});
  }

  Future<ApiResult<void>> verifyForgotOtp({
    required String email,
    required String otp,
  }) {
    return _postEmpty(ApiEndpoints.forgotVerifyOtp, {
      'email': email,
      'otp': otp,
    });
  }

  Future<ApiResult<AuthSession>> resetPassword({
    required String email,
    required String otp,
    required String password,
  }) {
    return _postSession(ApiEndpoints.forgotReset, {
      'email': email,
      'otp': otp,
      'password': password,
    });
  }

  Future<ApiResult<AuthSession>> _postSession(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.post<dynamic>(path, data: body);
      final data = response.data;
      if (data is! Map) {
        return const ApiError(message: 'Unexpected response');
      }
      return ApiSuccess(
        AuthSession.fromJson(Map<String, dynamic>.from(data)),
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<void>> _postEmpty(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.post<dynamic>(path, data: body);
      return ApiSuccess(null, statusCode: response.statusCode);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }
}
