import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_icons.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/utils/money_format.dart';
import '../../../core/widgets/app_loading_handler.dart';
import '../cubit/booking_cubit.dart';
import '../cubit/booking_state.dart';
import '../model/time_slot.dart';
import '../widgets/booking_auth_sheet.dart';
import '../widgets/booking_sticky_bar.dart';
import '../widgets/court_hero_canvas.dart';
import '../widgets/pick_slot_shimmer.dart';

class PickSlotScreen extends StatelessWidget {
  const PickSlotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          final venue = state.venue;
          return AppLoadingHandler(
            status: state.status,
            errorMessage: state.errorMessage,
            loading: const PickSlotShimmer(),
            onRetry: venue == null
                ? null
                : () => context.read<BookingCubit>().start(venue),
            child: venue == null
                ? const SizedBox.shrink()
                : Column(
                    children: [
                      Expanded(
                        child: CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: _HeroHeader(
                                venueId: venue.id,
                                color: venue.heroColor,
                                onBack: () {
                                  AppHaptics.selection();
                                  context.pop();
                                },
                                onSave: () => showBookingAuthSheet(
                                  context,
                                  title: 'Save your favourite venues',
                                  body:
                                      'Log in to save venues and get alerts when your usual courts open up.',
                                  onLogin: () => context.push(
                                    '${AppRoutes.login}?next=home',
                                  ),
                                  onSignup: () => context.push(
                                    '${AppRoutes.signup}?next=home',
                                  ),
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Transform.translate(
                                offset: const Offset(0, -26),
                                child: DecoratedBox(
                                  decoration: const BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(26),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const .fromLTRB(20, 22, 20, 28),
                                    child: Column(
                                      crossAxisAlignment: .start,
                                      children: [
                                        _VenueIntro(state: state),
                                        AppSizes.spaceLg.h,
                                        const _PayGroundCallout(),
                                        AppSizes.spaceLg.h,
                                        _CourtPicker(state: state),
                                        AppSizes.spaceLg.h,
                                        _DatePicker(state: state),
                                        AppSizes.spaceLg.h,
                                        _DurationPicker(state: state),
                                        AppSizes.spaceLg.h,
                                        _SlotGrid(state: state),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      BookingStickyBar(
                        enabled: state.canContinue,
                        meta: state.canContinue
                            ? '${state.selectedCourt?.name} · ${state.summaryLine}'
                            : null,
                        total: state.canContinue ? state.total : null,
                        ctaLabel: 'Continue',
                        onPressed: () {
                          AppHaptics.medium();
                          context.push(AppRoutes.checkout);
                        },
                      ),
                    ],
                  ),
          );
        },
      ),
    ).annotatedRegion(.dark);
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.venueId,
    required this.color,
    required this.onBack,
    required this.onSave,
  });

  final String venueId;
  final Color color;
  final VoidCallback onBack;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Hero(
          tag: 'venue-hero-$venueId',
          child: CourtHeroCanvas(color: color, height: 210),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const .all(16),
            child: Row(
              children: [
                _RoundIconButton(
                  icon: AppIcons.back,
                  onPressed: onBack,
                ),
                const Spacer(),
                _RoundIconButton(icon: Icons.ios_share, onPressed: () {}),
                8.w,
                _RoundIconButton(
                  icon: Icons.favorite_border,
                  onPressed: onSave,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface.withValues(alpha: 0.94),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 20, color: AppColors.text),
        ),
      ),
    );
  }
}

class _VenueIntro extends StatelessWidget {
  const _VenueIntro({required this.state});

  final BookingState state;

