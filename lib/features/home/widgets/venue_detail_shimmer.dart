import 'package:material_ui/material_ui.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/widgets/app_shimmer.dart';

class VenueCourtsShimmer extends StatelessWidget {
  const VenueCourtsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        const ShimmerBox(width: 88, height: 18, radius: 8),
        12.h,
        const _CourtBone(),
        8.h,
        const _CourtBone(),
      ],
    ).shimmer();
  }
}

class VenueReviewsPreviewShimmer extends StatelessWidget {
  const VenueReviewsPreviewShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        const ShimmerBox(width: 96, height: 18, radius: 8),
        12.h,
        const _ReviewBone(),
        10.h,
        const _ReviewBone(),
      ],
    ).shimmer();
  }
}

class VenueReviewsListShimmer extends StatelessWidget {
  const VenueReviewsListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const .fromLTRB(20, 8, 20, 28),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        const ShimmerBox(width: double.infinity, height: 88, radius: 18),
        12.h,
        const _ReviewBone(),
        12.h,
        const _ReviewBone(),
        12.h,
        const _ReviewBone(),
        12.h,
        const _ReviewBone(),
      ],
    ).shimmer();
  }
}

class SlotGridShimmer extends StatelessWidget {
  const SlotGridShimmer({super.key, this.count = 6});

  final int count;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        mainAxisExtent: 112,
      ),
      itemBuilder: (_, _) => DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.outline),
        ),
      ),
    ).shimmer();
  }
}

class _CourtBone extends StatelessWidget {
  const _CourtBone();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          const ShimmerBox(width: 56, height: 56, radius: 12),
          12.w,
          Column(
            crossAxisAlignment: .start,
            children: [
              const ShimmerBox(width: 120, height: 14, radius: 7),
              8.h,
              const ShimmerBox(width: 160, height: 11, radius: 6),
            ],
          ).expand(),
          const ShimmerBox(width: 64, height: 32, radius: 10),
        ],
      ).paddingAll(14),
    );
  }
}

class _ReviewBone extends StatelessWidget {
  const _ReviewBone();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              const ShimmerBox(width: 36, height: 36, radius: 18),
              10.w,
              Column(
                crossAxisAlignment: .start,
                children: [
                  const ShimmerBox(width: 110, height: 12, radius: 6),
                  6.h,
                  const ShimmerBox(width: 72, height: 10, radius: 5),
                ],
              ).expand(),
              const ShimmerBox(width: 48, height: 14, radius: 7),
            ],
          ),
          12.h,
          const ShimmerBox(width: double.infinity, height: 11, radius: 6),
          6.h,
          const ShimmerBox(width: 220, height: 11, radius: 6),
        ],
      ).paddingAll(14),
    );
  }
}
