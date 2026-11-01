import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/widgets/app_button.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

/// Step 4 of user-web `/auth`, shown only when there is something to
/// show: a welcome promo, or a referral notice. Plain sign-ins skip
/// this step and navigate straight home. Web auto-redirects after 8s;
/// mobile does not — the button is the only way on, so a promo code
/// is never navigated away from before it can be copied.
class AuthDoneStep extends StatelessWidget {
  const AuthDoneStep({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final promo = state.welcomePromoCode;
        final notice = state.referralNotice;
        return ListView(
          padding: const .fromLTRB(24, 12, 24, 24),
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: .circle,
              ),
              child: const Icon(
                Icons.check,
                color: AppColors.primary,
                size: 28,
              ),
            ).center(),
            AppSizes.spaceLg.h,
            Text(
              promo != null ? 'Welcome to Areana!' : 'You\'re in',
              style: context.textTheme.headlineLarge,
              textAlign: .center,
            ),
            if (promo != null) ...[
              8.h,
              Text(
                "Your account is ready. Here's a welcome gift for joining with a friend's invite:",
                style: context.textTheme.titleSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: .w500,
                  height: 1.45,
                ),
                textAlign: .center,
              ),
              AppSizes.spaceMd.h,
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: promo));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Promo code copied')),
                  );
                },
                child: Container(
                  padding: const .symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Text(
                    promo,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: .w800,
                      letterSpacing: 2,
                    ),
                    textAlign: .center,
                  ),
                ),
              ),
              8.h,
              Text(
                'Use it at checkout on your next booking. Tap to copy.',
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: .center,
              ),
            ],
            if (notice != null && notice.isNotEmpty) ...[
              8.h,
              Container(
                padding: const .symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Text(
                  notice,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: .w600,
                  ),
                  textAlign: .center,
                ),
              ),
            ],
            AppSizes.spaceLg.h,
            AppButton(
              label: promo != null ? 'Start booking' : 'Continue',
              showArrow: false,
              onPressed: onContinue,
            ),
          ],
        );
      },
    );
  }
}
