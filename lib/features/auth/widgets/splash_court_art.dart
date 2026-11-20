import 'package:material_ui/material_ui.dart';

import '../../../core/consts/app_colors.dart';
import '../model/splash_court_layout.dart';

class SplashCourtArt extends StatelessWidget {
  const SplashCourtArt({super.key, required this.layout});

  final SplashCourtLayout layout;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SplashCourtPainter(layout),
      size: Size.infinite,
    );
  }
}

class SplashCourtPainter extends CustomPainter {
  const SplashCourtPainter(this.layout);

  final SplashCourtLayout layout;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent.withValues(alpha: layout.lineOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final center = Offset(size.width / 2, size.height * layout.centerYFactor);
    canvas.drawCircle(center, layout.outerRadius, paint);
    canvas.drawCircle(center, layout.innerRadius, paint);
    final fillRadius = layout.fillRadius;
    if (fillRadius != null) {
      canvas.drawCircle(
        center,
        fillRadius,
        Paint()..color = AppColors.accent.withValues(alpha: 0.1),
      );
    }
    canvas.drawLine(
      Offset(-20, center.dy),
      Offset(size.width + 20, center.dy),
      paint,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - 220),
        width: layout.boxWidth,
        height: layout.topBoxHeight,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + 210),
        width: layout.boxWidth,
        height: layout.bottomBoxHeight,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant SplashCourtPainter oldDelegate) {
    return oldDelegate.layout != layout;
  }
}
