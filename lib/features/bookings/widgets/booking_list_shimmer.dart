import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../model/booking_filter_tab.dart';

class BookingListShimmer extends StatelessWidget {
  const BookingListShimmer({
    super.key,
    this.tab = .upcoming,
    this.timelineCount = 3,
    this.pastCount = 4,
  });

  final BookingFilterTab tab;
  final int timelineCount;
  final int pastCount;

  @override
  Widget build(BuildContext context) {
    return switch (tab) {
      .upcoming => _UpcomingShimmer(timelineCount: timelineCount),
      .past || .reviews => _PastListShimmer(count: pastCount),
    }.shimmer();
  }
}

class _UpcomingShimmer extends StatelessWidget {
  const _UpcomingShimmer({required this.timelineCount});

  final int timelineCount;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const .fromLTRB(
        AppSizes.pagePadding,
        4,
        AppSizes.pagePadding,
        110,
      ),
      children: [
        const _FeaturedCardShimmer(),
        22.h,
        const ShimmerBox(width: 120, height: 12, radius: 6),
        12.h,
        for (var i = 0; i < timelineCount; i++)
          _TimelineTileShimmer(isLast: i == timelineCount - 1),
      ],
    );
  }
}

class _FeaturedCardShimmer extends StatelessWidget {
  const _FeaturedCardShimmer();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
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
              const ColoredBox(color: AppColors.shimmerBase),
              Padding(
                padding: const .all(16),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    const ShimmerBox(width: 78, height: 22, radius: 11),
                    const Spacer(),
                    const ShimmerBox(width: 210, height: 22, radius: 8),
                    8.h,
                    const ShimmerBox(width: 140, height: 12, radius: 6),
                    12.h,
                    Row(
                      children: [
                        const ShimmerBox(width: 14, height: 14, radius: 4),
                        8.w,
                        const ShimmerBox(width: 180, height: 12, radius: 6),
                        const Spacer(),
                        const ShimmerBox(width: 18, height: 18, radius: 4),
                      ],
                    ),
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

class _TimelineTileShimmer extends StatelessWidget {
  const _TimelineTileShimmer({required this.isLast});

  final bool isLast;

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
                  decoration: const BoxDecoration(
                    shape: .circle,
                    color: AppColors.shimmerBase,
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
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  border: Border.all(color: AppColors.outline),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Padding(
                  padding: const .all(12),
                  child: Row(
                    crossAxisAlignment: .start,
                    children: [
                      const ShimmerBox(width: 56, height: 56, radius: 12),
                      12.w,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: .start,
                          children: [
                            Row(
                              children: [
                                const ShimmerBox(
                                  width: 130,
                                  height: 14,
                                  radius: 7,
                                ).expand(),
                                8.w,
                                const ShimmerBox(
                                  width: 64,
                                  height: 20,
                                  radius: 10,
                                ),
                              ],
                            ),
                            6.h,
                            const ShimmerBox(width: 120, height: 11, radius: 5),
                            10.h,
                            Row(
                              children: [
                                const ShimmerBox(
                                  width: 13,
                                  height: 13,
                                  radius: 3,
                                ),
                                6.w,
                                const ShimmerBox(
                                  width: 150,
                                  height: 11,
                                  radius: 5,
                                ).expand(),
                                const ShimmerBox(
                                  width: 16,
                                  height: 16,
                                  radius: 4,
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
        ],
      ),
    );
  }
}

class _PastListShimmer extends StatelessWidget {
  const _PastListShimmer({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const .fromLTRB(
        AppSizes.pagePadding,
        4,
        AppSizes.pagePadding,
        110,
      ),
      itemCount: count,
      separatorBuilder: (_, _) => 12.h,
      itemBuilder: (_, _) => const _PastTileShimmer(),
    );
  }
}

class _PastTileShimmer extends StatelessWidget {
  const _PastTileShimmer();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.outline),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Padding(
            padding: const .fromLTRB(14, 14, 14, 12),
            child: Row(
              crossAxisAlignment: .start,
              children: [
                const ShimmerBox(width: 64, height: 64, radius: 12),
                12.w,
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      const ShimmerBox(width: 170, height: 14, radius: 7),
                      8.h,
                      const ShimmerBox(width: 120, height: 11, radius: 5),
                      6.h,
                      const ShimmerBox(width: 150, height: 11, radius: 5),
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
                const ShimmerBox(width: 100, height: 14, radius: 7).center().expand(),
                const VerticalDivider(width: 1, color: AppColors.outline),
                const ShimmerBox(width: 72, height: 14, radius: 7).center().expand(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
