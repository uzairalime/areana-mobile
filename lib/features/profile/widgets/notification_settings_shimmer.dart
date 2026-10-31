import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/widgets/app_shimmer.dart';

/// Skeleton matching notification settings (section + toggle cards).
class NotificationSettingsShimmer extends StatelessWidget {
  const NotificationSettingsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const .fromLTRB(20, 8, 20, 28),
      children: [
        const ShimmerBox(width: 150, height: 18, radius: 8),
        8.h,
        const ShimmerBox(width: 200, height: 12, radius: 6),
        10.h,
        const _ToggleCardShimmer(rows: 3),
        22.h,
        const ShimmerBox(width: 64, height: 18, radius: 8),
        8.h,
        const ShimmerBox(width: 190, height: 12, radius: 6),
        10.h,
        const _ToggleCardShimmer(rows: 2),
      ],
    ).shimmer();
  }
}

class _ToggleCardShimmer extends StatelessWidget {
  const _ToggleCardShimmer({required this.rows});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: const BorderSide(color: AppColors.outline),
      ),
      clipBehavior: .antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < rows; i++) ...[
            Padding(
              padding: const .fromLTRB(14, 16, 14, 16),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: .start,
                    children: [
                      const ShimmerBox(width: 140, height: 14, radius: 7),
                      8.h,
                      const ShimmerBox(width: 180, height: 11, radius: 6),
                    ],
                  ).expand(),
                  12.w,
                  const ShimmerBox(width: 48, height: 28, radius: 14),
                ],
              ),
            ),
            if (i < rows - 1)
              const Divider(height: 1, color: AppColors.outline),
          ],
        ],
      ),
    );
  }
}
