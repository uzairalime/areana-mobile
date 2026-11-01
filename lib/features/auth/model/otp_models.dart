import 'package:equatable/equatable.dart';

/// Referral outcome from `POST /auth/verify-otp`, same wording rules as
/// user-web: `none` shows no message, every other status has its own copy.
enum ReferralStatus { none, applied, self, invalid, failed, unknown }

ReferralStatus referralStatusFromJson(Object? value) {
  return switch (value) {
    'none' => ReferralStatus.none,
    'applied' => ReferralStatus.applied,
    'self' => ReferralStatus.self,
    'invalid' => ReferralStatus.invalid,
    'failed' => ReferralStatus.failed,
    _ => ReferralStatus.unknown,
  };
}

class OtpRequestResponse extends Equatable {
  const OtpRequestResponse({
    required this.message,
    this.expiresAt,
    this.ttlSeconds,
    this.retryAfterSeconds,
    this.resetsAt,
  });

  factory OtpRequestResponse.fromJson(Map<String, dynamic> json) {
    return OtpRequestResponse(
      message: json['message'] as String? ?? '',
      expiresAt: json['expiresAt'] as String?,
      ttlSeconds: (json['ttlSeconds'] as num?)?.toInt(),
      retryAfterSeconds: (json['retryAfterSeconds'] as num?)?.toInt(),
      resetsAt: json['resetsAt'] as String?,
    );
  }

  final String message;
  final String? expiresAt;
  final int? ttlSeconds;
  final int? retryAfterSeconds;
  final String? resetsAt;

  /// Absolute expiry in epoch milliseconds, from the server's
  /// `expiresAt` when present, else `sentAt + ttlSeconds`.
  int? expiryMs(int sentAtMs) {
    if (expiresAt != null) {
      final parsed = DateTime.tryParse(expiresAt!);
      if (parsed != null) {
        return parsed.millisecondsSinceEpoch;
      }
    }
    if (ttlSeconds != null && ttlSeconds! > 0) {
      return sentAtMs + ttlSeconds! * 1000;
    }
    return null;
  }

  @override
  List<Object?> get props => [
    message,
    expiresAt,
    ttlSeconds,
    retryAfterSeconds,
    resetsAt,
  ];
}

class OtpVerifyResponse extends Equatable {
  const OtpVerifyResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userPhone = '',
    this.userCity = '',
    this.welcomePromoCode,
    this.referralStatus = ReferralStatus.unknown,
    this.expiresAt,
    this.ttlSeconds,
  });

  factory OtpVerifyResponse.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final userMap = user is Map ? Map<String, dynamic>.from(user) : null;
    return OtpVerifyResponse(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      userId: userMap?['id']?.toString() ?? '',
      userName: userMap?['name'] as String? ?? '',
      userEmail: userMap?['email'] as String? ?? '',
      userPhone: userMap?['phone'] as String? ?? '',
      userCity: userMap?['city'] as String? ?? '',
      welcomePromoCode: json['welcomePromoCode'] as String?,
      referralStatus: referralStatusFromJson(json['referralStatus']),
      expiresAt: json['expiresAt'] as String?,
      ttlSeconds: (json['ttlSeconds'] as num?)?.toInt(),
    );
  }

  final String accessToken;
  final String refreshToken;
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String userCity;
  final String? welcomePromoCode;
  final ReferralStatus referralStatus;
  final String? expiresAt;
  final int? ttlSeconds;

  @override
  List<Object?> get props => [
    accessToken,
    refreshToken,
    userId,
    userName,
    userEmail,
    userPhone,
    userCity,
    welcomePromoCode,
    referralStatus,
    expiresAt,
    ttlSeconds,
  ];
}
