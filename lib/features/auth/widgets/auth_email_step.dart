import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../cubit/auth_cubit.dart';
import 'auth_widgets.dart';

/// Step 1 of user-web `/auth`: email only. A new account is created
/// automatically on first verify — there is no separate signup form
/// before the code step, and no password anywhere.
class AuthEmailStep extends StatelessWidget {
  const AuthEmailStep({super.key, required this.onGuestContinue});

  final VoidCallback onGuestContinue;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    return Form(
      key: cubit.emailFormKey,
      child: ListView(
        padding: const .fromLTRB(24, 12, 24, 24),
        children: [
          Text(
            'Sign in or create an account',
            style: context.textTheme.headlineLarge,
          ),
          8.h,
          Text(
            "Enter your email and we'll send you a login code — no password needed. New here? Your account is created automatically when you verify — we'll just ask your name and phone once.",
            style: context.textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: .w500,
              height: 1.45,
            ),
          ),
          AppSizes.spaceMd.h,
          AppTextField(
            label: 'Email',
            controller: cubit.emailController,
            icon: Icons.mail_outline,
            hint: 'you@example.com',
            keyboardType: .emailAddress,
            onChanged: (_) => cubit.clearError(),
            validator: AppValidators.email,
          ),
          AppSizes.spaceLg.h,
          AppButton(
            label: 'Send code',
            showArrow: false,
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              cubit.requestOtp();
            },
          ),
          AppSizes.spaceMd.h,
          GuestContinueButton(onPressed: onGuestContinue),
        ],
      ),
    );
  }
}