  @override
  Widget build(BuildContext context) {
    final venue = state.venue!;
    return Column(
      crossAxisAlignment: .start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _Chip(
              label: venue.sport,
              background: AppColors.padelSoft,
              foreground: AppColors.padel,
            ),
            const _Chip(
              label: 'Pay at ground available',
              background: AppColors.accentSoft,
              foreground: AppColors.payBadgeText,
            ),
          ],
        ),
        10.h,
        Text(
          venue.name,
          style: context.textTheme.headlineMedium?.copyWith(
            fontSize: 26,
            fontWeight: .w800,
            height: 1.15,
            letterSpacing: -0.6,
          ),
        ),
        8.h,
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 16,
              color: AppColors.textSecondary,
            ),
            4.w,
            Text(
              venue.location,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ).expand(),
          ],
        ),
        12.h,
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final amenity in venue.amenities)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Text(
                  amenity,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: AppColors.textBody,
                    fontSize: 12,
                    fontWeight: .w600,
                  ),
                ).paddingSymmetric(horizontal: 10, vertical: 6),
              ),
          ],
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Text(
        label,
        style: context.textTheme.labelMedium?.copyWith(
          color: foreground,
          fontSize: 12,
          fontWeight: .w800,
        ),
      ).paddingSymmetric(horizontal: 10, vertical: 5),
    );
  }
}

class _PayGroundCallout extends StatelessWidget {
  const _PayGroundCallout();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Row(
        crossAxisAlignment: .start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.accent,
                size: 20,
              ),
            ),
          ),
          12.w,
          Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                'Pay at the ground',
                style: context.textTheme.titleSmall?.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: .w800,
                  fontSize: 15,
                ),
              ),
              4.h,
              Text(
                'Reserve now. Pay by cash or card when you arrive — no advance needed.',
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.onPrimary.withValues(alpha: 0.82),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ).expand(),
        ],
      ).paddingAll(14),
    );
  }
}

class _CourtPicker extends StatelessWidget {
  const _CourtPicker({required this.state});

  final BookingState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BookingCubit>();
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          'Choose court',
          style: context.textTheme.titleMedium?.copyWith(
            fontSize: 17,
            fontWeight: .w800,
          ),
        ),
        10.h,
        Row(
          children: [
            for (var i = 0; i < state.courts.length; i++) ...[
              if (i > 0) 10.w,
              _CourtTile(
                selected: state.courts[i].id == state.selectedCourtId,
                name: state.courts[i].name,
                note: state.courts[i].note,
                onTap: () => cubit.selectCourt(state.courts[i].id),
              ).expand(),
            ],
          ],
        ),
      ],
    );
  }
}

class _CourtTile extends StatelessWidget {
  const _CourtTile({
    required this.selected,
    required this.name,
    required this.note,
    required this.onTap,
  });

