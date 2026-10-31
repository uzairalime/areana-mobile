import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/app_loading.dart';
import '../../../core/services/api_result.dart';
import '../model/social_provider.dart';
import 'auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState());

  final AuthRepository _repository;
  final formKey = GlobalKey<FormState>();
  final otpFormKey = GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormState>();
  final identifierController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final otpController = TextEditingController();

  Timer? _otpTimer;
  static const _otpCooldown = Duration(seconds: 60);

  void togglePassword() {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  void toggleConfirmPassword() {
    emit(
      state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword),
    );
  }

  void toggleTerms() {
    final agreed = !state.agreedToTerms;
    final clearTermsError =
        agreed && state.errorMessage.startsWith('Agree to the Terms');
    emit(
      state.copyWith(
        agreedToTerms: agreed,
        status: clearTermsError ? AppLoading.initial : null,
        errorMessage: clearTermsError ? '' : null,
      ),
    );
  }

  void clearError() {
    if (state.errorMessage.isEmpty && !state.status.isError) {
      return;
    }
    emit(state.copyWith(status: AppLoading.initial, errorMessage: ''));
  }

  void backStep() {
    if (state.flowStep <= 0) {
      return;
    }
    _stopOtpTimer();
    otpController.clear();
    emit(
      state.copyWith(
        flowStep: state.flowStep - 1,
        status: AppLoading.initial,
        errorMessage: '',
        otpResendSeconds: 0,
      ),
    );
  }

  Future<void> login() {
    if (!_validate(formKey)) {
      return Future.value();
    }
    return _submitSession(
      loaderTitle: 'Log in',
      errorTitle: 'Log in failed',
      request: () => _repository.login(
        identifier: identifierController.text.trim(),
        password: passwordController.text,
      ),
    );
  }

  Future<void> signup() {
    final fieldsValid = _validate(formKey);
    if (!state.agreedToTerms) {
      emit(
        state.copyWith(
          status: AppLoading.error,
          errorMessage: 'Agree to the Terms of Service and Privacy Policy',
          errorTitle: 'Create account failed',
        ),
      );
      return Future.value();
    }
    if (!fieldsValid) {
      return Future.value();
    }
    return _submitStep(
      loaderTitle: 'Sending code',
      errorTitle: 'Create account failed',
      request: () => _repository.signup(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      ),
      nextStep: 1,
      startOtpTimer: true,
    );
  }

  Future<void> verifySignupOtp() {
    if (!_validate(otpFormKey)) {
      return Future.value();
    }
    return _submitSession(
      loaderTitle: 'Verifying',
      errorTitle: 'Verification failed',
      request: () => _repository.verifySignupOtp(
        email: emailController.text.trim(),
        otp: otpController.text.trim(),
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
      ),
    );
  }

  Future<void> signInWithGoogle() => _submitSession(
    loaderTitle: 'Continue with Google',
    errorTitle: 'Google sign in failed',
    request: () => _repository.socialSignIn(SocialProvider.google),
  );

  Future<void> signInWithApple() => _submitSession(
    loaderTitle: 'Continue with Apple',
    errorTitle: 'Apple sign in failed',
    request: () => _repository.socialSignIn(SocialProvider.apple),
  );

  Future<void> sendForgotOtp() {
    if (!_validate(formKey)) {
      return Future.value();
    }
    return _submitStep(
      loaderTitle: 'Sending code',
      errorTitle: 'Could not send code',
      request: () =>
          _repository.sendForgotOtp(email: emailController.text.trim()),
      nextStep: 1,
      startOtpTimer: true,
    );
  }

  Future<void> verifyForgotOtp() {
    if (!_validate(otpFormKey)) {
      return Future.value();
    }
    return _submitStep(
      loaderTitle: 'Verifying',
      errorTitle: 'Verification failed',
      request: () => _repository.verifyForgotOtp(
        email: emailController.text.trim(),
        otp: otpController.text.trim(),
      ),
      nextStep: 2,
    );
  }

  Future<void> resetPassword() {
    if (!_validate(passwordFormKey)) {
      return Future.value();
    }
    return _submitSession(
      loaderTitle: 'Updating password',
      errorTitle: 'Reset password failed',
      request: () => _repository.resetPassword(
        email: emailController.text.trim(),
        otp: otpController.text.trim(),
        password: passwordController.text,
      ),
    );
  }

  Future<void> resendOtp({required bool forSignup}) {
    if (!state.canResendOtp) {
      return Future.value();
    }
    if (forSignup) {
      return _submitStep(
        loaderTitle: 'Resending code',
        errorTitle: 'Could not resend code',
        request: () => _repository.signup(
          name: nameController.text.trim(),
          phone: phoneController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text,
        ),
        nextStep: state.flowStep,
        startOtpTimer: true,
      );
    }
    return _submitStep(
      loaderTitle: 'Resending code',
      errorTitle: 'Could not resend code',
      request: () =>
          _repository.sendForgotOtp(email: emailController.text.trim()),
      nextStep: state.flowStep,
      startOtpTimer: true,
    );
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

  Future<void> _submitStep({
    required Future<ApiResult<Object?>> Function() request,
    required int nextStep,
    required String loaderTitle,
    required String errorTitle,
    bool startOtpTimer = false,
  }) async {
    emit(
      state.copyWith(
        status: AppLoading.loading,
        errorMessage: '',
        loaderTitle: loaderTitle,
        errorTitle: errorTitle,
      ),
    );
    final result = await request();
    if (isClosed) {
      return;
    }
    result.when(
      success: (_) {
        emit(
          state.copyWith(
            status: AppLoading.initial,
            errorMessage: '',
            flowStep: nextStep,
          ),
        );
        if (startOtpTimer) {
          _startOtpTimer();
        }
      },
      failure: (error) {
        emit(
          state.copyWith(
            status: AppLoading.error,
            errorMessage: error.message,
            errorTitle: errorTitle,
          ),
        );
      },
    );
  }

  Future<void> _submitSession({
    required Future<ApiResult<Object?>> Function() request,
    required String loaderTitle,
    required String errorTitle,
  }) async {
    emit(
      state.copyWith(
        status: AppLoading.loading,
        errorMessage: '',
        loaderTitle: loaderTitle,
        errorTitle: errorTitle,
      ),
    );
    final result = await request();
    if (isClosed) {
      return;
    }
    result.when(
      success: (_) {
        _stopOtpTimer();
        emit(state.copyWith(status: AppLoading.success, errorMessage: ''));
      },
      failure: (error) {
        emit(
          state.copyWith(
            status: AppLoading.error,
            errorMessage: error.message,
            errorTitle: errorTitle,
          ),
        );
      },
    );
  }

  @override
  Future<void> close() {
    _stopOtpTimer();
    identifierController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    otpController.dispose();
    return super.close();
  }
}
