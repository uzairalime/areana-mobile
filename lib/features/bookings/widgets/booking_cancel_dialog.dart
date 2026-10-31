import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/utils/app_haptics.dart';
import '../model/user_booking.dart';

Future<bool> showBookingCancelDialog(
  BuildContext context, {
  required UserBooking booking,
}) async {
  AppHaptics.light();
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        title: Text(
          'Cancel booking?',
          style: dialogContext.textTheme.titleLarge?.copyWith(
            fontWeight: .w800,
          ),
        ),
        content: Text(
          'Cancel ${booking.code} at ${booking.venueName} '
          '(${booking.dateLabel}, ${booking.timeLabel})?',
          style: dialogContext.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: .w500,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'Keep booking',
              style: dialogContext.textTheme.labelLarge?.copyWith(
                fontWeight: .w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              AppHaptics.medium();
              Navigator.of(dialogContext).pop(true);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onError,
            ),
            child: Text(
              'Cancel booking',
              style: dialogContext.textTheme.labelLarge?.copyWith(
                color: AppColors.onError,
                fontWeight: .w800,
              ),
            ),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
