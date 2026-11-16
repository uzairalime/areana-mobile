import 'package:material_ui/material_ui.dart';

import '../consts/app_colors.dart';
import '../consts/app_sizes.dart';
import 'app_button.dart';

/// Pill-shaped primary action with optional loading and trailing icon.
class PrimaryButton extends AppButton {
  const PrimaryButton({
    super.key,
    required super.label,
    required super.onPressed,
    super.loading,
    super.backgroundColor = AppColors.accent,
    super.foregroundColor = AppColors.text,
    super.showArrow,
    super.icon,
    super.minimumSize = const Size(0, AppSizes.buttonHeight),
    super.shape = const StadiumBorder(),
    super.textStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w800,
    ),
  });
}
