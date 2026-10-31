import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/widgets/app_shimmer.dart';

/// Skeleton matching pending CTA + review cards on My reviews.
class MyReviewsShimmer extends StatelessWidget {
  const MyReviewsShimmer({super.key, this.count = 3});

  final int count;

  static const _heroBone = Color(0x55FFFFFF);
  static const _heroBoneSoft = Color(0x38FFFFFF);
  static const _heroShimmerBase = Color(0x40FFFFFF);
  static const _heroShimmerHighlight = Color(0x88FFFFFF);

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const .fromLTRB(20, 8, 20, 28),
      children: [
        const _PendingCardShimmer(),
        12.h,
        for (var i = 0; i < count; i++) ...[
          const _ReviewCardShimmer(),
          if (i < count - 1) 12.h,
        ],
      ],
    );
  }
}

class _PendingCardShimmer extends StatelessWidget {
  const _PendingCardShimmer();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: AppShimmer(
        baseColor: MyReviewsShimmer._heroShimmerBase,
        highlightColor: MyReviewsShimmer._heroShimmerHighlight,
        child: Padding(
          padding: const .all(16),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: .start,
                children: [
                  const ShimmerBox(
                    width: 168,
                    height: 15,
                    radius: 7,
                    color: MyReviewsShimmer._heroBone,
                  ),
                  8.h,
                  const ShimmerBox(
                    width: 148,
                    height: 12,
                    radius: 6,
                    color: MyReviewsShimmer._heroBoneSoft,
                  ),
                ],
              ).expand(),
              10.w,
              const ShimmerBox(
                width: 72,
                height: 40,
                radius: 12,
                color: AppColors.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewCardShimmer extends StatelessWidget {
  const _ReviewCardShimmer();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.outline),
      ),
      child: AppShimmer(
        child: Padding(
          padding: const .all(14),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Row(
                children: [
                  const ShimmerBox(
                    width: 160,
                    height: 15,
                    radius: 7,
                  ).expand(),
                  10.w,
                  const ShimmerBox(width: 78, height: 12, radius: 6),
                ],
              ),
              10.h,
              Row(
                children: [
                  for (var i = 0; i < 5; i++) ...[
                    const ShimmerBox(width: 16, height: 16, radius: 4),
                    if (i < 4) 2.w,
                  ],
                ],
              ),
              12.h,
              const ShimmerBox(width: double.infinity, height: 12, radius: 6),
              8.h,
              const ShimmerBox(width: 220, height: 12, radius: 6),
            ],
          ),
        ),
      ),
    );
  }
}
