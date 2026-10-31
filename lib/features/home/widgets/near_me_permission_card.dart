import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/utils/app_haptics.dart';

class NearMePermissionCard extends StatelessWidget {
  const NearMePermissionCard({
    super.key,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.isLoading = false,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.outline),
      ),
      child: Padding(
        padding: const .all(16),
        child: Row(
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: .circle,
              ),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.near_me_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
            ),
            12.w,
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    'Find courts near you',
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: .w800,
                    ),
                  ),
                  4.h,
                  Text(
                    message,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            8.w,
            FilledButton(
              onPressed: isLoading
                  ? null
                  : () {
                      AppHaptics.selection();
                      onAction();
                    },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                minimumSize: const Size(0, 40),
                padding: const .symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.onPrimary,
                      ),
                    )
                  : Text(
                      actionLabel,
                      style: context.textTheme.labelLarge?.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: .w800,
                        fontSize: 13,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
