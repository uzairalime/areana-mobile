import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/utils/email_mask.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_otp_field.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class OtpVerifyPanel extends StatelessWidget {
  const OtpVerifyPanel({
    super.key,
    required this.email,
    required this.onVerify,
    required this.onResend,
  });

  final String email;
  final VoidCallback onVerify;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) =>
          previous.otpResendSeconds != current.otpResendSeconds,
      builder: (context, state) {
        return Form(
          key: cubit.otpFormKey,
          child: ListView(
            padding: const .fromLTRB(24, 12, 24, 24),
            children: [
              Text.rich(
                TextSpan(
                  text: 'We sent a code to ',
                  style: context.textTheme.titleSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: .w500,
                    height: 1.45,
                  ),
                  children: [
                    TextSpan(
                      text: EmailMask.mask(email),
                      style: context.textTheme.titleSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: .w800,
                      ),
                    ),
                  ],
                ),
              ),
              AppSizes.spaceMd.h,
              AppOtpField(
                controller: cubit.otpController,
                onChanged: (_) => cubit.clearError(),
                validator: AppValidators.otp,
              ),
              AppSizes.spaceLg.h,
              AppButton(
                label: 'Verify code',
                showArrow: false,
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  onVerify();
                },
              ),
              AppSizes.spaceMd.h,
              Row(
                mainAxisAlignment: .center,
                children: [
                  Text(
                    'Did not get it?',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textBody,
                      fontWeight: .w500,
                    ),
                  ),
                  if (state.canResendOtp)
                    TextButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        onResend();
                      },
                      child: const Text('Resend code'),
                    )
                  else
                    Text(
                      ' Resend in ${_format(state.otpResendSeconds)}',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: .w700,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static String _format(int seconds) {
    final minutes = seconds ~/ 60;
    final rest = seconds % 60;
    return '$minutes:${rest.toString().padLeft(2, '0')}';
  }
}
