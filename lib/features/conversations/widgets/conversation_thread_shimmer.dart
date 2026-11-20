import 'package:material_ui/material_ui.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/widgets/app_shimmer.dart';

/// Skeleton that matches [_ThreadTile]: avatar, two text lines, time.
class ConversationThreadShimmer extends StatelessWidget {
  const ConversationThreadShimmer({super.key, this.count = 6});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const .fromLTRB(
        AppSizes.pagePadding,
        8,
        AppSizes.pagePadding,
        110,
      ),
      itemCount: count,
      separatorBuilder: (_, _) => 10.h,
      itemBuilder: (_, _) => const _ThreadTileShimmer(),
    ).shimmer();
  }
}

class _ThreadTileShimmer extends StatelessWidget {
  const _ThreadTileShimmer();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const .fromLTRB(12, 12, 14, 12),
        child: Row(
          children: [
            const ShimmerBox(width: 48, height: 48, radius: 24),
            12.w,
            Column(
              crossAxisAlignment: .start,
              children: [
                const ShimmerBox(width: 148, height: 14, radius: 7),
                8.h,
                const ShimmerBox(width: 196, height: 12, radius: 6),
              ],
            ).expand(),
            8.w,
            Column(
              crossAxisAlignment: .end,
              children: [
                const ShimmerBox(width: 36, height: 10, radius: 5),
                10.h,
                const ShimmerBox(width: 22, height: 22, radius: 11),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
