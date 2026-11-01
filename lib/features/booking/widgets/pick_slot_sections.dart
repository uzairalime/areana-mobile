import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_icons.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/utils/money_format.dart';
import '../../home/model/areana_models.dart';
import '../cubit/booking_cubit.dart';
import '../cubit/booking_state.dart';
import 'court_hero_canvas.dart';

/// Pick-slot sections, extracted from the screen so the screen file
/// stays under 500 lines. Data is Areana availability: courts from
/// the venue, dates as the next 14 days, slots from
/// `GET /courts/:id/availability` with peak/deal badges and the
/// server's unavailable reason (never invented).
class PickSlotHeroHeader extends StatelessWidget {
  const PickSlotHeroHeader({
    super.key,
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
                _RoundIconButton(icon: AppIcons.back, onPressed: onBack),
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

class PickSlotVenueIntro extends StatelessWidget {
  const PickSlotVenueIntro({super.key, required this.state});

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

class PickSlotPayGroundCallout extends StatelessWidget {
  const PickSlotPayGroundCallout({super.key});

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

class PickSlotCourtPicker extends StatelessWidget {
  const PickSlotCourtPicker({super.key, required this.state});

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
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final court in state.courts)
              _CourtTile(
                selected: court.id == state.selectedCourtId,
                name: court.name,
                note: court.specLine,
                price: court.pricePerHour,
                onTap: () => cubit.selectCourt(court.id),
              ),
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
    required this.price,
    required this.onTap,
  });

  final bool selected;
  final String name;
  final String note;
  final int price;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.selectedSoft : AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Container(
          constraints: const BoxConstraints(minHeight: 64, minWidth: 140),
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
              2.h,
              Text(
                '${MoneyFormat.pkr(price)}/hr',
                style: context.textTheme.labelMedium?.copyWith(
                  fontWeight: .w700,
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

class PickSlotDatePicker extends StatelessWidget {
  const PickSlotDatePicker({super.key, required this.state});

  final BookingState state;

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BookingCubit>();
    final today = DateTime.now();
    final days = List<DateTime>.generate(
      14,
      (i) => DateTime(today.year, today.month, today.day + i),
    );
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
            itemCount: days.length,
            separatorBuilder: (_, _) => 8.w,
            itemBuilder: (context, index) {
              final date = days[index];
              final selected = formatDate(date) == state.selectedDate;
              return _DateCell(
                selected: selected,
                weekday: _weekdays[date.weekday - 1],
                day: '${date.day}',
                month: _months[date.month - 1],
                onTap: () => cubit.selectDate(date),
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

class PickSlotCountPicker extends StatelessWidget {
  const PickSlotCountPicker({super.key, required this.state});

  final BookingState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BookingCubit>();
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          'Slots',
          style: context.textTheme.titleMedium?.copyWith(
            fontSize: 17,
            fontWeight: .w800,
          ),
        ),
        4.h,
        Text(
          'Consecutive slots, like user-web slotCount.',
          style: context.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
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
                for (var count = 1; count <= 4; count++)
                  _CountChip(
                    label: '$count',
                    selected: count == state.slotCount,
                    onTap: () => cubit.selectSlotCount(count),
                  ).expand(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({
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

class PickSlotGrid extends StatelessWidget {
  const PickSlotGrid({super.key, required this.state});

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
        if (state.slots.isEmpty)
          Text(
            'No slots for this court and date.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.slots.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.25,
            ),
            itemBuilder: (context, index) {
              final slot = state.slots[index];
              final selected = slot.startMinutes == state.selectedStartMinutes;
              return _SlotTile(
                slot: slot,
                selected: selected,
                onTap: () => cubit.selectSlot(slot.startMinutes),
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

  final AvailabilitySlot slot;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final booked = !slot.available;
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
              2.h,
              Text(
                booked ? slot.unavailableLabel : MoneyFormat.pkr(slot.price),
                style: context.textTheme.labelMedium?.copyWith(
                  color: selected
                      ? AppColors.accent
                      : AppColors.textSecondary,
                  fontWeight: selected ? .w700 : .w600,
                  fontSize: 12,
                ),
              ),
              if (!booked && (slot.peak || slot.deal))
                Text(
                  slot.peak ? 'Peak' : 'Off-peak deal',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: selected
                        ? AppColors.accent
                        : AppColors.primary,
                    fontWeight: .w800,
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
