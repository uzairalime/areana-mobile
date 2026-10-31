import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/widgets/labels_builder.dart';
import '../../../core/widgets/sport_filter_chip.dart';
import '../../home/model/sport_game.dart';
import '../model/explore_models.dart';

class ExploreHeader extends StatelessWidget {
  const ExploreHeader({
    super.key,
    required this.search,
    required this.pageTab,
    required this.selectedSportId,
    required this.onSearchTap,
    required this.onFilterTap,
    required this.onPageTabChanged,
    required this.onSportSelected,
    this.onClearSearch,
  });

  final ExploreSearchCriteria search;
  final ExplorePageTab pageTab;
  final String? selectedSportId;
  final VoidCallback onSearchTap;
  final VoidCallback onFilterTap;
  final ValueChanged<ExplorePageTab> onPageTabChanged;
  final ValueChanged<String?> onSportSelected;

  /// Explicit clear only — never tied to Courts/Map or sport chips.
  final VoidCallback? onClearSearch;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Row(
          children: [
            Expanded(
              child: Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: onSearchTap,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusPill,
                          ),
                          child: Padding(
                            padding: const .fromLTRB(14, 12, 8, 12),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.search_rounded,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                                8.w,
                                Text(
                                  search.hasLocation
                                      ? search.pillSummary
                                      : 'Search city, area or arena',
                                  maxLines: 1,
                                  overflow: .ellipsis,
                                  style: context.textTheme.labelLarge?.copyWith(
                                    fontWeight:
                                        search.hasLocation ? .w700 : .w500,
                                    fontSize: 13,
                                    color: search.hasLocation
                                        ? AppColors.text
                                        : AppColors.textSecondary,
                                  ),
                                ).expand(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (search.hasLocation && onClearSearch != null)
                        IconButton(
                          onPressed: onClearSearch,
                          tooltip: 'Clear search',
                          visualDensity: .compact,
                          padding: const .only(right: 6),
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            8.w,
            const SizedBox(
              width: 44,
              height: 44,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: .circle,
                ),
                child: Icon(
                  Icons.tune_rounded,
                  color: AppColors.accent,
                  size: 20,
                ),
              ),
            ).onTap(onFilterTap),
          ],
        ),
        12.h,
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: .horizontal,
            itemCount: SportGame.defaults.length,
            separatorBuilder: (_, _) => 8.w,
            itemBuilder: (context, index) {
              final sport = SportGame.defaults[index];
              final selected = sport.isAll
                  ? selectedSportId == null
                  : selectedSportId == sport.id;
              return SportFilterChip(
                sport: sport,
                selected: selected,
                dense: true,
                selectedForeground: AppColors.accent,
                onTap: () => onSportSelected(sport.isAll ? null : sport.id),
              );
            },
          ),
        ),
        12.h,
        BuildLabels<ExplorePageTab>(
          expanded: true,
          labels: ExplorePageTab.values,
          label: pageTab,
          textOf: (value) => value.label,
          itemHorizontalPadding: 18,
          onChange: onPageTabChanged,
        ),
      ],
    );
  }
}
