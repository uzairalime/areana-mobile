import 'package:flutter/material.dart';

import '../consts/app_colors.dart';
import '../consts/app_sizes.dart';
import '../consts/app_strings.dart';
import 'app_button.dart';

Future<void> showAppErrorDialog(
  BuildContext context, {
  required String title,
  required String message,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Error',
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, animation, secondaryAnimation) {
      return AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          textAlign: .center,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: .w800),
        ),
        content: Text(
          message,
          textAlign: .center,
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: AppColors.textBody),
        ),
        actions: [
          AppButton(
            label: AppStrings.okay,
            showArrow: false,
            minimumSize: const Size(0, AppSizes.buttonHeight),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          ),
          child: child,
        ),
      );
    },
  );
}
