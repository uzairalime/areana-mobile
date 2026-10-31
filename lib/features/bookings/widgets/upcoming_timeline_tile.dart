import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/media_slider/cache_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_haptics.dart';
import '../../booking/widgets/court_hero_canvas.dart';
import '../model/user_booking.dart';
import 'booking_status_chip.dart';

class UpcomingTimelineTile extends StatelessWidget {
  const UpcomingTimelineTile({
    super.key,
    required this.booking,
    required this.isLast,
    required this.onTap,
  });

  final UserBooking booking;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: .stretch,
        children: [
          SizedBox(
            width: 22,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: .circle,
                    color: AppColors.primary,
                    border: Border.all(color: AppColors.accent, width: 2),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const .symmetric(vertical: 4),
                      color: AppColors.outline,
                    ),
                  ),
              ],
            ),
          ),
          10.w,
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: DecoratedBox(
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
                    child: Padding(
                      padding: const .all(12),
                      child: Row(
                        crossAxisAlignment: .start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 56,
                              height: 56,
                              child: booking.imageUrl.isNotEmpty
                                  ? CacheImage(
                                      url: booking.imageUrl,
                                      width: 56,
                                      height: 56,
                                      memCacheWidth: 140,
                                      errorWidget: CourtHeroCanvas(
                                        color: booking.heroColor,
                                        height: 56,
                                        showGradient: false,
                                      ),
                                    )
                                  : CourtHeroCanvas(
                                      color: booking.heroColor,
                                      height: 56,
                                      showGradient: false,
                                    ),
                            ),
                          ),
                          12.w,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: .start,
                              children: [
                                Row(
                                  crossAxisAlignment: .start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        booking.venueName,
                                        maxLines: 1,
                                        overflow: .ellipsis,
                                        style: context.textTheme.titleSmall
                                            ?.copyWith(
                                              fontWeight: .w800,
                                              fontSize: 15,
                                            ),
                                      ),
                                    ),
                                    8.w,
                                    BookingStatusChip(
                                      status: booking.status,
                                      compact: true,
                                    ),
                                  ],
                                ),
                                4.h,
                                Text(
                                  '${booking.sport} · ${booking.courtLabel}',
                                  maxLines: 1,
                                  overflow: .ellipsis,
                                  style: context.textTheme.labelMedium
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                        fontWeight: .w600,
                                        fontSize: 12,
                                      ),
                                ),
                                8.h,
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_rounded,
                                      size: 13,
                                      color: AppColors.primary,
                                    ),
                                    6.w,
                                    Expanded(
                                      child: Text(
                                        booking.scheduleLine,
                                        maxLines: 1,
                                        overflow: .ellipsis,
                                        style: context.textTheme.labelMedium
                                            ?.copyWith(
                                              color: AppColors.text,
                                              fontWeight: .w700,
                                              fontSize: 12,
                                            ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 16,
                                      color: AppColors.primary,
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
            ),
          ),
        ],
      ),
    );
  }
}
