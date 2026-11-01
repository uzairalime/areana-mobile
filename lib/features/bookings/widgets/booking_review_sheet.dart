import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../model/user_booking.dart';

/// Result of the review sheet: a 1–5 star rating plus an optional comment.
/// Mirrors user-web `POST /reviews` (one review per completed booking).
class BookingReviewResult {
  const BookingReviewResult({required this.rating, this.comment});

  final int rating;
  final String? comment;
}

Future<BookingReviewResult?> showBookingReviewSheet(
  BuildContext context, {
  required UserBooking booking,
}) {
  AppHaptics.light();
  return showModalBottomSheet<BookingReviewResult>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.scrim,
    isScrollControlled: true,
    builder: (sheetContext) {
      return const _ReviewSheetBody();
    },
  );
}

class _ReviewSheetBody extends StatefulWidget {
  const _ReviewSheetBody();

  @override
  State<_ReviewSheetBody> createState() => _ReviewSheetBodyState();
}

class _ReviewSheetBodyState extends State<_ReviewSheetBody> {
  var _rating = 5;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                'How was your game?',
                textAlign: .center,
                style: context.textTheme.headlineMedium?.copyWith(
                  fontSize: 22,
                  fontWeight: .w800,
                  letterSpacing: -0.4,
                ),
              ),
              16.h,
              Row(
                mainAxisAlignment: .center,
                children: [
                  for (var i = 1; i <= 5; i++)
                    IconButton(
                      onPressed: () {
                        AppHaptics.selection();
                        setState(() => _rating = i);
                      },
                      icon: Icon(
                        i <= _rating ? Icons.star : Icons.star_border,
                        color: AppColors.primary,
                        size: 36,
                      ),
                    ),
                ],
              ),
              16.h,
              AppTextField(
                controller: _commentController,
                label: 'Comment (optional)',
                icon: Icons.comment_outlined,
                hint: 'Tell others about this venue',
              ),
              20.h,
              AppButton(
                label: 'Submit review',
                onPressed: () {
                  AppHaptics.medium();
                  Navigator.of(context).pop(
                    BookingReviewResult(
                      rating: _rating,
                      comment: _commentController.text.trim().isEmpty
                          ? null
                          : _commentController.text.trim(),
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
