import 'package:material_ui/material_ui.dart';

import '../consts/app_colors.dart';
import '../consts/app_sizes.dart';
import 'app_button.dart';

/// Transparent primary action with a pill-shaped outline.
class PrimaryOutlineButton extends AppButton {
  const PrimaryOutlineButton({
    super.key,
    required super.label,
    required super.onPressed,
    super.loading,
    super.backgroundColor = Colors.transparent,
    super.foregroundColor = AppColors.onPrimary,
    super.icon,
    super.minimumSize = const Size(0, AppSizes.buttonHeight),
    super.shape = const StadiumBorder(),
    super.textStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
    ),
    super.side = const BorderSide(color: Color(0x66FFFFFF), width: 1.5),
  }) : super.outlined();
}
