import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_icons.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/locator.dart';
import '../../../core/utils/auth_navigation.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_form_listener.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../booking/cubit/booking_cubit.dart';
import '../../booking/cubit/booking_state.dart';
import '../../booking/widgets/booking_summary_card.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_step_header.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/otp_verify_panel.dart';
import '../widgets/social_auth_buttons.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final next = AuthNavigation.nextOf(context);
    final bookingState = next == 'checkout'
        ? getIt<BookingCubit>().state
        : null;
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
                ? 'Create account failed'
                : state.errorTitle,
            onSuccess: () => AuthNavigation.afterAuthSuccess(
              context,
              next: next,
            ),
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
                  index: state.flowStep.clamp(0, 1),
                  sizing: .expand,
                  children: [
                    _SignupForm(
                      cubit: cubit,
                      state: state,
                      next: next,
                      bookingState: bookingState,
                    ),
                    _SignupOtp(cubit: cubit),
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

class _SignupForm extends StatelessWidget {
  const _SignupForm({
    required this.cubit,
    required this.state,
    required this.next,
    required this.bookingState,
  });

  final AuthCubit cubit;
  final AuthState state;
  final String? next;
  final BookingState? bookingState;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: cubit.formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        children: [
          Text('Create your account', style: context.textTheme.headlineLarge),
          8.h,
          Text(
            next == 'checkout'
                ? 'One quick step and your slot is locked in.'
                : 'Join in a minute and start booking courts near you.',
            style: context.textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: .w500,
              height: 1.45,
            ),
          ),
          if (bookingState case final booking?
              when booking.selectedCourt != null) ...[
            AppSizes.spaceMd.h,
            BookingReminderCard(state: booking),
          ],
          AppSizes.spaceMd.h,
          AppTextField(
            label: 'Full name',
            controller: cubit.nameController,
            icon: Icons.person_outline,
            hint: 'Enter your name',
            onChanged: (_) => cubit.clearError(),
            validator: (value) => AppValidators.requiredField(
              value,
              message: 'Enter your name',
            ),
          ),
          AppSizes.spaceMd.h,
          AppTextField(
            label: 'Phone number',
            controller: cubit.phoneController,
            icon: Icons.phone_outlined,
            hint: '03XX XXXXXXX',
            keyboardType: TextInputType.phone,
            onChanged: (_) => cubit.clearError(),
            validator: AppValidators.phone,
          ),
          AppSizes.spaceMd.h,
          AppTextField(
            label: 'Email',
            controller: cubit.emailController,
            icon: Icons.mail_outline,
            hint: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => cubit.clearError(),
            validator: AppValidators.email,
          ),
          AppSizes.spaceMd.h,
          AppTextField(
            label: 'Password',
            controller: cubit.passwordController,
            icon: Icons.lock_outline,
            hint: 'At least 8 characters',
            obscureText: state.obscurePassword,
            onToggleObscure: cubit.togglePassword,
            onChanged: (_) => cubit.clearError(),
            validator: AppValidators.password,
          ),
          AppSizes.spaceMd.h,
          Row(
            crossAxisAlignment: .start,
            children: [
              _TermsBox(agreed: state.agreedToTerms).onTap(cubit.toggleTerms),
              4.w,
              Text.rich(
                TextSpan(
                  text: 'I agree to the ',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.textBody,
                    fontSize: 13,
                    height: 1.45,
                  ),
                  children: [
                    TextSpan(
                      text: 'Terms of Service',
                      style: context.textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: context.textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ).paddingOnly(top: 11).expand(),
            ],
          ),
          AppSizes.spaceMd.h,
          AppButton(
            label: 'Continue',
            showArrow: false,
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              cubit.signup();
            },
          ),
          AppSizes.spaceMd.h,
          const AuthOrDivider(),
          AppSizes.spaceMd.h,
          const SocialAuthButtons(),
          AppSizes.spaceMd.h,
          Row(
            mainAxisAlignment: .center,
            children: [
              Text(
                'Already have an account?',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textBody,
                  fontWeight: .w500,
                ),
              ),
              TextButton(
                onPressed: () => context.push(
                  next == null
                      ? AppRoutes.login
                      : '${AppRoutes.login}?next=$next',
                ),
                child: const Text('Log in'),
              ),
            ],
          ),
          if (next == 'checkout')
            AppButton.outlined(
              label: 'Back to booking',
              icon: AppIcons.back,
              onPressed: () => context.pop(),
            )
          else
            GuestContinueButton(
              onPressed: () => context.go(AppRoutes.home),
            ),
        ],
      ),
    );
  }
}

class _SignupOtp extends StatelessWidget {
  const _SignupOtp({required this.cubit});

  final AuthCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AuthStepHeader(
          step: 2,
          total: 2,
          title: 'Verify your email',
          subtitle: 'Enter the 6-digit code we sent to your email.',
        ).paddingSymmetric(horizontal: 24),
        OtpVerifyPanel(
          email: cubit.emailController.text.trim(),
          onVerify: cubit.verifySignupOtp,
          onResend: () => cubit.resendOtp(forSignup: true),
        ).expand(),
      ],
    );
  }
}

class _TermsBox extends StatelessWidget {
  const _TermsBox({required this.agreed});

  final bool agreed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: agreed ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: agreed ? AppColors.primary : AppColors.textDisabled,
            width: agreed ? 0 : 2,
          ),
        ),
        child: SizedBox(
          width: 24,
          height: 24,
          child: agreed
              ? const Icon(Icons.check, size: 16, color: AppColors.accent)
              : null,
        ),
      ).center(),
    );
  }
}
