import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money_format.dart';
import '../cubit/booking_state.dart';
import 'court_hero_canvas.dart';

class BookingSummaryCard extends StatelessWidget {
  const BookingSummaryCard({super.key, required this.state});

  final BookingState state;

  @override
  Widget build(BuildContext context) {
    final venue = state.venue;
    if (venue == null) {
      return const SizedBox.shrink();
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.outline),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: .start,
            children: [
              SizedBox(
                width: 84,
                child: CourtHeroCanvas(
                  color: venue.heroColor,
                  height: 84,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  showGradient: false,
                ),
              ),
              12.w,
              Column(
                crossAxisAlignment: .start,
                children: [
                  _SportChip(label: venue.sport),
                  8.h,
                  Text(
                    venue.name,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontSize: 17,
                      fontWeight: .w800,
                    ),
                  ),
                  4.h,
                  Text(
                    venue.location,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ).expand(),
            ],
          ),
          14.h,
          const DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.border,
                  style: BorderStyle.solid,
                ),
              ),
            ),
            child: SizedBox(height: 1, width: double.infinity),
          ),
          // dashed feel via dotted line substitute
          CustomPaint(
            painter: const _DashedLinePainter(),
            child: const SizedBox(height: 1, width: double.infinity),
          ),
          14.h,
          Row(
            children: [
              _MetaTile(
                icon: Icons.calendar_today_outlined,
                label: 'Date',
                value: state.selectedDate ?? '—',
              ).expand(),
              12.w,
              _MetaTile(
                icon: Icons.schedule_outlined,
                label: 'Time',
                value: state.timeRange,
              ).expand(),
            ],
          ),
          14.h,
          Row(
            children: [
              _MetaTile(
                icon: Icons.grid_view_rounded,
                label: 'Court',
                value: _courtLabel(state),
              ).expand(),
              12.w,
              _MetaTile(
                icon: Icons.timer_outlined,
                label: 'Slots',
                value: '${state.slotCount} slot${state.slotCount == 1 ? '' : 's'}',
              ).expand(),
            ],
          ),
        ],
      ).paddingAll(14),
    );
  }

  static String _courtLabel(BookingState state) {
    final court = state.selectedCourt;
    if (court == null) {
      return '—';
    }
    return '${court.name} · ${court.sport}';
  }
}

class BookingReminderCard extends StatelessWidget {
  const BookingReminderCard({super.key, required this.state});

  final BookingState state;

  @override
  Widget build(BuildContext context) {
    final court = state.selectedCourt;
    final venue = state.venue;
    if (court == null || venue == null) {
      return const SizedBox.shrink();
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.selectedSoft,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: const Color(0xFFCFE3D4)),
      ),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.calendar_month_outlined,
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
                '${court.name} · ${venue.sport}',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: .w800,
                ),
              ),
              2.h,
              Text(
                state.summaryLine,
                style: context.textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ).expand(),
          Text(
            MoneyFormat.pkr(state.total),
            style: context.textTheme.titleSmall?.copyWith(fontWeight: .w800),
          ),
        ],
      ).paddingSymmetric(horizontal: 14, vertical: 12),
    );
  }
}

class _SportChip extends StatelessWidget {
  const _SportChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.padelSoft,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Text(
        label,
        style: context.textTheme.labelMedium?.copyWith(
          color: AppColors.padel,
          fontSize: 11,
          fontWeight: .w800,
        ),
      ).paddingSymmetric(horizontal: 10, vertical: 5),
    );
  }
}

class _MetaTile extends StatelessWidget {
  const _MetaTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: .start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
        ),
        10.w,
        Column(
          crossAxisAlignment: .start,
          children: [
            Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: .w600,
                fontSize: 11,
              ),
            ),
            2.h,
            Text(
              value,
              style: context.textTheme.labelLarge?.copyWith(
                fontWeight: .w800,
                fontSize: 14,
              ),
            ),
          ],
        ).expand(),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    const dash = 6.0;
    const gap = 4.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
