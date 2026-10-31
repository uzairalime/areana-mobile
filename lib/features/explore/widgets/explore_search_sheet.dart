import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/utils/app_haptics.dart';
import '../model/explore_models.dart';

Future<ExploreSearchCriteria?> showExploreSearchSheet(
  BuildContext context, {
  required ExploreSearchCriteria initial,
}) {
  AppHaptics.light();
  return showModalBottomSheet<ExploreSearchCriteria>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.scrim.withValues(alpha: 0.45),
    builder: (_) => ExploreSearchSheet(initial: initial),
  );
}

class ExploreSearchSheet extends StatefulWidget {
  const ExploreSearchSheet({super.key, required this.initial});

  final ExploreSearchCriteria initial;

  @override
  State<ExploreSearchSheet> createState() => _ExploreSearchSheetState();
}

class _ExploreSearchSheetState extends State<ExploreSearchSheet> {
  late ExploreSearchCriteria _draft = widget.initial;
  ExploreSearchSection _open = .where;
  late final TextEditingController _locationController;

  static const _areas = [
    'Lahore, Pakistan',
    'Karachi, Pakistan',
    'Islamabad, Pakistan',
    'DHA, Lahore',
    'Gulberg, Lahore',
  ];

  static const _dates = [
    'Today',
    'Tomorrow',
    'This weekend',
    'Next week',
  ];

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(text: _draft.location);
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  void _openSection(ExploreSearchSection section) {
    AppHaptics.selection();
    setState(() => _open = section);
  }

  void _submit() {
    AppHaptics.medium();
    Navigator.of(context).pop(
      _draft.copyWith(location: _locationController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    const radius = BorderRadius.vertical(top: Radius.circular(28));

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.96),
            borderRadius: radius,
          ),
          child: SizedBox(
            height: height * 0.86,
            child: Column(
              children: [
                Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusPill,
                      ),
                    ),
                    child: const SizedBox(width: 44, height: 5),
                  ),
                ).paddingOnly(top: 12, bottom: 8),
                Expanded(
                  child: ListView(
                    padding: const .fromLTRB(16, 4, 16, 12),
                    children: [
                      _ExpandableCard(
                        title: 'Where',
                        summary: _draft.location,
                        expanded: _open == .where,
                        onTap: () => _openSection(.where),
                        child: _WhereBody(
                          controller: _locationController,
                          areas: _areas,
                          onPick: (value) {
                            _locationController.text = value;
                            setState(() {
                              _draft = _draft.copyWith(location: value);
                              _open = .when;
                            });
                          },
                        ),
                      ),
                      10.h,
                      _ExpandableCard(
                        title: 'When',
                        summary: _draft.dateLabel,
                        expanded: _open == .when,
                        onTap: () => _openSection(.when),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final date in _dates)
                              _ChoiceChip(
                                label: date,
                                selected: _draft.dateLabel == date,
                                onTap: () => setState(() {
                                  _draft = _draft.copyWith(dateLabel: date);
                                  _open = .who;
                                }),
                              ),
                          ],
                        ),
                      ),
                      10.h,
                      _ExpandableCard(
                        title: 'Who’s playing?',
                        summary: _draft.playersLabel,
                        expanded: _open == .who,
                        onTap: () => _openSection(.who),
                        child: Column(
                          children: [
                            _StepperRow(
                              title: 'Players',
                              subtitle: 'Including you',
                              value: _draft.players ?? 2,
                              onChanged: (value) => setState(
                                () => _draft = _draft.copyWith(players: value),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const .fromLTRB(20, 8, 20, 12),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            AppHaptics.selection();
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Back',
                            style: context.textTheme.labelLarge?.copyWith(
                              decoration: TextDecoration.underline,
                              fontWeight: .w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        FilledButton.icon(
                          onPressed: _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            minimumSize: const Size(0, 48),
                            padding: const .symmetric(horizontal: 22),
                            shape: const StadiumBorder(),
                          ),
                          icon: const Icon(
                            Icons.search_rounded,
                            color: AppColors.accent,
                            size: 18,
                          ),
                          label: Text(
                            'Search',
                            style: context.textTheme.labelLarge?.copyWith(
                              color: AppColors.onPrimary,
                              fontWeight: .w800,
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _ExpandableCard extends StatelessWidget {
  const _ExpandableCard({
    required this.title,
    required this.summary,
    required this.expanded,
    required this.onTap,
    required this.child,
  });

  final String title;
  final String summary;
  final bool expanded;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: expanded ? AppColors.primary : AppColors.outline,
          width: expanded ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: expanded ? 0.1 : 0.04),
            blurRadius: expanded ? 18 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: expanded ? null : onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: .all(expanded ? 18 : 16),
            child: expanded
                ? Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        title,
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontSize: 22,
                          fontWeight: .w800,
                        ),
                      ),
                      14.h,
                      child,
                    ],
                  )
                : Row(
                    children: [
                      Text(
                        title,
                        style: context.textTheme.labelLarge?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: .w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        summary,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: .w800,
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

class _WhereBody extends StatelessWidget {
  const _WhereBody({
    required this.controller,
    required this.areas,
    required this.onPick,
  });

  final TextEditingController controller;
  final List<String> areas;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'City, area or venue',
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        12.h,
        _SuggestionTile(
          icon: Icons.near_me_rounded,
          iconBg: AppColors.primarySoft,
          iconColor: AppColors.primary,
          title: 'Nearby',
          subtitle: 'Find courts around you',
          onTap: () => onPick('Nearby'),
        ),
        for (final area in areas)
          _SuggestionTile(
            icon: Icons.history_rounded,
            iconBg: AppColors.accentSoft,
            iconColor: AppColors.payBadgeText,
            title: area.split(',').first,
            subtitle: area,
            onTap: () => onPick(area),
          ),
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
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        AppHaptics.selection();
        onTap();
      },
      contentPadding: .zero,
      leading: DecoratedBox(
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: SizedBox(
          width: 42,
          height: 42,
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
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.track,
      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      child: InkWell(
        onTap: () {
          AppHaptics.selection();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        child: Text(
          label,
          style: context.textTheme.labelLarge?.copyWith(
            color: selected ? AppColors.onPrimary : AppColors.text,
            fontWeight: .w700,
          ),
        ).paddingSymmetric(horizontal: 14, vertical: 10),
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: .start,
          children: [
            Text(
              title,
              style: context.textTheme.titleSmall?.copyWith(fontWeight: .w800),
            ),
            2.h,
            Text(
              subtitle,
              style: context.textTheme.labelMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ).expand(),
        _RoundIcon(
          icon: Icons.remove,
          enabled: value > 1,
          onTap: () => onChanged(value - 1),
        ),
        SizedBox(
          width: 36,
          child: Text(
            '$value',
            textAlign: .center,
            style: context.textTheme.titleMedium?.copyWith(fontWeight: .w800),
          ),
        ),
        _RoundIcon(
          icon: Icons.add,
          enabled: value < 22,
          onTap: () => onChanged(value + 1),
        ),
      ],
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: .circle,
          border: Border.all(color: AppColors.border),
          color: AppColors.surface,
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppColors.text : AppColors.textDisabled,
        ),
      ),
    ).onTap(enabled ? () {
      AppHaptics.selection();
      onTap();
    } : null);
  }
}
