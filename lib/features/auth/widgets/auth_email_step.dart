import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../cubit/auth_cubit.dart';
import 'auth_widgets.dart';

/// Email OTP plus native social buttons. Android is Google-only; iOS
/// also offers Sign in with Apple. New accounts finish name + phone
/// after the first verified session.
class AuthEmailStep extends StatelessWidget {
  const AuthEmailStep({super.key, required this.onGuestContinue});

  final VoidCallback onGuestContinue;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    final showGoogle = cubit.showGoogleSignIn;
    final showApple = cubit.showAppleSignIn;
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
            showApple
                ? 'Use Google, Apple, or an email login code. New here? We only ask for your name and phone once.'
                : 'Use Google or an email login code. New here? We only ask for your name and phone once.',
            style: context.textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: .w500,
              height: 1.45,
            ),
          ),
          AppSizes.spaceMd.h,
          if (showGoogle) ...[
            SocialAuthButton.google(
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                cubit.continueWithGoogle();
              },
            ),
            AppSizes.spaceMd.h,
          ],
          if (showApple) ...[
            SocialAuthButton.apple(
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                cubit.continueWithApple();
              },
            ),
            AppSizes.spaceMd.h,
          ],
          if (showGoogle || showApple) ...[
            const AuthOrDivider(),
            AppSizes.spaceMd.h,
          ],
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
