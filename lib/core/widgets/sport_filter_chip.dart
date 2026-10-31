import 'package:flutter/material.dart';

import '../consts/app_colors.dart';
import '../consts/app_sizes.dart';
import '../extensions/extensions.dart';
import '../utils/app_haptics.dart';
import '../../features/home/model/sport_game.dart';

/// Reusable sport chip with type icon (edit profile, explore, filters).
class SportFilterChip extends StatelessWidget {
  const SportFilterChip({
    super.key,
    required this.sport,
    required this.selected,
    required this.onTap,
    this.dense = false,
    this.selectedForeground = AppColors.onPrimary,
  });

  final SportGame sport;
  final bool selected;
  final VoidCallback onTap;
  final bool dense;

  /// Text/icon color when selected (edit profile: white, explore: accent).
  final Color selectedForeground;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? selectedForeground : AppColors.text;
    final bg = selected ? AppColors.primary : AppColors.surface;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      child: InkWell(
        onTap: () {
          AppHaptics.selection();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.outline,
            ),
          ),
          child: Row(
            mainAxisSize: .min,
            children: [
              Icon(sport.icon, size: dense ? 15 : 16, color: fg),
              6.w,
              Text(
                sport.label,
                style: context.textTheme.labelLarge?.copyWith(
                  color: fg,
                  fontWeight: .w700,
                  fontSize: dense ? 12 : 13,
                ),
              ),
            ],
          ).paddingSymmetric(
            horizontal: dense ? 12 : 14,
            vertical: dense ? 8 : 10,
          ),
        ),
      ),
    );
  }
}
