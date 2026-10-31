import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/utils/money_format.dart';
import '../../../core/widgets/app_button.dart';

Future<void> showBookingAuthSheet(
  BuildContext context, {
  required String title,
  required String body,
  required VoidCallback onLogin,
  required VoidCallback onSignup,
  String dismissLabel = 'Maybe later',
  String? summaryTitle,
  String? summaryMeta,
  int? summaryAmount,
}) {
  AppHaptics.light();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.scrim,
    builder: (sheetContext) {
      return DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Color(0x470D1B14),
              blurRadius: 50,
              offset: Offset(0, -20),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const .fromLTRB(24, 12, 24, 28),
            child: Column(
              mainAxisSize: .min,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                  ),
                  child: const SizedBox(width: 44, height: 5),
                ),
                14.h,
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const SizedBox(
                    width: 64,
                    height: 64,
                    child: Icon(
                      Icons.lock_outline,
                      color: AppColors.accent,
                      size: 28,
                    ),
                  ),
                ),
                14.h,
                Text(
                  title,
                  textAlign: .center,
                  style: sheetContext.textTheme.headlineSmall?.copyWith(
                    fontSize: 22,
                    fontWeight: .w800,
                  ),
                ),
                8.h,
                Text(
                  body,
                  textAlign: .center,
                  style: sheetContext.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                if (summaryTitle != null) ...[
                  14.h,
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: .start,
                          children: [
                            Text(
                              summaryTitle,
                              style: sheetContext.textTheme.titleSmall
                                  ?.copyWith(fontWeight: .w800),
                            ),
                            if (summaryMeta != null) ...[
                              2.h,
                              Text(
                                summaryMeta,
                                style: sheetContext.textTheme.labelMedium
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                              ),
                            ],
                          ],
                        ).expand(),
                        if (summaryAmount != null)
                          Text(
                            MoneyFormat.pkr(summaryAmount),
                            style: sheetContext.textTheme.titleSmall?.copyWith(
                              fontWeight: .w800,
                            ),
                          ),
                      ],
                    ).paddingSymmetric(horizontal: 14, vertical: 12),
                  ),
                ],
                16.h,
                AppButton(
                  label: 'Log in',
                  showArrow: false,
                  onPressed: () {
                    AppHaptics.medium();
                    Navigator.of(sheetContext).pop();
                    onLogin();
                  },
                ),
                10.h,
                AppButton.outlined(
                  label: 'Create account',
                  onPressed: () {
                    AppHaptics.medium();
                    Navigator.of(sheetContext).pop();
                    onSignup();
                  },
                ),
                4.h,
                TextButton(
                  onPressed: () {
                    AppHaptics.selection();
                    Navigator.of(sheetContext).pop();
                  },
                  child: Text(
                    dismissLabel,
                    style: sheetContext.textTheme.labelLarge?.copyWith(
                      color: AppColors.textBody,
                      fontWeight: .w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
