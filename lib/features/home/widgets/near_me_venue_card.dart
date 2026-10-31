import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/media_slider/cache_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/utils/money_format.dart';
import '../../booking/widgets/court_hero_canvas.dart';
import '../model/nearby_venue.dart';

class NearMeVenueCard extends StatelessWidget {
  const NearMeVenueCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final NearbyVenue item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final venue = item.venue;
    return SizedBox(
      width: 168,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: InkWell(
          onTap: () {
            AppHaptics.selection();
            onTap();
          },
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(color: AppColors.outline),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                ClipRRect(
                  borderRadius: const .vertical(
                    top: Radius.circular(AppSizes.radiusLg - 1),
                  ),
                  child: SizedBox(
                    height: 96,
                    width: double.infinity,
                    child: Stack(
                      fit: .expand,
                      children: [
                        if (venue.imageUrls.isNotEmpty)
                          CacheImage(
                            url: venue.imageUrls.first,
                            height: 96,
                            width: 168,
                            memCacheWidth: 360,
                            errorWidget: CourtHeroCanvas(
                              color: venue.heroColor,
                              height: 96,
                              showGradient: false,
                            ),
                          )
                        else
                          CourtHeroCanvas(
                            color: venue.heroColor,
                            height: 96,
                            showGradient: false,
                          ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusPill,
                              ),
                            ),
                            child: Text(
                              item.distanceLabel,
                              style: context.textTheme.labelSmall?.copyWith(
                                color: AppColors.accent,
                                fontWeight: .w800,
                                fontSize: 11,
                              ),
                            ).paddingSymmetric(horizontal: 8, vertical: 4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const .fromLTRB(10, 10, 10, 12),
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        venue.name,
                        maxLines: 1,
                        overflow: .ellipsis,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: .w800,
                          fontSize: 13,
                        ),
                      ),
                      4.h,
                      Text(
                        venue.sport,
                        maxLines: 1,
                        overflow: .ellipsis,
                        style: context.textTheme.labelMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: .w600,
                          fontSize: 11,
                        ),
                      ),
                      6.h,
                      Text(
                        '${MoneyFormat.pkr(venue.priceFrom)}/hr',
                        style: context.textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: .w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
