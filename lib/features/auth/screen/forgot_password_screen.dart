import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/utils/auth_navigation.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_form_listener.dart';
import '../../../core/widgets/app_text_field.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_step_header.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/otp_verify_panel.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final cubit = context.read<AuthCubit>();
          return AppFormListener(
            status: state.status,
            errorMessage: state.errorMessage,
            loadingTitle: state.loaderTitle.isEmpty
                ? 'Please wait'
                : state.loaderTitle,
            errorTitle: state.errorTitle.isEmpty
                ? 'Reset password failed'
                : state.errorTitle,
            onSuccess: () => AuthNavigation.afterAuthSuccess(context),
            onErrorDismissed: cubit.clearError,
            child: Column(
              children: [
                AuthTopBar(
                  onBack: () {
                    if (state.flowStep > 0) {
                      cubit.backStep();
                    } else {
                      context.pop();
                    }
                  },
                ),
                IndexedStack(
                  index: state.flowStep.clamp(0, 2),
                  sizing: .expand,
                  children: [
                    _EmailStep(cubit: cubit),
                    _OtpStep(cubit: cubit, email: cubit.emailController.text),
                    _PasswordStep(cubit: cubit, state: state),
                  ],
                ).expand(),
              ],
            ),
          );
        },
      ).safeArea(),
    ).annotatedRegion(.dark);
  }
}

class _EmailStep extends StatelessWidget {
  const _EmailStep({required this.cubit});

  final AuthCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: cubit.formKey,
      child: ListView(
        padding: const .fromLTRB(24, 12, 24, 28),
        children: [
          const AuthStepHeader(
            step: 1,
            total: 3,
            title: 'Forgot your password?',
            subtitle:
                'Enter the email linked to your account. We will send a one-time code.',
          ),
          AppSizes.spaceLg.h,
          AppTextField(
            label: 'Email',
            controller: cubit.emailController,
            icon: Icons.mail_outline,
            hint: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => cubit.clearError(),
            validator: AppValidators.email,
          ),
          AppSizes.spaceLg.h,
          AppButton(
            label: 'Send code',
            showArrow: false,
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              cubit.sendForgotOtp();
            },
          ),
          AppSizes.spaceLg.h,
          Row(
            mainAxisAlignment: .center,
            children: [
              Text(
                'Remembered it?',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textBody,
                  fontWeight: .w500,
                ),
              ),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Back to log in'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OtpStep extends StatelessWidget {
  const _OtpStep({required this.cubit, required this.email});

  final AuthCubit cubit;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AuthStepHeader(
          step: 2,
          total: 3,
          title: 'Check your inbox',
          subtitle: 'Enter the 6-digit code we sent to your email.',
        ).paddingSymmetric(horizontal: 24),
        OtpVerifyPanel(
          email: email,
          onVerify: cubit.verifyForgotOtp,
          onResend: () => cubit.resendOtp(forSignup: false),
        ).expand(),
      ],
    );
  }
}

class _PasswordStep extends StatelessWidget {
  const _PasswordStep({required this.cubit, required this.state});

  final AuthCubit cubit;
  final AuthState state;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: cubit.passwordFormKey,
      child: ListView(
        padding: const .fromLTRB(24, 12, 24, 28),
        children: [
          const AuthStepHeader(
            step: 3,
            total: 3,
            title: 'Set a new password',
            subtitle:
                'Choose a strong password. You will be signed in right after.',
          ),
          AppSizes.spaceLg.h,
          AppTextField(
            label: 'New password',
            controller: cubit.passwordController,
            icon: Icons.lock_outline,
            hint: 'At least 8 characters',
            obscureText: state.obscurePassword,
            onToggleObscure: cubit.togglePassword,
            onChanged: (_) => cubit.clearError(),
            validator: AppValidators.password,
          ),
          AppSizes.spaceMd.h,
          AppTextField(
            label: 'Confirm password',
            controller: cubit.confirmPasswordController,
            icon: Icons.lock_outline,
            hint: 'Re-enter password',
            obscureText: state.obscureConfirmPassword,
            onToggleObscure: cubit.toggleConfirmPassword,
            onChanged: (_) => cubit.clearError(),
            validator: (value) => AppValidators.confirmPassword(
              value,
              cubit.passwordController.text,
            ),
          ),
          AppSizes.spaceLg.h,
          AppButton(
            label: 'Save and continue',
            showArrow: false,
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              cubit.resetPassword();
            },
          ),
        ],
      ),
    );
  }
}
