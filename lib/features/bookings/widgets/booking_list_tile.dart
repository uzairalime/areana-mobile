import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/media_slider/cache_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money_format.dart';
import '../../booking/widgets/court_hero_canvas.dart';
import '../model/user_booking.dart';

class BookingListTile extends StatelessWidget {
  const BookingListTile({
    super.key,
    required this.booking,
    required this.onTap,
  });

  final UserBooking booking;
  final VoidCallback onTap;

  static const double height = 148;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusXl),
              border: Border.all(color: AppColors.outline),
              boxShadow: AppTheme.cardShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusXl),
              child: Row(
                crossAxisAlignment: .stretch,
                children: [
                  SizedBox(
                    width: 104,
                    child: Stack(
                      fit: .expand,
                      children: [
                        if (booking.imageUrl.isNotEmpty)
                          CacheImage(
                            url: booking.imageUrl,
                            height: height,
                            width: 104,
                            memCacheWidth: 240,
                            errorWidget: CourtHeroCanvas(
                              color: booking.heroColor,
                              height: height,
                              showGradient: false,
                            ),
                          )
                        else
                          CourtHeroCanvas(
                            color: booking.heroColor,
                            height: height,
                            showGradient: false,
                          ),
                        Positioned(
                          left: 8,
                          top: 8,
                          child: _StatusChip(status: booking.status),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const .fromLTRB(12, 10, 12, 10),
                      child: Column(
                        crossAxisAlignment: .start,
                        children: [
                          Text(
                            booking.venueName,
                            maxLines: 1,
                            overflow: .ellipsis,
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: .w800,
                              fontSize: 15,
                            ),
                          ),
                          2.h,
                          Text(
                            booking.sport,
                            style: context.textTheme.labelMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: .w700,
                              fontSize: 12,
                            ),
                          ),
                          6.h,
                          _MetaRow(
                            icon: Icons.calendar_today_rounded,
                            text: booking.dateLabel,
                          ),
                          3.h,
                          _MetaRow(
                            icon: Icons.schedule_rounded,
                            text: booking.timeLabel,
                          ),
                          3.h,
                          _MetaRow(
                            icon: Icons.grid_view_rounded,
                            text: booking.courtLabel,
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Text(
                                MoneyFormat.pkr(booking.amountDue),
                                style: context.textTheme.titleSmall?.copyWith(
                                  fontWeight: .w800,
                                ),
                              ),
                              6.w,
                              Text(
                                booking.payAtGround ? 'Pay at ground' : 'Paid',
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: booking.payAtGround
                                      ? AppColors.payBadgeText
                                      : AppColors.freeFee,
                                  fontWeight: .w700,
                                ),
                              ).expand(),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final UserBookingStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      .confirmed => (AppColors.accent, AppColors.onAccent),
      .pending => (AppColors.accentSoft, AppColors.payBadgeText),
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
        style: context.textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: .w800,
          fontSize: 10,
        ),
      ).paddingSymmetric(horizontal: 8, vertical: 4),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        4.w,
        Text(
          text,
          maxLines: 1,
          overflow: .ellipsis,
          style: context.textTheme.labelMedium?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ).expand(),
      ],
    );
  }
}
