import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/widgets/app_shimmer.dart';

class NotificationListShimmer extends StatelessWidget {
  const NotificationListShimmer({super.key, this.count = 6});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const .fromLTRB(
        AppSizes.pagePadding,
        8,
        AppSizes.pagePadding,
        32,
      ),
      itemCount: count,
      separatorBuilder: (_, _) => 10.h,
      itemBuilder: (context, index) {
        if (index == 0 || index == 3) {
          return Column(
            crossAxisAlignment: .start,
            children: [
              const ShimmerBox(width: 64, height: 12, radius: 6),
              10.h,
              const _TileShimmer(),
            ],
          );
        }
        return const _TileShimmer();
      },
    ).shimmer();
  }
}

class _TileShimmer extends StatelessWidget {
  const _TileShimmer();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outline),
      ),
      child: Padding(
        padding: const .fromLTRB(14, 14, 12, 14),
        child: Row(
          crossAxisAlignment: .start,
          children: [
            const ShimmerBox(width: 44, height: 44, radius: 22),
            12.w,
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  const ShimmerBox(width: 150, height: 14, radius: 7),
                  8.h,
                  const ShimmerBox(width: 260, height: 11, radius: 5),
                  6.h,
                  const ShimmerBox(width: 200, height: 11, radius: 5),
                  8.h,
                  const ShimmerBox(width: 56, height: 10, radius: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
