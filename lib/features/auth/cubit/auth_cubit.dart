import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/app_loading.dart';
import '../../../core/services/api_result.dart';
import '../model/otp_models.dart';
import 'auth_repository.dart';
import 'auth_state.dart';

/// Email OTP authenticates the player; profile completion uses that session.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState()) {
    final user = _repository.currentUser;
    if (user != null && !user.isProfileCompleted) {
      emailController.text = user.email;
      nameController.text = user.name;
      phoneController.text = user.phone;
      cityController.text = user.city;
      emit(state.copyWith(step: AuthStep.signup));
    }
  }

  final AuthRepository _repository;

  final emailFormKey = GlobalKey<FormState>();
  final otpFormKey = GlobalKey<FormState>();
  final signupFormKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();
  final referralController = TextEditingController();

  Timer? _otpTimer;
  static const _otpCooldown = Duration(seconds: 60);
  static const _fallbackTtlSeconds = 600;

  void clearError() {
    if (state.errorMessage.isEmpty && !state.status.isError) {
      return;
    }
    emit(state.copyWith(status: AppLoading.initial, errorMessage: ''));
  }

  void clearNotice() {
    if (state.noticeMessage.isEmpty) {
      return;
    }
    emit(state.copyWith(noticeMessage: ''));
  }

  void backStep() {
    switch (state.step) {
      case AuthStep.code:
        _stopOtpTimer();
        otpController.clear();
        emit(
          state.copyWith(
            step: AuthStep.email,
            status: AppLoading.initial,
            errorMessage: '',
            noticeMessage: '',
            otpResendSeconds: 0,
            failedAttempts: 0,
            clearOtpExpiry: true,
          ),
        );
      case AuthStep.signup:
        // The code is already consumed; switching accounts starts a new login.
        unawaited(switchAccount());
      case AuthStep.email:
      case AuthStep.done:
        break;
    }
  }

  Future<void> switchAccount() async {
    _stopOtpTimer();
    await _repository.logout();
    if (isClosed) {
      return;
    }
    emailController.clear();
    otpController.clear();
    nameController.clear();
    phoneController.clear();
    cityController.clear();
    referralController.clear();
    emit(const AuthState());
  }

  Future<void> requestOtp() async {
    if (state.status.isLoading || !_validate(emailFormKey)) {
      return;
    }
    final email = emailController.text.trim().toLowerCase();
    emailController.text = email;
    await _requestOtp(email: email, isResend: false);
  }

  Future<void> resendOtp() async {
    if (state.status.isLoading || !state.canResendOtp) {
      return;
    }
    await _requestOtp(
      email: emailController.text.trim().toLowerCase(),
      isResend: true,
    );
  }

  Future<void> _requestOtp({
    required String email,
    required bool isResend,
  }) async {
    emit(
      state.copyWith(
        status: AppLoading.loading,
        errorMessage: '',
        noticeMessage: '',
        loaderTitle: isResend ? 'Resending code' : 'Sending code',
        errorTitle: 'Could not send code',
      ),
    );
    final result = await _repository.requestOtp(email: email);
    if (isClosed) {
      return;
    }
    result.when(
      success: (response) {
        final sentAt = DateTime.now().millisecondsSinceEpoch;
        final expiry =
            response.expiryMs(sentAt) ?? sentAt + _fallbackTtlSeconds * 1000;
        final ttl = response.ttlSeconds ?? _fallbackTtlSeconds;
        final minutes = (ttl / 60).round().clamp(1, 60);
        if (isResend) {
          otpController.clear();
        }
        emit(
          state.copyWith(
            status: AppLoading.initial,
            errorMessage: '',
            noticeMessage: isResend
                ? 'A fresh code is on its way — valid for $minutes minutes.'
                : 'Code sent — valid for $minutes minutes.',
            step: AuthStep.code,
            failedAttempts: 0,
            otpExpiresAtMs: expiry,
          ),
        );
        _startOtpTimer();
      },
      failure: (error) {
        emit(
          state.copyWith(
            status: AppLoading.error,
            errorMessage: _friendlyRequestError(error),
            errorTitle: 'Could not send code',
          ),
        );
      },
    );
  }

  Future<void> verifyCode() async {
    if (state.status.isLoading || _blockedByExpiryOrLock()) {
      return;
    }
    if (!_validate(otpFormKey)) {
      return;
    }
    final email = emailController.text.trim().toLowerCase();
    final code = otpController.text.trim();
    emit(
      state.copyWith(
        status: AppLoading.loading,
        errorMessage: '',
        noticeMessage: '',
        loaderTitle: 'Verifying',
        errorTitle: 'Verification failed',
      ),
    );
    final result = await _repository.verifyOtp(email: email, code: code);
    if (isClosed) {
      return;
    }
    await result.when<Future<void>>(
      success: (response) => _finishLogin(response, referralEntered: false),
      failure: (error) async => _noteVerifyFailure(error),
    );
  }

  Future<void> verifySignup() async {
    if (state.status.isLoading || !_validate(signupFormKey)) return;
    final cleanName = nameController.text
        .replaceAll(RegExp(r'[\r\n]+'), ' ')
        .trim();
    final cleanPhone = phoneController.text.trim();
    final city = cityController.text.trim();
    final referral = referralController.text.trim().toUpperCase();
    emit(state.copyWith(
      status: AppLoading.loading,
      errorMessage: '',
      noticeMessage: '',
      loaderTitle: 'Completing profile',
      errorTitle: 'Could not complete profile',
    ));
    final result = await _repository.completeProfile(
      name: cleanName,
      phone: cleanPhone,
      city: city.isEmpty ? null : city,
      referralCode: referral.isEmpty ? null : referral,
    );
    if (isClosed) return;
    result.when(
      success: (response) => _finishProfile(
        welcomePromoCode: response.welcomePromoCode,
        referralStatus: response.referralStatus,
        referralEntered: referral.isNotEmpty,
      ),
      failure: (error) => emit(state.copyWith(
        status: AppLoading.error,
        errorMessage: error.message.isEmpty
            ? 'Could not complete your profile. Please try again.'
            : error.message,
        errorTitle: 'Could not complete profile',
      )),
    );
  }

  Future<void> _finishLogin(
    OtpVerifyResponse response, {
    required bool referralEntered,
  }) async {
    final persisted = await _repository.persistVerify(response);
    if (isClosed) {
      return;
    }
    final error = persisted.errorOrNull;
    if (error != null) {
      emit(
        state.copyWith(
          status: AppLoading.error,
          errorMessage: error.message,
          errorTitle: 'Could not sign in',
        ),
      );
      return;
    }
    _stopOtpTimer();
    otpController.clear();
    if (!response.isProfileCompleted) {
      nameController.text = response.userName;
      phoneController.text = response.userPhone;
      cityController.text = response.userCity;
      emit(state.copyWith(
        status: AppLoading.initial,
        step: AuthStep.signup,
        noticeMessage: 'Email verified. Complete your profile below.',
        errorMessage: '',
        failedAttempts: 0,
        otpResendSeconds: 0,
        clearOtpExpiry: true,
      ));
      return;
    }
    _finishProfile(
      welcomePromoCode: response.welcomePromoCode,
      referralStatus: response.referralStatus,
      referralEntered: referralEntered,
    );
  }

  void _finishProfile({
    required String? welcomePromoCode,
    required ReferralStatus referralStatus,
    required bool referralEntered,
  }) {
    if (welcomePromoCode != null && welcomePromoCode.isNotEmpty) {
      emit(state.copyWith(
        status: AppLoading.initial,
        errorMessage: '',
        noticeMessage: '',
        step: AuthStep.done,
        welcomePromoCode: welcomePromoCode,
        clearOtpExpiry: true,
      ));
      return;
    }
    if (referralEntered) {
      final notice = _referralNoticeFor(referralStatus);
      if (notice.isNotEmpty) {
        emit(state.copyWith(
          status: AppLoading.initial,
          errorMessage: '',
          noticeMessage: '',
          step: AuthStep.done,
          referralNotice: notice,
          clearOtpExpiry: true,
        ));
        return;
      }
    }
    emit(state.copyWith(
      status: AppLoading.success,
      errorMessage: '',
      clearOtpExpiry: true,
    ));
  }

  bool _blockedByExpiryOrLock() {
    if (state.codeExpired) {
      emit(
        state.copyWith(
          status: AppLoading.error,
          errorMessage: 'This code has expired — send a new one below.',
          errorTitle: 'Verification failed',
        ),
      );
      return true;
    }
    if (state.codeLocked) {
      emit(
        state.copyWith(
          status: AppLoading.error,
          errorMessage: 'This code is blocked after too many wrong tries — tap Resend for a fresh code.',
          errorTitle: 'Verification failed',
        ),
      );
      return true;
    }
    return false;
  }

  void _noteVerifyFailure(ApiError<OtpVerifyResponse> error) {
    final message = error.message;
    final lower = message.toLowerCase();
    // A suspended account is not a wrong guess — never count it.
    if (lower.contains('not active') || lower.contains('suspend')) {
      emit(
        state.copyWith(
          status: AppLoading.error,
          errorMessage: 'This account has been suspended. Please contact support for help.',
          errorTitle: 'Verification failed',
        ),
      );
      return;
    }
    // A verify timeout may have consumed an attempt, but it is not
    // proven — never claim the code still works, and never count it
    // locally. The server is the authority.
    if (error.statusCode == 503) {
      emit(
        state.copyWith(
          status: AppLoading.error,
          errorMessage: 'The service timed out — that try may have used up one of your attempts. Please try verifying again, or tap Resend for a fresh code if you\'re unsure.',
          errorTitle: 'Verification failed',
        ),
      );
      return;
    }
    // Server-blocked: waiting never unblocks a blocked code.
    if (lower.contains('too many') || lower.contains('attempt')) {
      emit(
        state.copyWith(
          status: AppLoading.error,
          errorMessage: 'This code is blocked — tap Resend for a fresh code.',
          errorTitle: 'Verification failed',
          failedAttempts: 5,
        ),
      );
      return;
    }
    final nextCount = state.failedAttempts + 1;
    const base =
        'Wrong or expired code. Please check the 6-digit code and try again.';
    emit(
      state.copyWith(
        status: AppLoading.error,
        errorMessage: nextCount >= 5
            ? 'This code is blocked after too many wrong tries — tap Resend for a fresh code.'
            : nextCount >= 3
            ? '$base After a few wrong tries a code gets blocked — if this keeps failing, tap Resend for a fresh code.'
            : base,
        errorTitle: 'Verification failed',
        failedAttempts: nextCount,
      ),
    );
  }

  String _friendlyRequestError(ApiError<OtpRequestResponse> error) {
    if (error.statusCode == 503) {
      final hasLiveCode =
          state.otpExpiresAtMs != null &&
          DateTime.now().millisecondsSinceEpoch < state.otpExpiresAtMs!;
      return hasLiveCode
          ? 'The email service timed out and no new code was sent — your previous code still works, or tap Resend for a fresh code.'
          : 'The email service timed out and no code was sent — please tap Send again.';
    }
    if (error.statusCode == 429 || _isRateLimit(error.message)) {
      final data = error.data;
      final retryAfter = (data?['retryAfterSeconds'] as num?)?.toInt();
      final resetsAtRaw = data?['resetsAt'] as String?;
      final resetsAt = resetsAtRaw == null
          ? null
          : DateTime.tryParse(resetsAtRaw)?.millisecondsSinceEpoch;
      final unlockAt =
          resetsAt ??
          (retryAfter != null
              ? DateTime.now().millisecondsSinceEpoch + retryAfter * 1000
              : null);
      if (unlockAt != null) {
        final codesLimit = error.message.toLowerCase().contains(
          'codes requested',
        );
        return codesLimit
            ? 'Too many codes sent — the limit is 5 codes per hour. You can request a new code after ${_fmtClock(unlockAt)}.'
            : 'Too many requests — please try again after ${_fmtClock(unlockAt)}.';
      }
      if (error.message.toLowerCase().contains('codes requested')) {
        return 'Too many codes sent — the limit is 5 codes per hour. If you haven\'t sent 5 codes, this may be a shared-network limit — please wait a bit and try again.';
      }
      return 'Too many requests — please wait a minute and try again.';
    }
    return error.message.isEmpty
        ? 'Couldn\'t send the code. Please try again.'
        : error.message;
  }

  bool _isRateLimit(String message) {
    final lower = message.toLowerCase();
    return lower.contains('too many') || lower.contains('rate');
  }

  String _referralNoticeFor(ReferralStatus status) {
    return switch (status) {
      ReferralStatus.applied => 'Referral promo applied.',
      ReferralStatus.self => 'You cannot use your own referral code — account created without a welcome promo.',
      ReferralStatus.invalid => 'Referral code not recognised — account created without a welcome promo.',
      ReferralStatus.failed => 'Referral promo could not be applied — try again later. Your account was created without a welcome promo.',
      ReferralStatus.none => '',
      ReferralStatus.unknown => 'Referral code not recognised — account created without a welcome promo.',
    };
  }

  bool _validate(GlobalKey<FormState> key) {
    final isValid = key.currentState?.validate() ?? false;
    if (!isValid && state.errorMessage.isNotEmpty) {
      emit(state.copyWith(status: AppLoading.initial, errorMessage: ''));
    }
    return isValid;
  }

  void _startOtpTimer() {
    _stopOtpTimer();
    emit(state.copyWith(otpResendSeconds: _otpCooldown.inSeconds));
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isClosed) {
        timer.cancel();
        return;
      }
      final next = state.otpResendSeconds - 1;
      if (next <= 0) {
        timer.cancel();
        emit(state.copyWith(otpResendSeconds: 0));
        return;
      }
      emit(state.copyWith(otpResendSeconds: next));
    });
  }

  void _stopOtpTimer() {
    _otpTimer?.cancel();
    _otpTimer = null;
  }

  String _fmtClock(int epochMs) {
    final date = DateTime.fromMillisecondsSinceEpoch(epochMs);
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Future<void> close() {
    _stopOtpTimer();
    emailController.dispose();
    otpController.dispose();
    nameController.dispose();
    phoneController.dispose();
    cityController.dispose();
    referralController.dispose();
    return super.close();
  }
}
