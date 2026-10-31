import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';

class CourtHeroCanvas extends StatelessWidget {
  const CourtHeroCanvas({
    super.key,
    required this.color,
    this.height = 210,
    this.borderRadius,
    this.showGradient = true,
  });

  final Color color;
  final double height;
  final BorderRadius? borderRadius;
  final bool showGradient;

  @override
  Widget build(BuildContext context) {
    final child = SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: .expand,
        children: [
          ColoredBox(color: color),
          CustomPaint(painter: CourtLinesPainter(color)),
          if (showGradient)
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: .topCenter,
                  end: .bottomCenter,
                  colors: [Color(0x800D1B14), Color(0x000D1B14)],
                  stops: [0, 0.45],
                ),
              ),
            ),
        ],
      ),
    );
    if (borderRadius == null) {
      return child;
    }
    return ClipRRect(borderRadius: borderRadius!, child: child);
  }
}

class CourtLinesPainter extends CustomPainter {
  const CourtLinesPainter(this.base);

  final Color base;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.surface.withValues(alpha: 0.16)
      ..style = .stroke
      ..strokeWidth = 2;
    final inset = size.shortestSide * 0.12;
    final rect = Rect.fromLTWH(
      inset,
      inset * 0.8,
      size.width - inset * 2,
      size.height - inset * 1.6,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      paint,
    );
    canvas.drawLine(
      Offset(size.width / 2, rect.top),
      Offset(size.width / 2, rect.bottom),
      paint,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.shortestSide * 0.12,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CourtLinesPainter oldDelegate) =>
      oldDelegate.base != base;
}
