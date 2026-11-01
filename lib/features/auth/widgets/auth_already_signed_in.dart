import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/widgets/app_button.dart';
import '../cubit/auth_cubit.dart';

/// Mirrors web `/auth` for a visitor who is already signed in: they are
/// NOT bounced away — they get Continue, or Switch accounts.
class AuthAlreadySignedIn extends StatelessWidget {
  const AuthAlreadySignedIn({
    super.key,
    required this.email,
    required this.onContinue,
  });

  final String email;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    return ListView(
      padding: const .fromLTRB(24, 12, 24, 24),
      children: [
        Text(
          "You're already signed in",
          style: context.textTheme.headlineLarge,
          textAlign: .center,
        ),
        8.h,
        Text.rich(
          TextSpan(
            text: 'Signed in as ',
            style: context.textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: .w500,
              height: 1.45,
            ),
            children: [
              TextSpan(
                text: email,
                style: context.textTheme.titleSmall?.copyWith(
                  color: AppColors.text,
                  fontWeight: .w800,
                ),
              ),
              const TextSpan(text: '. Continue to where you were headed, or switch accounts.'),
            ],
          ),
          textAlign: .center,
        ),
        AppSizes.spaceLg.h,
        AppButton(
          label: 'Continue',
          showArrow: false,
          onPressed: onContinue,
        ),
        AppSizes.spaceMd.h,
        TextButton(
          onPressed: () => cubit.switchAccount(),
          child: const Text('Sign in with a different account'),
        ).center(),
      ],
    );
  }
}
