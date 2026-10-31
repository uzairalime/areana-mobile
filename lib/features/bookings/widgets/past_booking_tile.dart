import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/media_slider/cache_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_haptics.dart';
import '../../booking/widgets/court_hero_canvas.dart';
import '../model/user_booking.dart';

class PastBookingTile extends StatelessWidget {
  const PastBookingTile({
    super.key,
    required this.booking,
    required this.onTap,
    required this.onRebook,
    this.onAddReview,
  });

  final UserBooking booking;
  final VoidCallback onTap;
  final VoidCallback onRebook;

  /// Null when cancelled — review CTA is hidden.
  final VoidCallback? onAddReview;

  @override
  Widget build(BuildContext context) {
    final showReview = booking.status == .completed;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          side: const BorderSide(color: AppColors.outline),
        ),
        clipBehavior: .antiAlias,
        child: InkWell(
          onTap: () {
            AppHaptics.selection();
            onTap();
          },
          child: Column(
            children: [
              Padding(
                padding: const .fromLTRB(14, 14, 14, 12),
                child: Row(
                  crossAxisAlignment: .start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 64,
                        height: 64,
                        child: booking.imageUrl.isNotEmpty
                            ? CacheImage(
                                url: booking.imageUrl,
                                width: 64,
                                height: 64,
                                memCacheWidth: 160,
                                errorWidget: CourtHeroCanvas(
                                  color: booking.heroColor,
                                  height: 64,
                                  showGradient: false,
                                ),
                              )
                            : CourtHeroCanvas(
                                color: booking.heroColor,
                                height: 64,
                                showGradient: false,
                              ),
                      ),
                    ),
                    12.w,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: .start,
                        children: [
                          Text(
                            booking.venueName,
                            maxLines: 2,
                            overflow: .ellipsis,
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: .w800,
                              fontSize: 15,
                              letterSpacing: -0.1,
                            ),
                          ),
                          6.h,
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              4.w,
                              Expanded(
                                child: Text(
                                  booking.location,
                                  maxLines: 1,
                                  overflow: .ellipsis,
                                  style: context.textTheme.labelMedium
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                        fontWeight: .w600,
                                        fontSize: 12,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          4.h,
                          Text(
                            '${booking.dateLabel} · ${booking.durationLabel}',
                            maxLines: 1,
                            overflow: .ellipsis,
                            style: context.textTheme.labelMedium?.copyWith(
                              color: AppColors.textDisabled,
                              fontWeight: .w600,
                              fontSize: 12,
                            ),
                          ),
                          if (booking.status == .cancelled) ...[
                            6.h,
                            Text(
                              'Cancelled',
                              style: context.textTheme.labelMedium?.copyWith(
                                color: AppColors.error,
                                fontWeight: .w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.outline),
              SizedBox(
                height: 48,
                child: Row(
                  children: [
                    if (showReview) ...[
                      _FooterAction(
                        icon: booking.isReviewed
                            ? Icons.check_circle_rounded
                            : Icons.star_border_rounded,
                        label: booking.isReviewed ? 'Reviewed' : 'Add a review',
                        color: booking.isReviewed
                            ? AppColors.freeFee
                            : AppColors.textBody,
                        onTap: booking.isReviewed ? null : onAddReview,
                      ).expand(),
                      const VerticalDivider(
                        width: 1,
                        color: AppColors.outline,
                      ),
                    ],
                    _FooterAction(
                      icon: Icons.replay_rounded,
                      label: 'Rebook',
                      color: AppColors.textBody,
                      onTap: onRebook,
                    ).expand(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterAction extends StatelessWidget {
  const _FooterAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap == null
          ? null
          : () {
              AppHaptics.selection();
              onTap!();
            },
      child: Row(
        mainAxisAlignment: .center,
        children: [
          Icon(icon, size: 18, color: color),
          6.w,
          Text(
            label,
            style: context.textTheme.labelLarge?.copyWith(
              fontSize: 13,
              fontWeight: .w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
