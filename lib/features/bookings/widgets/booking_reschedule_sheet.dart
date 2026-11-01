import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../model/user_booking.dart';

/// Result of the reschedule sheet: a new date (YYYY-MM-DD) and
/// startMinutes. The owner approves the request in user-web.
class BookingRescheduleResult {
  const BookingRescheduleResult({
    required this.date,
    required this.startMinutes,
  });

  final String date;
  final int startMinutes;
}

String _dateLabel(DateTime day) =>
    '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

Future<BookingRescheduleResult?> showBookingRescheduleSheet(
  BuildContext context, {
  required UserBooking booking,
}) {
  AppHaptics.light();
  return showModalBottomSheet<BookingRescheduleResult>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.scrim,
    isScrollControlled: true,
    builder: (sheetContext) => const _RescheduleSheetBody(),
  );
}

class _RescheduleSheetBody extends StatefulWidget {
  const _RescheduleSheetBody();

  @override
  State<_RescheduleSheetBody> createState() => _RescheduleSheetBodyState();
}

class _RescheduleSheetBodyState extends State<_RescheduleSheetBody> {
  late DateTime _day = DateTime.now().add(const Duration(days: 1));
  final _timeController = TextEditingController(text: '09:00');

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  int? get _startMinutes {
    final parts = _timeController.text.trim().split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null || h < 0 || h > 23 || m < 0 || m > 59) {
      return null;
    }
    return h * 60 + m;
  }

  @override
  Widget build(BuildContext context) {
    final days = List.generate(
      14,
      (i) => DateTime.now().add(Duration(days: i + 1)),
    );
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            12,
            24,
            28 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                ),
                child: const SizedBox(width: 40, height: 4),
              ),
              22.h,
              Text(
                'Request a new time',
                style: context.textTheme.headlineMedium?.copyWith(
                  fontSize: 22,
                  fontWeight: .w800,
                  letterSpacing: -0.4,
                ),
              ),
              6.h,
              Text(
                'The venue owner approves the request.',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              16.h,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final day in days)
                    ChoiceChip(
                      label: Text(_dateLabel(day)),
                      selected: _dateLabel(day) == _dateLabel(_day),
                      onSelected: (_) => setState(() => _day = day),
                    ),
                ],
              ),
              16.h,
              AppTextField(
                controller: _timeController,
                label: 'Start time (HH:MM)',
                hint: '09:00',
                keyboardType: TextInputType.datetime,
              ),
              20.h,
              AppButton(
                label: 'Send request',
                onPressed: _startMinutes == null
                    ? null
                    : () {
                        AppHaptics.medium();
                        Navigator.of(context).pop(
                          BookingRescheduleResult(
                            date: _dateLabel(_day),
                            startMinutes: _startMinutes!,
                          ),
                        );
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
