import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/widgets/app_button.dart';

/// ReelStay-style logout confirmation as a bottom sheet.
Future<bool> showProfileLogoutDialog(BuildContext context) async {
  AppHaptics.light();
  final result = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: .vertical(top: Radius.circular(22)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const .fromLTRB(28, 14, 28, 12),
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
              18.h,
              Text(
                'Log out',
                textAlign: .center,
                style: sheetContext.textTheme.titleLarge?.copyWith(
                  fontWeight: .w800,
                  letterSpacing: -0.2,
                ),
              ),
              10.h,
              Text(
                'Are you sure you want to log out? You can sign back in any time — your bookings stay on your account.',
                textAlign: .center,
                style: sheetContext.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              28.h,
              AppButton(
                label: 'Yes, log out',
                showArrow: false,
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.onError,
                onPressed: () {
                  AppHaptics.medium();
                  Navigator.of(sheetContext).pop(true);
                },
              ),
              Divider(
                height: 18,
                color: AppColors.text.withValues(alpha: 0.08),
              ),
              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                child: TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(false),
                  child: Text(
                    'Cancel',
                    style: sheetContext.textTheme.titleMedium?.copyWith(
                      fontWeight: .w700,
                      color: AppColors.text,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  return result ?? false;
}

/// ReelStay-style delete dialog with reason field + scale/fade transition.
Future<bool> showDeleteAccountDialog(BuildContext context) async {
  AppHaptics.light();
  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'DeleteAccountDialog',
    barrierColor: AppColors.scrim,
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return const _DeleteAccountDialog();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: child,
        ),
      );
    },
  );
  return result ?? false;
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _controller = TextEditingController();
  bool _canConfirm = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  void _onChanged() {
    final next = _controller.text.trim().isNotEmpty;
    if (next != _canConfirm) setState(() => _canConfirm = next);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titlePadding: const .fromLTRB(20, 22, 20, 10),
      contentPadding: const .symmetric(horizontal: 20, vertical: 12),
      actionsPadding: const .all(16),
      title: Text(
        'Delete account',
        textAlign: .center,
        style: context.textTheme.titleLarge?.copyWith(
          fontWeight: .w800,
          letterSpacing: -0.2,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: .min,
          children: [
            Text(
              'This permanently removes your profile, saved venues, and upcoming bookings. Tell us why you’re leaving — it helps us improve Pitchside.',
              textAlign: .center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            18.h,
            TextField(
              controller: _controller,
              minLines: 3,
              maxLines: 5,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              style: context.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: "Tell us why you're leaving",
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const .symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  foregroundColor: AppColors.text,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: context.textTheme.labelLarge?.copyWith(
                    fontWeight: .w700,
                  ),
                ),
              ),
            ),
            10.w,
            Expanded(
              child: FilledButton(
                onPressed: !_canConfirm
                    ? null
                    : () {
                        AppHaptics.medium();
                        Navigator.of(context).pop(true);
                      },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.onError,
                  disabledBackgroundColor: AppColors.error.withValues(
                    alpha: 0.35,
                  ),
                  disabledForegroundColor: AppColors.onError.withValues(
                    alpha: 0.7,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Delete',
                  style: context.textTheme.labelLarge?.copyWith(
                    color: AppColors.onError,
                    fontWeight: .w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
