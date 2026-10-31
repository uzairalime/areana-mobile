import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/media_slider/cache_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_haptics.dart';
import '../../booking/widgets/court_hero_canvas.dart';
import '../model/user_booking.dart';

/// Large hero card for the nearest upcoming booking.
class UpcomingFeaturedCard extends StatelessWidget {
  const UpcomingFeaturedCard({
    super.key,
    required this.booking,
    required this.onTap,
  });

  final UserBooking booking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AppHaptics.selection();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusXl),
            boxShadow: AppTheme.cardShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusXl),
            child: SizedBox(
              height: 220,
              child: Stack(
                fit: .expand,
                children: [
                  if (booking.imageUrl.isNotEmpty)
                    CacheImage(
                      url: booking.imageUrl,
                      height: 220,
                      width: double.infinity,
                      memCacheWidth: 900,
                      errorWidget: CourtHeroCanvas(
                        color: booking.heroColor,
                        height: 220,
                        showGradient: false,
                      ),
                    )
                  else
                    CourtHeroCanvas(
                      color: booking.heroColor,
                      height: 220,
                      showGradient: false,
                    ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: .topCenter,
                        end: .bottomCenter,
                        colors: [
                          Color(0x140D1B14),
                          Color(0xCC0D1B14),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const .all(16),
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        _StatusPill(status: booking.status),
                        const Spacer(),
                        Text(
                          booking.venueName,
                          maxLines: 2,
                          overflow: .ellipsis,
                          style: context.textTheme.titleLarge?.copyWith(
                            color: AppColors.onPrimary,
                            fontSize: 22,
                            fontWeight: .w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                        6.h,
                        Text(
                          '${booking.sport} · ${booking.courtLabel}',
                          maxLines: 1,
                          overflow: .ellipsis,
                          style: context.textTheme.labelLarge?.copyWith(
                            color: AppColors.onPrimary.withValues(alpha: 0.88),
                            fontWeight: .w600,
                          ),
                        ),
                        10.h,
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color: AppColors.accent,
                            ),
                            6.w,
                            Expanded(
                              child: Text(
                                booking.scheduleLine,
                                maxLines: 1,
                                overflow: .ellipsis,
                                style: context.textTheme.labelLarge?.copyWith(
                                  color: AppColors.onPrimary,
                                  fontWeight: .w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: AppColors.accent,
                            ),
                          ],
                        ),
                      ],
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final UserBookingStatus status;

  @override
  Widget build(BuildContext context) {
    final label = status.label;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(
          color: AppColors.onAccent,
          fontWeight: .w800,
          fontSize: 11,
        ),
      ).paddingSymmetric(horizontal: 10, vertical: 5),
    );
  }
}
