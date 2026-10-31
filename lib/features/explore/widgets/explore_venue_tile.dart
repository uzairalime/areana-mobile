import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money_format.dart';
import '../../booking/widgets/court_hero_canvas.dart';
import '../../home/model/venue.dart';

/// Full-width list row (not a grid cell) for Explore Courts.
class ExploreVenueTile extends StatelessWidget {
  const ExploreVenueTile({
    super.key,
    required this.venue,
    required this.onTap,
  });

  final Venue venue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          side: const BorderSide(color: AppColors.outline),
        ),
        clipBehavior: .antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Row(
              crossAxisAlignment: .stretch,
              children: [
                SizedBox(
                  width: 118,
                  child: Stack(
                    fit: .expand,
                    children: [
                      CourtHeroCanvas(
                        color: venue.heroColor,
                        height: 118,
                        showGradient: false,
                      ),
                      Positioned(
                        left: 8,
                        top: 8,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusPill,
                            ),
                          ),
                          child: Text(
                            venue.sport,
                            style: context.textTheme.labelSmall?.copyWith(
                              fontWeight: .w800,
                              fontSize: 11,
                            ),
                          ).paddingSymmetric(horizontal: 8, vertical: 4),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const .fromLTRB(12, 12, 12, 12),
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        Text(
                          venue.name,
                          maxLines: 2,
                          overflow: .ellipsis,
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: .w800,
                            fontSize: 15,
                            height: 1.2,
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
                            2.w,
                            Text(
                              venue.location,
                              maxLines: 1,
                              overflow: .ellipsis,
                              style: context.textTheme.labelMedium?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ).expand(),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Text(
                              MoneyFormat.pkr(venue.priceFrom),
                              style: context.textTheme.titleSmall?.copyWith(
                                fontWeight: .w800,
                              ),
                            ),
                            4.w,
                            Text(
                              '/hr',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: AppColors.textSecondary,
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
    );
  }
}
