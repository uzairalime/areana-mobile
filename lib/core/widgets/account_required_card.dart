import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../consts/app_colors.dart';
import '../consts/app_sizes.dart';
import '../extensions/extensions.dart';
import '../router/app_router.dart';
import '../utils/app_haptics.dart';

/// Pitchside guest gate — forest card, lime CTA. More refined than a flat promo tile.
class AccountRequiredCard extends StatelessWidget {
  const AccountRequiredCard({
    super.key,
    this.title = 'Account required',
    this.message =
        'Sign in to unlock bookings, offers, and a profile that stays with you across devices.',
    this.primaryLabel = 'Create account',
    this.onPrimary,
    this.onSignIn,
  });

  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback? onSignIn;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: .topLeft,
            end: .bottomRight,
            colors: [Color(0xFF145239), AppColors.primary, Color(0xFF0A2E20)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x330D1B14),
              blurRadius: 28,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Stack(
          children: [
            const Positioned(
              top: -36,
              right: -28,
              child: _Glow(size: 140, opacity: 0.14),
            ),
            const Positioned(
              bottom: 24,
              left: -40,
              child: _Glow(size: 120, opacity: 0.1),
            ),
            Padding(
              padding: const .fromLTRB(28, 32, 28, 22),
              child: Column(
                mainAxisSize: .min,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      shape: .circle,
                      color: AppColors.surface.withValues(alpha: 0.12),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.45),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.18),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const SizedBox(
                      width: 76,
                      height: 76,
                      child: Icon(
                        Icons.lock_person_rounded,
                        color: AppColors.accent,
                        size: 36,
                      ),
                    ),
                  ),
                  22.h,
                  Text(
                    title,
                    textAlign: .center,
                    style: context.textTheme.headlineSmall?.copyWith(
                      color: AppColors.onPrimary,
                      fontSize: 24,
                      fontWeight: .w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  10.h,
                  Text(
                    message,
                    textAlign: .center,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onPrimary.withValues(alpha: 0.86),
                      fontSize: 14,
                      height: 1.45,
                      fontWeight: .w500,
                    ),
                  ),
                  26.h,
                  FilledButton(
                    onPressed: () {
                      AppHaptics.medium();
                      if (onPrimary != null) {
                        onPrimary!();
                        return;
                      }
                      context.push(AppRoutes.signup);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.onAccent,
                      minimumSize: const Size.fromHeight(52),
                      shape: const StadiumBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: .center,
                      children: [
                        Text(
                          primaryLabel,
                          style: context.textTheme.titleSmall?.copyWith(
                            color: AppColors.onAccent,
                            fontWeight: .w800,
                            fontSize: 16,
                          ),
                        ),
                        8.w,
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: AppColors.onAccent,
                        ),
                      ],
                    ),
                  ),
                  6.h,
                  TextButton(
                    onPressed: () {
                      AppHaptics.selection();
                      if (onSignIn != null) {
                        onSignIn!();
                        return;
                      }
                      context.push(AppRoutes.login);
                    },
                    child: Text(
                      'I already have an account',
                      style: context.textTheme.labelLarge?.copyWith(
                        color: AppColors.accent,
                        fontWeight: .w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: .circle,
        color: AppColors.accent.withValues(alpha: opacity),
      ),
      child: SizedBox(width: size, height: size),
    );
  }
}

/// Full-screen guest placeholder for tab routes that need an account.
class GuestGateScreen extends StatelessWidget {
  const GuestGateScreen({
    super.key,
    this.title = 'Account required',
    this.message =
        'Sign in to unlock bookings, offers, and a profile that stays with you across devices.',
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AccountRequiredCard(
          title: title,
          message: message,
        ).paddingSymmetric(horizontal: AppSizes.pagePadding).center(),
      ),
    );
  }
}
