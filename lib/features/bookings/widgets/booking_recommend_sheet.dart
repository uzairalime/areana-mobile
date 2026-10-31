import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/utils/app_haptics.dart';
import '../model/user_booking.dart';

Future<bool?> showBookingRecommendSheet(
  BuildContext context, {
  required UserBooking booking,
}) {
  AppHaptics.light();
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.scrim,
    builder: (sheetContext) {
      return DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Color(0x330D1B14),
              blurRadius: 40,
              offset: Offset(0, -12),
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
                  child: const SizedBox(width: 40, height: 4),
                ),
                22.h,
                Text(
                  'Recommend this venue?',
                  textAlign: .center,
                  style: sheetContext.textTheme.headlineMedium?.copyWith(
                    fontSize: 22,
                    fontWeight: .w800,
                    letterSpacing: -0.4,
                  ),
                ),
                8.h,
                Text(
                  booking.venueName,
                  textAlign: .center,
                  style: sheetContext.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: .w600,
                  ),
                ),
                28.h,
                Row(
                  children: [
                    _RecommendChoice(
                      icon: Icons.thumb_up_alt_outlined,
                      onTap: () {
                        AppHaptics.medium();
                        Navigator.of(sheetContext).pop(true);
                      },
                    ).expand(),
                    Padding(
                      padding: const .symmetric(horizontal: 14),
                      child: Text(
                        'or',
                        style: sheetContext.textTheme.labelLarge?.copyWith(
                          color: AppColors.textDisabled,
                          fontWeight: .w600,
                        ),
                      ),
                    ),
                    _RecommendChoice(
                      icon: Icons.thumb_down_alt_outlined,
                      onTap: () {
                        AppHaptics.medium();
                        Navigator.of(sheetContext).pop(false);
                      },
                    ).expand(),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _RecommendChoice extends StatelessWidget {
  const _RecommendChoice({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 96,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.outline),
            boxShadow: const [
              BoxShadow(
                color: Color(0x140D1B14),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
            color: AppColors.surface,
          ),
          child: Icon(icon, size: 36, color: AppColors.text),
        ),
      ),
    );
  }
}
