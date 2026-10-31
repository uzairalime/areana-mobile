import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../model/user_booking.dart';

class BookingStatusChip extends StatelessWidget {
  const BookingStatusChip({
    super.key,
    required this.status,
    this.compact = false,
  });

  final UserBookingStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      .confirmed => (AppColors.accentSoft, AppColors.payBadgeText),
      .pending => (const Color(0xFFFFF4D6), const Color(0xFF8A6A00)),
      .completed => (AppColors.primarySoft, AppColors.primary),
      .cancelled => (const Color(0xFFFCE8E8), AppColors.error),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Text(
        status.label,
        style: context.textTheme.labelMedium?.copyWith(
          color: fg,
          fontWeight: .w800,
          fontSize: compact ? 10 : 12,
        ),
      ).paddingSymmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 5,
      ),
    );
  }
}
