import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/widgets/app_shimmer.dart';

/// Skeleton that mirrors [PickSlotScreen] (hero → sheet sections → sticky CTA).
class PickSlotShimmer extends StatelessWidget {
  const PickSlotShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              physics: const NeverScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      const ShimmerBox(
                        width: double.infinity,
                        height: 210,
                        radius: 0,
                      ).shimmer(),
                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const .all(16),
                          child: Row(
                            children: [
                              const _HeaderCircle(),
                              const Spacer(),
                              const _HeaderCircle(),
                              8.w,
                              const _HeaderCircle(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -26),
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(26),
                        ),
                      ),
                      child: Padding(
                        padding: const .fromLTRB(20, 22, 20, 28),
                        child: Column(
                          crossAxisAlignment: .start,
                          children: [
                            // Sport / pay chips
                            Row(
                              children: [
                                const ShimmerBox(
                                  width: 64,
                                  height: 26,
                                  radius: 999,
                                ),
                                8.w,
                                const ShimmerBox(
                                  width: 148,
                                  height: 26,
                                  radius: 999,
                                ),
                              ],
                            ),
                            12.h,
                            // Venue title
                            const ShimmerBox(
                              width: 240,
                              height: 28,
                              radius: 10,
                            ),
                            10.h,
                            // Location
                            const ShimmerBox(
                              width: 170,
                              height: 14,
                              radius: 7,
                            ),
                            14.h,
                            // Amenities
                            Row(
                              children: [
                                const ShimmerBox(
                                  width: 72,
                                  height: 28,
                                  radius: 999,
                                ),
                                8.w,
                                const ShimmerBox(
                                  width: 88,
                                  height: 28,
                                  radius: 999,
                                ),
                                8.w,
                                const ShimmerBox(
                                  width: 64,
                                  height: 28,
                                  radius: 999,
                                ),
                              ],
                            ),
                            AppSizes.spaceLg.h,
                            // Pay-at-ground callout
                            const ShimmerBox(
                              width: double.infinity,
                              height: 78,
                              radius: AppSizes.radiusLg,
                            ),
                            AppSizes.spaceLg.h,
                            // Choose court
                            const ShimmerBox(width: 118, height: 17, radius: 8),
                            10.h,
                            Row(
                              children: [
                                const _TileBone(height: 64).expand(),
                                10.w,
                                const _TileBone(height: 64).expand(),
                              ],
                            ),
                            AppSizes.spaceLg.h,
                            // Pick a date
                            const ShimmerBox(width: 108, height: 17, radius: 8),
                            10.h,
                            SizedBox(
                              height: 80,
                              child: Row(
                                children: [
                                  for (var i = 0; i < 5; i++) ...[
                                    if (i > 0) 8.w,
                                    const _TileBone(
                                      width: 64,
                                      height: 80,
                                      radius: AppSizes.radiusLg,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            AppSizes.spaceLg.h,
                            // Duration
                            const ShimmerBox(width: 86, height: 17, radius: 8),
                            10.h,
                            const _TileBone(
                              width: double.infinity,
                              height: 52,
                              radius: AppSizes.radiusMd,
                            ),
                            AppSizes.spaceLg.h,
                            // Available slots header + legend
                            Row(
                              children: [
                                const ShimmerBox(
                                  width: 132,
                                  height: 17,
                                  radius: 8,
                                ).expand(),
                                const ShimmerBox(
                                  width: 36,
                                  height: 10,
                                  radius: 5,
                                ),
                                8.w,
                                const ShimmerBox(
                                  width: 36,
                                  height: 10,
                                  radius: 5,
                                ),
                                8.w,
                                const ShimmerBox(
                                  width: 44,
                                  height: 10,
                                  radius: 5,
                                ),
                              ],
                            ),
                            10.h,
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 3,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 1.35,
                              children: const [
                                _TileBone(),
                                _TileBone(),
                                _TileBone(),
                                _TileBone(),
                                _TileBone(),
                                _TileBone(),
                              ],
                            ),
                          ],
                        ).shimmer(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Matches disabled [BookingStickyBar] full-width CTA.
          DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.outline)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const .fromLTRB(20, 12, 20, 18),
                child: const ShimmerBox(
                  width: double.infinity,
                  height: AppSizes.buttonHeight,
                  radius: AppSizes.radiusMd,
                ).shimmer(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCircle extends StatelessWidget {
  const _HeaderCircle();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.94),
        shape: .circle,
      ),
      child: const SizedBox(width: 44, height: 44),
    );
  }
}

class _TileBone extends StatelessWidget {
  const _TileBone({
    this.width,
    this.height,
    this.radius = AppSizes.radiusMd,
  });

  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
