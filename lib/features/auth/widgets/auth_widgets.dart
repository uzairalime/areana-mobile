import 'package:material_ui/material_ui.dart';

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

class SocialAuthButton extends StatelessWidget {
  const SocialAuthButton.google({super.key, required this.onPressed})
    : _kind = _SocialKind.google;

  const SocialAuthButton.apple({super.key, required this.onPressed})
    : _kind = _SocialKind.apple;

  final VoidCallback onPressed;
  final _SocialKind _kind;

  @override
  Widget build(BuildContext context) {
    final isApple = _kind == _SocialKind.apple;
    return SizedBox(
      height: AppSizes.buttonHeight,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isApple ? AppColors.text : AppColors.surface,
          foregroundColor: isApple ? AppColors.surface : AppColors.text,
          side: BorderSide(
            color: isApple ? AppColors.text : AppColors.border,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
        ),
        child: Row(
          mainAxisAlignment: .center,
          children: [
            if (isApple)
              const _AppleMark()
            else
              const _GoogleMark(),
            10.w,
            Text(
              isApple ? 'Continue with Apple' : 'Continue with Google',
              style: context.textTheme.labelLarge?.copyWith(
                color: isApple ? AppColors.surface : AppColors.text,
                fontWeight: .w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _SocialKind { google, apple }

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  const _GoogleGPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.18
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromLTWH(
      size.width * 0.12,
      size.height * 0.12,
      size.width * 0.76,
      size.height * 0.76,
    );
    stroke.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.2, 1.7, false, stroke);
    stroke.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 1.5, 1.1, false, stroke);
    stroke.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 2.6, 0.8, false, stroke);
    stroke.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, 3.4, 1.2, false, stroke);
    canvas.drawLine(
      Offset(size.width * 0.52, size.height * 0.5),
      Offset(size.width * 0.88, size.height * 0.5),
      Paint()
        ..color = const Color(0xFF4285F4)
        ..strokeWidth = size.width * 0.16
        ..strokeCap = StrokeCap.butt,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AppleMark extends StatelessWidget {
  const _AppleMark();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 18,
      height: 20,
      child: CustomPaint(painter: _ApplePainter()),
    );
  }
}

class _ApplePainter extends CustomPainter {
  const _ApplePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.surface;
    final body = Path()
      ..moveTo(size.width * 0.50, size.height * 0.22)
      ..cubicTo(
        size.width * 0.22,
        size.height * 0.22,
        size.width * 0.02,
        size.height * 0.46,
        size.width * 0.08,
        size.height * 0.78,
      )
      ..cubicTo(
        size.width * 0.16,
        size.height * 1.04,
        size.width * 0.42,
        size.height * 0.96,
        size.width * 0.50,
        size.height * 0.82,
      )
      ..cubicTo(
        size.width * 0.58,
        size.height * 0.96,
        size.width * 0.84,
        size.height * 1.04,
        size.width * 0.92,
        size.height * 0.78,
      )
      ..cubicTo(
        size.width * 0.98,
        size.height * 0.46,
        size.width * 0.78,
        size.height * 0.22,
        size.width * 0.50,
        size.height * 0.22,
      )
      ..close();
    canvas.drawPath(body, paint);
    final leaf = Path()
      ..moveTo(size.width * 0.52, size.height * 0.20)
      ..cubicTo(
        size.width * 0.58,
        size.height * 0.02,
        size.width * 0.82,
        size.height * 0.00,
        size.width * 0.78,
        size.height * 0.18,
      )
      ..cubicTo(
        size.width * 0.70,
        size.height * 0.24,
        size.width * 0.58,
        size.height * 0.24,
        size.width * 0.52,
        size.height * 0.20,
      );
    canvas.drawPath(leaf, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
