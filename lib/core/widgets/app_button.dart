import 'package:flutter/material.dart';

import '../consts/app_colors.dart';
import '../consts/app_sizes.dart';

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
    this.shape,
    this.textStyle,
  }) : side = null,
       variant = AppButtonVariant.filled;

  const AppButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.backgroundColor = AppColors.surface,
    this.foregroundColor = AppColors.text,
    this.icon,
    this.minimumSize,
    this.shape,
    this.textStyle,
    this.side = const BorderSide(color: AppColors.border),
  }) : showArrow = false,
       variant = AppButtonVariant.outlined;

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool showArrow;
  final IconData? icon;
  final Size? minimumSize;
  final OutlinedBorder? shape;
  final TextStyle? textStyle;
  final BorderSide? side;
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
        disabledBackgroundColor: loading ? backgroundColor : null,
        disabledForegroundColor: loading ? foregroundColor : null,
        // A finite minimum also permits use in a Row without Expanded.
        minimumSize: minimumSize ?? const Size(0, AppSizes.buttonHeight),
        shape: shape,
        textStyle: Theme.of(context).textTheme.titleMedium
            ?.copyWith(fontSize: 16)
            .merge(textStyle),
      ),
      child: _content(),
    );
  }

  Widget _outlined(BuildContext context) {
    return OutlinedButton(
      onPressed: loading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        disabledBackgroundColor: loading ? backgroundColor : null,
        disabledForegroundColor: loading ? foregroundColor : null,
        minimumSize: minimumSize ?? const Size(0, 52),
        side: side,
        shape: shape,
        textStyle: Theme.of(context).textTheme.labelLarge?.merge(textStyle),
      ),
      child: _content(),
    );
  }

  Widget _content() {
    // Fill bounded parents, but shrink to fit when width is unconstrained.
    return Align(
      heightFactor: 1,
      child: loading
          ? SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: foregroundColor,
                semanticsLabel: label,
              ),
            )
          : _label(),
    );
  }

  Widget _label() {
    final effectiveIcon = icon ?? (showArrow ? Icons.arrow_forward : null);
    final iconWidget = effectiveIcon == null
        ? null
        : Icon(
            effectiveIcon,
            size: 18,
            color:
                onPressed != null &&
                    variant == AppButtonVariant.filled &&
                    foregroundColor == AppColors.onPrimary
                ? AppColors.accent
                : null,
          );

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (variant == AppButtonVariant.outlined && iconWidget != null) ...[
          iconWidget,
          const SizedBox(width: 8),
        ],
        Flexible(child: Text(label, textAlign: TextAlign.center)),
        if (variant == AppButtonVariant.filled && iconWidget != null) ...[
          const SizedBox(width: 8),
          iconWidget,
        ],
      ],
    );
  }
}
