import 'package:flutter/material.dart';

import '../consts/app_colors.dart';

class PitchsideMark extends StatelessWidget {
  const PitchsideMark({
    super.key,
    required this.size,
    this.radius,
    this.backgroundColor = AppColors.accent,
    this.foregroundColor = AppColors.primary,
    this.shadows = const [],
  });

  final double size;
  final double? radius;
  final Color backgroundColor;
  final Color foregroundColor;
  final List<BoxShadow> shadows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius ?? size * 28 / 96),
        boxShadow: shadows,
      ),
      child: CustomPaint(painter: _PitchsideBallPainter(foregroundColor)),
    );
  }
}

class _PitchsideBallPainter extends CustomPainter {
  const _PitchsideBallPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = size.width * 0.2;
    final scale = (size.width - inset * 2) / 24;
    Offset point(double x, double y) =>
        Offset(inset + x * scale, inset + y * scale);

    final paint = Paint()
      ..color = color
      ..style = .stroke
      ..strokeWidth = 1.8 * scale
      ..strokeCap = .round
      ..strokeJoin = .round;

    final center = point(12, 12);
    final radius = 9 * scale;
    canvas.drawCircle(center, radius, paint);
    final pentagon = Path()
      ..addPolygon([
        point(12, 8),
        point(15.5, 10.5),
        point(14.2, 14.5),
        point(9.8, 14.5),
        point(8.5, 10.5),
      ], true);
    canvas.drawPath(pentagon, paint);
    final seams = <(Offset, Offset)>[
      (point(12, 8), point(12, 3.2)),
      (point(15.5, 10.5), point(20, 9)),
      (point(14.2, 14.5), point(17, 18.3)),
      (point(9.8, 14.5), point(7, 18.3)),
      (point(8.5, 10.5), point(4, 9)),
    ];
    for (final seam in seams) {
      canvas.drawLine(seam.$1, seam.$2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PitchsideBallPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
