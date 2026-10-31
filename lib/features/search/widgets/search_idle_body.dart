import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/services/recent_search_store.dart';
import '../../../core/utils/app_haptics.dart';
import '../model/search_models.dart';

/// ReelStay-style idle surface: Near me + last [RecentSearchStore.maxItems].
class SearchIdleBody extends StatelessWidget {
  const SearchIdleBody({
    super.key,
    required this.recents,
    required this.onNearby,
    required this.onRecentTap,
    required this.onRecentRemove,
    required this.onClearRecents,
    this.nearbyLoading = false,
  });

  final List<String> recents;
  final VoidCallback onNearby;
  final ValueChanged<String> onRecentTap;
  final ValueChanged<String> onRecentRemove;
  final VoidCallback onClearRecents;
  final bool nearbyLoading;

  @override
  Widget build(BuildContext context) {
    return ListView(
      keyboardDismissBehavior: .onDrag,
      padding: const .fromLTRB(
        AppSizes.pagePadding,
        8,
        AppSizes.pagePadding,
        28,
      ),
      children: [
        _SuggestionTile(
          icon: Icons.near_me_rounded,
          iconBg: AppColors.primarySoft,
          iconColor: AppColors.primary,
          title: PlaceSuggestion.nearby.primaryText,
          subtitle: PlaceSuggestion.nearby.secondaryText,
          trailing: nearbyLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
          onTap: nearbyLoading ? null : onNearby,
        ),
        if (recents.isNotEmpty) ...[
          18.h,
          Row(
            children: [
              Text(
                'Recent searches',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: .w800,
                ),
              ).expand(),
              TextButton(
                onPressed: () {
                  AppHaptics.selection();
                  onClearRecents();
                },
                style: TextButton.styleFrom(
                  visualDensity: .compact,
                  padding: const .symmetric(horizontal: 8),
                ),
                child: Text(
                  'Clear',
                  style: context.textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: .w700,
                  ),
                ),
              ),
            ],
          ),
          4.h,
          for (final item in recents.take(RecentSearchStore.maxItems))
            _SuggestionTile(
              icon: Icons.history_rounded,
              iconBg: AppColors.accentSoft,
              iconColor: AppColors.payBadgeText,
              title: item,
              subtitle: 'Recent search',
              trailing: IconButton(
                onPressed: () {
                  AppHaptics.selection();
                  onRecentRemove(item);
                },
                tooltip: 'Remove',
                visualDensity: .compact,
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
              onTap: () {
                AppHaptics.selection();
                onRecentTap(item);
              },
            ),
        ] else ...[
          28.h,
          const Icon(
            Icons.search_rounded,
            size: 40,
            color: AppColors.primary,
          ).center(),
          12.h,
          Text(
            'Find a place or arena',
            textAlign: .center,
            style: context.textTheme.titleMedium?.copyWith(fontWeight: .w800),
          ),
          6.h,
          Text(
            'Type a city or area to filter Explore, or an arena name to open its card.',
            textAlign: .center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ).paddingSymmetric(horizontal: 24),
        ],
      ],
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: .zero,
      onTap: onTap == null
          ? null
          : () {
              AppHaptics.selection();
              onTap!();
            },
      leading: DecoratedBox(
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: const .all(Radius.circular(12)),
        ),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: iconColor, size: 20),
        ),
      ),
      title: Text(
        title,
        style: context.textTheme.titleSmall?.copyWith(fontWeight: .w700),
      ),
      subtitle: Text(
        subtitle,
        style: context.textTheme.labelMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: trailing,
    );
  }
}
