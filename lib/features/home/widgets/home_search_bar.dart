import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    super.key,
    required this.onSearchTap,
    required this.onFilter,
    this.hint = 'Search venue, sport or area',
  });

  final VoidCallback onSearchTap;
  final VoidCallback onFilter;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: AppSizes.searchHeight,
          child: Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            child: InkWell(
              onTap: onSearchTap,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Row(
                  children: [
                    14.w,
                    const Icon(
                      Icons.search_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    10.w,
                    Text(
                      hint,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    ).expand(),
                  ],
                ),
              ),
            ),
          ),
        ).expand(),
        10.w,
        SizedBox(
          width: AppSizes.searchHeight,
          height: AppSizes.searchHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: AppColors.accent,
            ).center(),
          ),
        ).onTap(onFilter),
      ],
    );
  }
}
