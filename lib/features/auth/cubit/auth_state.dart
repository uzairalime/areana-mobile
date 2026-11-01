import 'package:equatable/equatable.dart';

import '../../../core/enums/app_loading.dart';

/// Auth steps, mirroring user-web `/auth` exactly:
/// email → code → signup (only for new accounts) → done (welcome promo /
/// referral notice, otherwise the Cubit reports success and the screen
/// navigates straight home).
enum AuthStep { email, code, signup, done }

class AuthState extends Equatable {
  const AuthState({
    this.status = AppLoading.initial,
    this.errorMessage = '',
    this.noticeMessage = '',
    this.loaderTitle = '',
    this.errorTitle = '',
    this.step = AuthStep.email,
    this.otpResendSeconds = 0,
    this.failedAttempts = 0,
    this.otpExpiresAtMs,
    this.welcomePromoCode,
    this.referralNotice,
  });

  final AppLoading status;
  final String errorMessage;

  /// Non-error info banner (for example "Code sent — valid for
  /// 10 minutes."). Kept separate from errorMessage so a notice never
  /// renders as an error dialog.
  final String noticeMessage;
  final String loaderTitle;
  final String errorTitle;
  final AuthStep step;

  /// Countdown before Resend is enabled. `0` means resend is available.
  final int otpResendSeconds;

  /// Local failed-verify count for this code. The server caps at 5
  /// attempts per code; at 5 the code is blocked and only a resend
  /// helps. Suspended-account and timeout failures are never counted.
  final int failedAttempts;

  /// Absolute code expiry (epoch ms), from the server's `expiresAt` /
  /// `ttlSeconds` when present, else the local 10-minute fallback.
  /// Null on the email step (no live code yet).
  final int? otpExpiresAtMs;

  final String? welcomePromoCode;
  final String? referralNotice;

  bool get canResendOtp => otpResendSeconds <= 0;
  bool get codeLocked => failedAttempts >= 5;

  bool get codeExpired {
    final expiry = otpExpiresAtMs;
    if (expiry == null) {
      return false;
    }
    return DateTime.now().millisecondsSinceEpoch >= expiry;
  }

  AuthState copyWith({
    AppLoading? status,
    String? errorMessage,
    String? noticeMessage,
    String? loaderTitle,
    String? errorTitle,
    AuthStep? step,
    int? otpResendSeconds,
    int? failedAttempts,
    int? otpExpiresAtMs,
    bool clearOtpExpiry = false,
    String? welcomePromoCode,
    String? referralNotice,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      noticeMessage: noticeMessage ?? this.noticeMessage,
      loaderTitle: loaderTitle ?? this.loaderTitle,
      errorTitle: errorTitle ?? this.errorTitle,
      step: step ?? this.step,
      otpResendSeconds: otpResendSeconds ?? this.otpResendSeconds,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      otpExpiresAtMs: clearOtpExpiry
          ? null
          : (otpExpiresAtMs ?? this.otpExpiresAtMs),
      welcomePromoCode: welcomePromoCode ?? this.welcomePromoCode,
      referralNotice: referralNotice ?? this.referralNotice,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    noticeMessage,
    loaderTitle,
    errorTitle,
    step,
    otpResendSeconds,
    failedAttempts,
    otpExpiresAtMs,
    welcomePromoCode,
    referralNotice,
  ];
}
