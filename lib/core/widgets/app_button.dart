import 'package:flutter/material.dart';

import '../consts/app_colors.dart';
import '../consts/app_sizes.dart';
import '../extensions/extensions.dart';

enum AppButtonVariant { filled, outlined }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.backgroundColor = AppColors.primary,
    this.foregroundColor = AppColors.onPrimary,
    this.showArrow = true,
    this.icon,
    this.minimumSize,
  }) : variant = AppButtonVariant.filled;

  const AppButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.minimumSize,
  }) : loading = false,
       backgroundColor = AppColors.primary,
       foregroundColor = AppColors.onPrimary,
       showArrow = false,
       variant = AppButtonVariant.outlined;

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool showArrow;
  final IconData? icon;
  final Size? minimumSize;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      .filled => _filled(context),
      .outlined => _outlined(context),
    };
  }

  Widget _filled(BuildContext context) {
    return FilledButton(
      onPressed: loading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        disabledBackgroundColor: backgroundColor,
        disabledForegroundColor: foregroundColor,
        minimumSize:
            minimumSize ?? const Size.fromHeight(AppSizes.buttonHeight),
      ),
      child: loading
          ? SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: foregroundColor,
              ),
            )
          : Row(
              mainAxisAlignment: .center,
              children: [
                Text(
                  label,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: foregroundColor,
                    fontSize: 16,
                  ),
                ),
                if (showArrow || icon != null) ...[
                  8.w,
                  Icon(
                    icon ?? Icons.arrow_forward,
                    size: 18,
                    color: foregroundColor == AppColors.onPrimary
                        ? AppColors.accent
                        : foregroundColor,
                  ),
                ],
              ],
            ),
    );
  }

  Widget _outlined(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: minimumSize ?? const Size.fromHeight(52),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: .center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppColors.text),
            8.w,
          ],
          Text(label, style: context.textTheme.labelLarge),
        ],
      ),
    );
  }
}
