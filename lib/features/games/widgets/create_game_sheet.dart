import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../bookings/model/user_booking.dart';

/// Result of the create-game sheet: the booking to post from plus
/// the game settings. Games are posted from a confirmed booking
/// (user-web rule), so venue/court/time come from that booking.
class CreateGameResult {
  const CreateGameResult({
    required this.bookingId,
    required this.playersNeeded,
    this.squadSize,
    this.level,
    this.note,
  });

  final String bookingId;
  final int playersNeeded;
  final int? squadSize;
  final String? level;
  final String? note;
}

Future<CreateGameResult?> showCreateGameSheet(
  BuildContext context, {
  required List<UserBooking> postableBookings,
}) {
  AppHaptics.light();
  return showModalBottomSheet<CreateGameResult>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.scrim,
    isScrollControlled: true,
    builder: (sheetContext) =>
        _CreateGameSheetBody(bookings: postableBookings),
  );
}

class _CreateGameSheetBody extends StatefulWidget {
  const _CreateGameSheetBody({required this.bookings});

  final List<UserBooking> bookings;

  @override
  State<_CreateGameSheetBody> createState() => _CreateGameSheetBodyState();
}

class _CreateGameSheetBodyState extends State<_CreateGameSheetBody> {
  late String _bookingId =
      widget.bookings.isEmpty ? '' : widget.bookings.first.id;
  final _playersNeededController = TextEditingController(text: '4');
  final _squadController = TextEditingController(text: '6');
  final _levelController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _playersNeededController.dispose();
    _squadController.dispose();
    _levelController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  int? _intInRange(TextEditingController controller) {
    final value = int.tryParse(controller.text.trim());
    if (value == null || value < 1 || value > 50) return null;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final playersNeeded = _intInRange(_playersNeededController);
    final squad = _intInRange(_squadController);
    final valid = _bookingId.isNotEmpty && playersNeeded != null;
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
                'Post a game',
                style: context.textTheme.headlineMedium?.copyWith(
                  fontSize: 22,
                  fontWeight: .w800,
                  letterSpacing: -0.4,
                ),
              ),
              6.h,
              Text(
                'Pick one of your confirmed bookings — players join a game that actually exists.',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              16.h,
              if (widget.bookings.isEmpty)
                Text(
                  'No bookings can be posted right now — they may already have a game post or have started.',
                  style: context.textTheme.bodyMedium,
                )
              else
                DropdownButtonFormField<String>(
                  value: _bookingId,
                  items: [
                    for (final booking in widget.bookings)
                      DropdownMenuItem(
                        value: booking.id,
                        child: Text(
                          '${booking.venueName} · ${booking.scheduleLine}',
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _bookingId = value);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Booking',
                  ),
                ),
              16.h,
              AppTextField(
                controller: _playersNeededController,
                label: 'Players needed (1–50)',
                icon: Icons.group_add_outlined,
                hint: '4',
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
              12.h,
              AppTextField(
                controller: _squadController,
                label: 'We are (1–50)',
                icon: Icons.group_outlined,
                hint: '6',
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
              12.h,
              AppTextField(
                controller: _levelController,
                label: 'Level (optional)',
                icon: Icons.speed_outlined,
                hint: 'Intermediate',
              ),
              12.h,
              AppTextField(
                controller: _noteController,
                label: 'Note (optional, max 280)',
                icon: Icons.note_outlined,
                hint: 'Bring your own shoes',
              ),
              20.h,
              AppButton(
                label: 'Post game',
                onPressed: valid
                    ? () {
                        AppHaptics.medium();
                        Navigator.of(context).pop(
                          CreateGameResult(
                            bookingId: _bookingId,
                            playersNeeded: playersNeeded!,
                            squadSize: squad,
                            level: _levelController.text.trim().isEmpty
                                ? null
                                : _levelController.text.trim(),
                            note: _noteController.text.trim().isEmpty
                                ? null
                                : _noteController.text.trim(),
                          ),
                        );
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
