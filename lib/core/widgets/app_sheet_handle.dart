import 'package:material_ui/material_ui.dart';

import '../consts/app_colors.dart';
import '../consts/app_sizes.dart';

/// Decorative drag handle; the sheet controls its alignment and spacing.
class AppSheetHandle extends StatelessWidget {
  const AppSheetHandle({
    super.key,
    this.width = 40,
    this.height = 4,
    this.color = AppColors.border,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(
            Radius.circular(AppSizes.radiusPill),
          ),
        ),
      ),
    );
  }
}
