import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import 'home_search_bar.dart';

class HomeStickySearchDelegate extends SliverPersistentHeaderDelegate {
  HomeStickySearchDelegate({
    required this.onSearchTap,
    required this.onFilter,
  });

  final VoidCallback onSearchTap;
  final VoidCallback onFilter;

  static const double _top = 8;
  static const double _bottom = 12;

  @override
  double get minExtent => AppSizes.searchHeight + _top + _bottom;

  @override
  double get maxExtent => AppSizes.searchHeight + _top + _bottom;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final elevated = overlapsContent || shrinkOffset > 0.5;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: elevated
            ? const [
                BoxShadow(
                  color: Color(0x140D1B14),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
        border: elevated
            ? const Border(bottom: BorderSide(color: AppColors.outline))
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.pagePadding,
          _top,
          AppSizes.pagePadding,
          _bottom,
        ),
        child: HomeSearchBar(
          onSearchTap: onSearchTap,
          onFilter: onFilter,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant HomeStickySearchDelegate oldDelegate) {
    return oldDelegate.onSearchTap != onSearchTap ||
        oldDelegate.onFilter != onFilter;
  }
}
