import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../cubit/auth_cubit.dart';

/// Profile details are saved with the verified session; no OTP is replayed.
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
          Text('Complete your profile', style: context.textTheme.headlineLarge),
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
          AppSizes.spaceLg.h,
          AppButton(
            label: 'Complete profile',
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
              cubit.switchAccount();
            },
            child: const Text('Sign in with a different account'),
          ).center(),
        ],
      ),
    );
  }
}
