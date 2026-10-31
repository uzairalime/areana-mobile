import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_shimmer.dart';

/// Horizontal Explore court-row shimmer (matches [ExploreVenueTile] 118 height).
class ExploreVenueTileShimmerList extends StatelessWidget {
  const ExploreVenueTileShimmerList({super.key, this.count = 5});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const .fromLTRB(0, 4, 0, 110),
      itemCount: count,
      separatorBuilder: (_, _) => 12.h,
      itemBuilder: (_, _) => const ExploreVenueTileShimmer(),
    ).shimmer();
  }
}

class ExploreVenueTileShimmer extends StatelessWidget {
  const ExploreVenueTileShimmer({super.key});

  static const double height = 118;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          border: Border.all(color: AppColors.outline),
          boxShadow: AppTheme.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          child: Row(
            crossAxisAlignment: .stretch,
            children: [
              const SizedBox(
                width: height,
                child: Stack(
                  fit: .expand,
                  children: [
                    ShimmerBox(width: height, height: height, radius: 0),
                    Positioned(
                      left: 8,
                      top: 8,
                      child: ShimmerBox(width: 56, height: 22, radius: 999),
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
                      const ShimmerBox(width: 160, height: 16, radius: 8),
                      8.h,
                      const ShimmerBox(width: 120, height: 12, radius: 6),
                      const Spacer(),
                      Row(
                        children: [
                          const ShimmerBox(width: 88, height: 16, radius: 8),
                          const Spacer(),
                          const ShimmerBox(width: 22, height: 22, radius: 11),
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
