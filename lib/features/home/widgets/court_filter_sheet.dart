import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/utils/money_format.dart';
import '../../../core/widgets/app_button.dart';
import '../model/court_filter.dart';
import '../model/sport_game.dart';

Future<CourtFilterDraft?> showCourtFilterSheet(
  BuildContext context, {
  CourtFilterDraft initial = const CourtFilterDraft(),
}) {
  AppHaptics.light();
  return showModalBottomSheet<CourtFilterDraft>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.scrim.withValues(alpha: 0.42),
    builder: (_) => CourtFilterSheet(initial: initial),
  );
}

class CourtFilterSheet extends StatefulWidget {
  const CourtFilterSheet({super.key, this.initial = const CourtFilterDraft()});

  final CourtFilterDraft initial;

  @override
  State<CourtFilterSheet> createState() => _CourtFilterSheetState();
}

class _CourtFilterSheetState extends State<CourtFilterSheet> {
  late CourtFilterDraft _draft = widget.initial;

  void _set(CourtFilterDraft next) => setState(() => _draft = next);

  void _apply() {
    AppHaptics.medium();
    Navigator.of(context).pop(_draft);
  }

  void _clear() {
    AppHaptics.selection();
    Navigator.of(context).pop(const CourtFilterDraft());
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    const radius = BorderRadius.vertical(top: Radius.circular(28));

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border(
              top: BorderSide(color: AppColors.outline.withValues(alpha: 0.9)),
            ),
            gradient: LinearGradient(
              begin: .topCenter,
              end: .bottomCenter,
              colors: [
                AppColors.surface.withValues(alpha: 0.96),
                AppColors.surface.withValues(alpha: 0.92),
              ],
            ),
          ),
          child: SizedBox(
            height: height * 0.88,
            child: Column(
              children: [
                const _Handle(),
                Padding(
                  padding: const .fromLTRB(20, 4, 20, 8),
                  child: Align(
                    alignment: .centerLeft,
                    child: Text(
                      'Find your court',
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontSize: 24,
                        fontWeight: .w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const .only(bottom: 12),
                    children: [
                      _SortSection(
                        selected: _draft.sort,
                        onSelected: (sort) => _set(_draft.copyWith(sort: sort)),
                      ),
                      _SportsSection(
                        selectedId: _draft.sportId,
                        onSelected: (id) => _set(_draft.toggleSport(id)),
                      ),
                      _LocationsSection(
                        selectedId: _draft.areaId,
                        onSelected: (id) => _set(_draft.toggleArea(id)),
                      ),
                      _BudgetSection(
                        range: _draft.priceRange,
                        onChanged: (values) =>
                            _set(_draft.withPriceRange(values)),
                        onReset: () => _set(
                          _draft.copyWith(
                            minPrice: CourtFilterPresets.priceMin,
                            maxPrice: CourtFilterPresets.priceMax,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _Footer(onApply: _apply, onClear: _clear),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        ),
        child: const SizedBox(width: 44, height: 5),
      ),
    ).paddingOnly(top: 12, bottom: 8);
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title, {this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .fromLTRB(20, 22, 20, 10),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: context.textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: .w700,
              fontSize: 12,
              letterSpacing: 0.7,
            ),
          ).expand(),
          if (action != null)
            Text(
              action!,
              style: context.textTheme.labelLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: .w700,
                fontSize: 13,
              ),
            ).onTap(onAction),
        ],
      ),
    );
  }
}

class _SortSection extends StatelessWidget {
  const _SortSection({required this.selected, required this.onSelected});

