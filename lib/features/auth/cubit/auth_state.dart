import 'package:equatable/equatable.dart';

import '../../../core/enums/app_loading.dart';

class AuthState extends Equatable {
  const AuthState({
    this.status = AppLoading.initial,
    this.errorMessage = '',
    this.loaderTitle = '',
    this.errorTitle = '',
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
    this.agreedToTerms = false,
    this.flowStep = 0,
    this.otpResendSeconds = 0,
  });

  final AppLoading status;
  final String errorMessage;
  final String loaderTitle;
  final String errorTitle;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final bool agreedToTerms;

  /// IndexedStack index: forgot 0 email / 1 otp / 2 password; signup 0 form / 1 otp.
  final int flowStep;

  /// Countdown before Resend is enabled. `0` means resend is available.
  final int otpResendSeconds;

  bool get canResendOtp => otpResendSeconds <= 0;

  AuthState copyWith({
    AppLoading? status,
    String? errorMessage,
    String? loaderTitle,
    String? errorTitle,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
    bool? agreedToTerms,
    int? flowStep,
    int? otpResendSeconds,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      loaderTitle: loaderTitle ?? this.loaderTitle,
      errorTitle: errorTitle ?? this.errorTitle,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword:
          obscureConfirmPassword ?? this.obscureConfirmPassword,
      agreedToTerms: agreedToTerms ?? this.agreedToTerms,
      flowStep: flowStep ?? this.flowStep,
      otpResendSeconds: otpResendSeconds ?? this.otpResendSeconds,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    loaderTitle,
    errorTitle,
    obscurePassword,
    obscureConfirmPassword,
    agreedToTerms,
    flowStep,
    otpResendSeconds,
  ];
}
