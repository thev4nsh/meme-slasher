import 'package:flutter/material.dart';

class SwipeTrail extends StatelessWidget {
  final List<Offset> points;

  const SwipeTrail({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
   return SizedBox.expand(
  child: CustomPaint(
    painter: _SwipePainter(points),
  ),
);
  }
}

class _SwipePainter extends CustomPainter {
  final List<Offset> points;

  _SwipePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];

      final progress = i / points.length;

      // 🔥 GLOW LAYER
      final glowPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            Colors.redAccent.withOpacity(0.4),
            Colors.orangeAccent.withOpacity(0.6),
            Colors.transparent,
          ],
        ).createShader(Rect.fromPoints(p1, p2))
        ..strokeWidth = 14 * (1 - progress)
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(p1, p2, glowPaint);

      // ⚡ CORE LINE
      final corePaint = Paint()
        ..shader = const LinearGradient(
          colors: [
            Colors.white,
            Colors.yellowAccent,
            Colors.orangeAccent,
          ],
        ).createShader(Rect.fromPoints(p1, p2))
        ..strokeWidth = 4 * (1 - progress)
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(p1, p2, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SwipePainter oldDelegate) => true;
}