import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/widgets/app_shimmer.dart';

class MessagesListShimmer extends StatelessWidget {
  const MessagesListShimmer({super.key, this.count = 5});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const .fromLTRB(
        AppSizes.pagePadding,
        8,
        AppSizes.pagePadding,
        110,
      ),
      itemCount: count,
      separatorBuilder: (_, _) => 10.h,
      itemBuilder: (_, _) => const _TileShimmer(),
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
        padding: const .all(14),
        child: Row(
          children: [
            const ShimmerBox(width: 48, height: 48, radius: 24),
            12.w,
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  const ShimmerBox(width: 160, height: 14, radius: 7),
                  8.h,
                  const ShimmerBox(width: 220, height: 11, radius: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
