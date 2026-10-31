import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_icons.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/consts/app_strings.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/widgets/pitchside_mark.dart';

class AuthTopBar extends StatelessWidget {
  const AuthTopBar({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      crossAxisAlignment: .center,
      children: [
        _CircleIconButton(onPressed: onBack, icon: AppIcons.back),
        Row(
          children: [
            const PitchsideMark(
              size: 32,
              radius: 10,
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.accent,
            ),
            8.w,
            Text(
              AppStrings.appName,
              style: context.textTheme.titleMedium?.copyWith(
                letterSpacing: -0.34,
              ),
            ),
          ],
        ),
        const SizedBox(width: 44),
      ],
    ).paddingSymmetric(horizontal: AppSizes.pagePadding, vertical: 8);
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.onPressed, required this.icon});

  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: .circle,
        border: Border.all(color: AppColors.outline),
      ),
      child: Icon(icon, color: AppColors.text, size: 22),
    ).onTap(onPressed);
  }
}

class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Divider(color: AppColors.border).expand(),
        Text(
          'or',
          style: context.textTheme.bodySmall?.copyWith(fontWeight: .w600),
        ).paddingSymmetric(horizontal: 12),
        const Divider(color: AppColors.border).expand(),
      ],
    );
  }
}

class GuestContinueButton extends StatelessWidget {
  const GuestContinueButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: const _DashedRRectPainter(),
      child: SizedBox(
        height: 52,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: .center,
          children: [
            const Icon(Icons.person_outline, size: 18, color: AppColors.text),
            8.w,
            Text('Continue as guest', style: context.textTheme.labelLarge),
          ],
        ),
      ),
    ).onTap(onPressed);
  }
}

class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(AppSizes.radiusMd),
        ),
      );
    final paint = Paint()
      ..color = AppColors.textDisabled
      ..style = .stroke
      ..strokeWidth = 1.5;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + 6;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + 4;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
