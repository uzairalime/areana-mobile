import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/utils/app_haptics.dart';
import '../model/sport_game.dart';

class SportGameGrid extends StatelessWidget {
  const SportGameGrid({
    super.key,
    required this.sports,
    required this.selectedId,
    required this.onSelected,
  });

  final List<SportGame> sports;
  final String selectedId;
  final ValueChanged<SportGame> onSelected;

  @override
  Widget build(BuildContext context) {
    final items = sports.isEmpty ? SportGame.defaults : sports;

    return Column(
      crossAxisAlignment: .start,
      children: [
        Text('Choose your game', style: context.textTheme.titleMedium),
        AppSizes.spaceSm.h,
        SizedBox(
          height: 108,
          child: ListView.separated(
            scrollDirection: .horizontal,
            itemCount: items.length,
            separatorBuilder: (_, _) => 8.w,
            itemBuilder: (context, index) {
              final sport = items[index];
              return _SportTile(
                sport: sport,
                selected: sport.id == selectedId,
                onTap: () {
                  AppHaptics.selection();
                  onSelected(sport);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SportTile extends StatelessWidget {
  const _SportTile({
    required this.sport,
    required this.selected,
    required this.onTap,
  });

  final SportGame sport;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Ink(
          width: 86,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.outline,
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: .center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: sport.background,
                  shape: .circle,
                ),
                child: Icon(sport.icon, color: sport.foreground, size: 22),
              ),
              8.h,
              Text(
                sport.label,
                textAlign: .center,
                maxLines: 2,
                overflow: .ellipsis,
                style: context.textTheme.labelMedium?.copyWith(
                  fontSize: 12,
                  fontWeight: .w700,
                  height: 1.15,
                  color: AppColors.text,
                ),
              ).paddingSymmetric(horizontal: 6),
            ],
          ).paddingSymmetric(vertical: 12),
        ),
      ),
    );
  }
}
