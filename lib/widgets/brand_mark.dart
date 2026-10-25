import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class BrandMark extends StatelessWidget {
  final double size;
  final Color background;
  final Color foreground;
  final Color accent;

  const BrandMark({
    super.key,
    this.size = 44,
    this.background = AppColors.emerald,
    this.foreground = Colors.white,
    this.accent = AppColors.gold,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _BrandMarkPainter(
            background: background,
            foreground: foreground,
            accent: accent,
          ),
        ),
      ),
    );
  }
}

class _BrandMarkPainter extends CustomPainter {
  final Color background;
  final Color foreground;
  final Color accent;

  const _BrandMarkPainter({
    required this.background,
    required this.foreground,
    required this.accent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.shortestSide;
    final center = Offset(size.width * 0.46, size.height * 0.54);
    final radius = unit * 0.29;
    final moonPaint = Paint()..color = foreground;
    final cutoutPaint = Paint()..color = background;

    canvas.drawCircle(center, radius, moonPaint);
    canvas.drawCircle(
      Offset(center.dx + radius * 0.48, center.dy - radius * 0.37),
      radius * 0.88,
      cutoutPaint,
    );

    final starCenter = Offset(size.width * 0.72, size.height * 0.31);
    final starPath = Path();
    for (var point = 0; point < 10; point++) {
      final angle = -1.5708 + point * 3.14159 / 5;
      final pointRadius = point.isEven ? unit * 0.115 : unit * 0.048;
      final position = Offset(
        starCenter.dx + pointRadius * math.cos(angle),
        starCenter.dy + pointRadius * math.sin(angle),
      );
      if (point == 0) {
        starPath.moveTo(position.dx, position.dy);
      } else {
        starPath.lineTo(position.dx, position.dy);
      }
    }
    starPath.close();
    canvas.drawPath(starPath, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(covariant _BrandMarkPainter oldDelegate) =>
      background != oldDelegate.background ||
      foreground != oldDelegate.foreground ||
      accent != oldDelegate.accent;
}
