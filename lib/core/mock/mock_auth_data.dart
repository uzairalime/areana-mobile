import '../../features/auth/model/otp_models.dart';

class MockAuthData {
  const MockAuthData._();

  /// Mock OTP accepted by verify endpoints.
  static const String validOtp = '123456';

  static bool isValidOtp(String otp) => otp.trim() == validOtp;

  /// New mock accounts authenticate first, then complete their profile.
  static OtpVerifyResponse verifyOtp({
    required String email,
    String? name,
    String? phone,
    String? city,
    String? referralCode,
  }) {
    final isReturning = email == 'alex@pitchside.app';
    return OtpVerifyResponse(
      isProfileCompleted: isReturning ||
          ((name?.trim().isNotEmpty ?? false) && (phone?.trim().isNotEmpty ?? false)),
      accessToken: 'mock_access_token',
      refreshToken: 'mock_refresh_token',
      userId: 'user_1',
      userName: isReturning ? 'Alex Player' : (name ?? ''),
      userEmail: email,
      userPhone: isReturning ? '03001234567' : (phone ?? ''),
      userCity: city ?? '',
      referralStatus: referralCode != null && referralCode.isNotEmpty
          ? ReferralStatus.applied
          : ReferralStatus.none,
    );
  }
}
