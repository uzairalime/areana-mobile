import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_otp_field.dart';
import '../cubit/auth_cubit.dart';

/// Step 3 of user-web `/auth`, shown only when verify reports a missing
/// account. The code from step 2 is kept (and shown read-only here for
/// context) — it is NOT cleared, because the server does not consume
/// it on the missing-account error, so the same code verifies again
/// with these fields attached.
class AuthSignupStep extends StatelessWidget {
  const AuthSignupStep({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    return Form(
      key: cubit.signupFormKey,
      child: ListView(
        padding: const .fromLTRB(24, 12, 24, 24),
        children: [
          Text(
            'Create your account',
            style: context.textTheme.headlineLarge,
          ),
          8.h,
          Text(
            "Just a few details and you're in.",
            style: context.textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: .w500,
              height: 1.45,
            ),
          ),
          AppSizes.spaceMd.h,
          AppTextField(
            label: 'Full name',
            controller: cubit.nameController,
            icon: Icons.person_outline,
            hint: 'Your name',
            onChanged: (_) => cubit.clearError(),
            validator: (value) => AppValidators.requiredField(
              value,
              message: 'Please tell us your name.',
            ),
          ),
          AppSizes.spaceMd.h,
          AppTextField(
            label: 'Phone number',
            controller: cubit.phoneController,
            icon: Icons.phone_outlined,
            hint: '03xx xxxxxxx',
            keyboardType: .phone,
            onChanged: (_) => cubit.clearError(),
            // Web rule: at least 7 digits. AppValidators.phone needs
            // 10+, which would reject numbers the web accepts.
            validator: (value) {
              final requiredError = AppValidators.requiredField(
                value,
                message: 'Enter your phone number',
              );
              if (requiredError != null) {
                return requiredError;
              }
              final digits = value!.replaceAll(RegExp(r'\D'), '');
              if (digits.length < 7) {
                return 'Please enter a valid phone number.';
              }
              return null;
            },
          ),
          AppSizes.spaceMd.h,
          AppTextField(
            label: 'City (optional)',
            controller: cubit.cityController,
            icon: Icons.location_city_outlined,
            hint: 'Lahore',
            onChanged: (_) => cubit.clearError(),
          ),
          AppSizes.spaceMd.h,
          AppTextField(
            label: 'Referral code (optional)',
            controller: cubit.referralController,
            icon: Icons.card_giftcard_outlined,
            hint: 'Friend\'s referral code',
            onChanged: (_) => cubit.clearError(),
          ),
          AppSizes.spaceMd.h,
          Text(
            'Your login code',
            style: context.textTheme.labelMedium?.copyWith(
              color: AppColors.textBody,
              fontWeight: .w700,
            ),
          ),
          6.h,
          AppOtpField(
            controller: cubit.otpController,
            onChanged: (_) => cubit.clearError(),
            validator: AppValidators.otp,
          ),
          AppSizes.spaceLg.h,
          AppButton(
            label: 'Create account',
            showArrow: false,
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              cubit.verifySignup();
            },
          ),
          AppSizes.spaceMd.h,
          TextButton(
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              cubit.backStep();
            },
            child: const Text('Back to code'),
          ).center(),
        ],
      ),
    );
  }
}