  final CourtSortOption selected;
  final ValueChanged<CourtSortOption> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        const _SectionLabel('Sort by signal'),
        Padding(
          padding: const .symmetric(horizontal: 20),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in CourtFilterPresets.sortOptions)
                _FilterChip(
                  label: option.label,
                  selected: selected == option,
                  onTap: () {
                    AppHaptics.selection();
                    onSelected(option);
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SportsSection extends StatelessWidget {
  const _SportsSection({required this.selectedId, required this.onSelected});

  final String? selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final sports = CourtFilterPresets.sports;
    return Column(
      crossAxisAlignment: .start,
      children: [
        const _SectionLabel('Sports'),
        SizedBox(
          height: 128,
          child: ListView.separated(
            scrollDirection: .horizontal,
            padding: const .symmetric(horizontal: 20),
            itemCount: sports.length,
            separatorBuilder: (_, _) => 10.w,
            itemBuilder: (context, index) {
              final sport = sports[index];
              return _SportCard(
                sport: sport,
                selected: selectedId == sport.id,
                onTap: () {
                  AppHaptics.selection();
                  onSelected(sport.id);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SportCard extends StatelessWidget {
  const _SportCard({
    required this.sport,
    required this.selected,
    required this.onTap,
  });

  final SportGame sport;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      child: Material(
        color: sport.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const .all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(
                color: selected ? sport.foreground : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(sport.icon, color: sport.foreground, size: 22),
                  ),
                ),
                const Spacer(),
                Text(
                  sport.label,
                  maxLines: 2,
                  overflow: .ellipsis,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: sport.foreground,
                    fontWeight: .w800,
                    fontSize: 13,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationsSection extends StatelessWidget {
  const _LocationsSection({
    required this.selectedId,
    required this.onSelected,
  });

  final String? selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final areas = CourtFilterPresets.areas;
    return Column(
      crossAxisAlignment: .start,
      children: [
        const _SectionLabel('Locations'),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: .horizontal,
            padding: const .symmetric(horizontal: 20),
            itemCount: areas.length,
            separatorBuilder: (_, _) => 8.w,
            itemBuilder: (context, index) {
              final area = areas[index];
              return _FilterChip(
                label: area.label,
                icon: area.icon,
                selected: selectedId == area.id,
                onTap: () {
                  AppHaptics.selection();
                  onSelected(area.id);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BudgetSection extends StatelessWidget {
  const _BudgetSection({
    required this.range,
    required this.onChanged,
    required this.onReset,
  });

  final RangeValues range;
  final ValueChanged<RangeValues> onChanged;
  final VoidCallback onReset;

  bool get _isDefault =>
      range.start <= CourtFilterPresets.priceMin &&
      range.end >= CourtFilterPresets.priceMax;

  @override
  Widget build(BuildContext context) {
    final minLabel = MoneyFormat.pkr(range.start.round());
    final maxLabel = MoneyFormat.pkr(range.end.round());

    return Column(
      crossAxisAlignment: .start,
      children: [
        _SectionLabel(
          'Budget',
          action: _isDefault ? null : 'Reset',
          onAction: _isDefault
              ? null
              : () {
                  AppHaptics.selection();
                  onReset();
                },
        ),
        Padding(
          padding: const .symmetric(horizontal: 20),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(color: AppColors.outline),
            ),
            child: Padding(
              padding: const .fromLTRB(16, 16, 16, 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      _PricePill(label: 'Min', value: minLabel).expand(),
                      10.w,
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: AppColors.textDisabled,
                      ),
                      10.w,
                      _PricePill(label: 'Max', value: maxLabel).expand(),
                    ],
                  ),
                  8.h,
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: AppColors.track,
                      thumbColor: AppColors.accent,
                      overlayColor: AppColors.primary.withValues(alpha: 0.12),
                      rangeThumbShape: const RoundRangeSliderThumbShape(
                        enabledThumbRadius: 11,
                        elevation: 2,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 18,
                      ),
                      trackHeight: 4,
                      rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
                      valueIndicatorColor: AppColors.primary,
                      valueIndicatorTextStyle: context.textTheme.labelMedium
                          ?.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: .w700,
                          ),
                      showValueIndicator: .never,
                    ),
                    child: RangeSlider(
                      values: RangeValues(
                        range.start.clamp(
                          CourtFilterPresets.priceMin.toDouble(),
                          CourtFilterPresets.priceMax.toDouble(),
                        ),
                        range.end.clamp(
                          CourtFilterPresets.priceMin.toDouble(),
                          CourtFilterPresets.priceMax.toDouble(),
                        ),
                      ),
                      min: CourtFilterPresets.priceMin.toDouble(),
                      max: CourtFilterPresets.priceMax.toDouble(),
                      divisions: CourtFilterPresets.priceDivisions,
                      onChanged: (values) {
                        if ((values.start - range.start).abs() >= 1 ||
                            (values.end - range.end).abs() >= 1) {
                          AppHaptics.selection();
                        }
                        onChanged(values);
                      },
                    ),
                  ),
                  Padding(
                    padding: const .symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        Text(
                          MoneyFormat.pkr(CourtFilterPresets.priceMin),
                          style: context.textTheme.labelSmall?.copyWith(
                            color: AppColors.textDisabled,
                            fontWeight: .w600,
                          ),
                        ).expand(),
                        Text(
                          MoneyFormat.pkr(CourtFilterPresets.priceMax),
                          style: context.textTheme.labelSmall?.copyWith(
                            color: AppColors.textDisabled,
                            fontWeight: .w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  8.h,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PricePill extends StatelessWidget {
  const _PricePill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const .symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: .w700,
                letterSpacing: 0.3,
              ),
            ),
            4.h,
            Text(
              value,
              maxLines: 1,
              overflow: .ellipsis,
              style: context.textTheme.titleSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: .w800,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.onPrimary : AppColors.text;

    return Material(
      color: selected ? AppColors.primary : AppColors.track,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const .symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: .min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: fg),
                6.w,
              ],
              Text(
                label,
                maxLines: 1,
                overflow: .ellipsis,
                style: context.textTheme.labelLarge?.copyWith(
                  color: fg,
                  fontWeight: selected ? .w700 : .w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.onApply, required this.onClear});

  final VoidCallback onApply;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const .fromLTRB(20, 8, 20, 12),
        child: Column(
          mainAxisSize: .min,
          children: [
            AppButton(
              label: 'Show courts',
              showArrow: false,
              onPressed: onApply,
            ),
            TextButton(
              onPressed: onClear,
              child: Text(
                'Clear All',
                style: context.textTheme.labelLarge?.copyWith(
                  color: AppColors.textBody,
                  fontWeight: .w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
