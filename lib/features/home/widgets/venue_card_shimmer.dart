import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_shimmer.dart';

class VenueCardShimmerList extends StatelessWidget {
  const VenueCardShimmerList({super.key, this.count = 3});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < count; i++) ...[
          const VenueCardShimmer(),
          if (i < count - 1) AppSizes.spaceMd.h,
        ],
      ],
    ).shimmer();
  }
}

class VenueCardShimmer extends StatelessWidget {
  const VenueCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.outline),
        boxShadow: AppTheme.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            const ShimmerBox(
              width: double.infinity,
              height: 170,
              radius: 0,
            ),
            Column(
              crossAxisAlignment: .start,
              children: [
                const ShimmerBox(width: 180, height: 18, radius: 8),
                10.h,
                const ShimmerBox(width: 140, height: 12, radius: 6),
                14.h,
                const ShimmerBox(width: 100, height: 16, radius: 8),
                14.h,
                Row(
                  children: [
                    const ShimmerBox(width: 72, height: 26, radius: 999),
                    8.w,
                    const ShimmerBox(width: 64, height: 26, radius: 999),
                    8.w,
                    const ShimmerBox(width: 56, height: 26, radius: 999),
                  ],
                ),
                16.h,
                const Divider(height: 1, color: AppColors.outline),
                12.h,
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: .start,
                      children: [
                        const ShimmerBox(width: 80, height: 10, radius: 5),
                        6.h,
                        const ShimmerBox(width: 110, height: 14, radius: 6),
                      ],
                    ).expand(),
                    const ShimmerBox(width: 112, height: 44, radius: 14),
                  ],
                ),
              ],
            ).paddingAll(AppSizes.spaceMd),
          ],
        ),
      ),
    );
  }
}

class SportGameGridShimmer extends StatelessWidget {
  const SportGameGridShimmer({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        const ShimmerBox(width: 150, height: 18, radius: 8),
        AppSizes.spaceSm.h,
        Row(
          children: [
            for (var i = 0; i < count; i++)
              const _SportTileShimmer().expand(),
          ],
        ),
      ],
    ).shimmer();
  }
}

class _SportTileShimmer extends StatelessWidget {
  const _SportTileShimmer();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          const ShimmerBox(width: 44, height: 44, radius: 22),
          8.h,
          const ShimmerBox(width: 48, height: 12, radius: 6),
        ],
      ).paddingOnly(top: 14, bottom: 12, left: 4, right: 4),
    ).paddingSymmetric(horizontal: 4);
  }
}
