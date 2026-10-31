import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/widgets/app_shimmer.dart';
import 'profile_sliver_header.dart';

/// Loading skeleton for the profile hub.
///
/// Keeps structural chrome (green hero + white card shells) so layout matches
/// the real screen — but bones stay neutral white/gray. Never paints brand
/// accent fills that make loading look like a broken colored UI.
class ProfileHubShimmer extends StatelessWidget {
  const ProfileHubShimmer({super.key});

  static const _heroBone = Color(0x3DFFFFFF);
  static const _heroBoneStrong = Color(0x52FFFFFF);
  static const _statsPanel = Color(0xFF0A2F22);
  static const _heroShimmerBase = Color(0x33FFFFFF);
  static const _heroShimmerHighlight = Color(0x66FFFFFF);

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: .light,
      child: ColoredBox(
        color: AppColors.background,
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            ColoredBox(
              color: AppColors.primary,
              child: SizedBox(
                height: topInset + ProfileHeaderDelegate.expandedBodyHeight,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, topInset + 8, 20, 24),
                  child: AppShimmer(
                    baseColor: _heroShimmerBase,
                    highlightColor: _heroShimmerHighlight,
                    child: Column(
                      crossAxisAlignment: .stretch,
                      children: [
                        Row(
                          children: [
                            const ShimmerBox(
                              width: 96,
                              height: 26,
                              radius: 8,
                              color: _heroBoneStrong,
                            ).expand(),
                            const ShimmerBox(
                              width: 42,
                              height: 42,
                              radius: 21,
                              color: _heroBone,
                            ),
                          ],
                        ),
                        20.h,
                        Row(
                          children: [
                            const ShimmerBox(
                              width: 74,
                              height: 74,
                              radius: 37,
                              color: _heroBoneStrong,
                            ),
                            14.w,
                            Column(
                              crossAxisAlignment: .start,
                              children: [
                                const ShimmerBox(
                                  width: 148,
                                  height: 20,
                                  radius: 8,
                                  color: _heroBoneStrong,
                                ),
                                8.h,
                                const ShimmerBox(
                                  width: 168,
                                  height: 12,
                                  radius: 6,
                                  color: _heroBone,
                                ),
                                10.h,
                                const ShimmerBox(
                                  width: 120,
                                  height: 22,
                                  radius: 999,
                                  color: _heroBone,
                                ),
                              ],
                            ).expand(),
                          ],
                        ),
                        16.h,
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: _statsPanel,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Padding(
                            padding: const .symmetric(
                              vertical: 16,
                              horizontal: 8,
                            ),
                            child: Row(
                              children: [
                                for (var i = 0; i < 3; i++)
                                  const Column(
                                    children: [
                                      ShimmerBox(
                                        width: 36,
                                        height: 20,
                                        radius: 8,
                                        color: _heroBoneStrong,
                                      ),
                                      SizedBox(height: 6),
                                      ShimmerBox(
                                        width: 52,
                                        height: 10,
                                        radius: 5,
                                        color: _heroBone,
                                      ),
                                    ],
                                  ).expand(),
                              ],
                            ),
                          ),
                        ),
                        14.h,
                        Row(
                          spacing: 12,
                          children: [
                            const ShimmerBox(
                              height: 48,
                              radius: 14,
                              color: _heroBoneStrong,
                            ).expand(),
                            const ShimmerBox(
                              height: 48,
                              radius: 14,
                              color: _heroBone,
                            ).expand(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: AppShimmer(
                child: ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const .fromLTRB(20, 22, 20, 110),
                  children: [
                    const ShimmerBox(width: 72, height: 16, radius: 8),
                    10.h,
                    const _MenuCardShimmer(rows: 4),
                    22.h,
                    const ShimmerBox(width: 68, height: 16, radius: 8),
                    10.h,
                    const _MenuCardShimmer(rows: 4),
                    22.h,
                    const ShimmerBox(width: 80, height: 16, radius: 8),
                    10.h,
                    const _MenuCardShimmer(rows: 2),
                    16.h,
                    const _MenuCardShimmer(rows: 2),
                    16.h,
                    const ShimmerBox(
                      width: 140,
                      height: 12,
                      radius: 6,
                    ).center(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCardShimmer extends StatelessWidget {
  const _MenuCardShimmer({required this.rows});

  final int rows;

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
          for (var i = 0; i < rows; i++) ...[
            Padding(
              padding: const .symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  const ShimmerBox(width: 22, height: 22, radius: 6),
                  12.w,
                  const ShimmerBox(
                    width: 140,
                    height: 14,
                    radius: 7,
                  ).expand(),
                  const ShimmerBox(width: 16, height: 16, radius: 4),
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