  final bool selected;
  final String name;
  final String note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.selectedSoft : AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          constraints: const BoxConstraints(minHeight: 64),
          padding: const .symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.outline,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                name,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: .w800,
                  fontSize: 15,
                ),
              ),
              2.h,
              Text(
                note,
                style: context.textTheme.labelMedium?.copyWith(
                  color: selected
                      ? AppColors.textBody
                      : AppColors.textSecondary,
                  fontWeight: .w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DatePicker extends StatelessWidget {
  const _DatePicker({required this.state});

  final BookingState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BookingCubit>();
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          'Pick a date',
          style: context.textTheme.titleMedium?.copyWith(
            fontSize: 17,
            fontWeight: .w800,
          ),
        ),
        10.h,
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: .horizontal,
            itemCount: state.dates.length,
            separatorBuilder: (_, _) => 8.w,
            itemBuilder: (context, index) {
              final date = state.dates[index];
              final selected = date.id == state.selectedDateId;
              return _DateCell(
                selected: selected,
                weekday: date.weekday,
                day: date.day,
                month: date.month,
                onTap: () => cubit.selectDate(date.id),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DateCell extends StatelessWidget {
  const _DateCell({
    required this.selected,
    required this.weekday,
    required this.day,
    required this.month,
    required this.onTap,
  });

  final bool selected;
  final String weekday;
  final String day;
  final String month;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 64,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.outline,
            ),
          ),
          child: Column(
            mainAxisAlignment: .center,
            children: [
              Text(
                weekday,
                style: context.textTheme.labelMedium?.copyWith(
                  color: selected ? AppColors.accent : AppColors.textSecondary,
                  fontWeight: .w700,
                  fontSize: 12,
                ),
              ),
              2.h,
              Text(
                day,
                style: context.textTheme.titleLarge?.copyWith(
                  color: selected ? AppColors.onPrimary : AppColors.text,
                  fontWeight: .w800,
                  fontSize: 22,
                ),
              ),
              Text(
                month,
                style: context.textTheme.labelSmall?.copyWith(
                  color: selected
                      ? AppColors.onPrimary.withValues(alpha: 0.8)
                      : AppColors.textSecondary,
                  fontWeight: .w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DurationPicker extends StatelessWidget {
  const _DurationPicker({required this.state});

  final BookingState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BookingCubit>();
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          'Duration',
          style: context.textTheme.titleMedium?.copyWith(
            fontSize: 17,
            fontWeight: .w800,
          ),
        ),
        10.h,
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.track,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Padding(
            padding: const .all(4),
            child: Row(
              children: [
                for (final duration in state.durations)
                  _DurationChip(
                    label: duration,
                    selected: duration == state.selectedDuration,
                    onTap: () => cubit.selectDuration(duration),
                  ).expand(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DurationChip extends StatelessWidget {
  const _DurationChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .symmetric(horizontal: 2),
      child: Material(
        color: selected ? AppColors.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        elevation: selected ? 1 : 0,
        shadowColor: const Color(0x260D1B14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 44,
            child: Text(
              label,
              textAlign: .center,
              style: context.textTheme.labelLarge?.copyWith(
                fontWeight: selected ? .w800 : .w600,
                fontSize: 14,
                color: selected ? AppColors.text : AppColors.textBody,
              ),
            ).center(),
          ),
        ),
      ),
    );
  }
}

class _SlotGrid extends StatelessWidget {
  const _SlotGrid({required this.state});

  final BookingState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BookingCubit>();
    return Column(
      crossAxisAlignment: .start,
      children: [
        Row(
          children: [
            Text(
              'Available slots',
              style: context.textTheme.titleMedium?.copyWith(
                fontSize: 17,
                fontWeight: .w800,
              ),
            ).expand(),
            const _LegendDot(color: AppColors.surface, label: 'Open'),
            8.w,
            const _LegendDot(color: AppColors.primary, label: 'Yours'),
            8.w,
            const _LegendDot(color: AppColors.track, label: 'Booked'),
          ],
        ),
        10.h,
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.slots.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.35,
          ),
          itemBuilder: (context, index) {
            final slot = state.slots[index];
            final selected = slot.id == state.selectedSlotId;
            return _SlotTile(
              slot: slot,
              selected: selected,
              onTap: () => cubit.selectSlot(slot.id),
            );
          },
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: .min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            shape: .circle,
            border: Border.all(color: AppColors.outline),
          ),
          child: const SizedBox(width: 8, height: 8),
        ),
        4.w,
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _SlotTile extends StatelessWidget {
  const _SlotTile({
    required this.slot,
    required this.selected,
    required this.onTap,
  });

  final TimeSlot slot;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final booked = slot.isBooked;
    final bg = selected
        ? AppColors.primary
        : booked
        ? AppColors.track
        : AppColors.surface;
    final border = selected
        ? AppColors.primary
        : booked
        ? AppColors.track
        : AppColors.outline;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: InkWell(
        onTap: booked ? null : onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const .symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: border, width: selected ? 2 : 1),
          ),
          child: Column(
            mainAxisAlignment: .center,
            children: [
              Text(
                slot.label,
                style: context.textTheme.titleSmall?.copyWith(
                  color: selected
                      ? AppColors.onPrimary
                      : booked
                      ? AppColors.textSecondary
                      : AppColors.text,
                  fontWeight: .w800,
                  fontSize: 15,
                  decoration: booked ? TextDecoration.lineThrough : null,
                ),
              ),
              4.h,
              Text(
                booked ? 'Booked' : MoneyFormat.pkr(slot.price),
                style: context.textTheme.labelMedium?.copyWith(
                  color: selected
                      ? AppColors.accent
                      : booked
                      ? AppColors.textSecondary
                      : AppColors.textSecondary,
                  fontWeight: selected ? .w700 : .w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
