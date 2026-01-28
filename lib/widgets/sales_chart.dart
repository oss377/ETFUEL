import 'package:flutter/material.dart';

class SalesChart extends StatelessWidget {
  const SalesChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: CustomPaint(
        painter: _ChartPainter(),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0df259)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0df259).withOpacity(0.3),
          const Color(0xFF0df259).withOpacity(0),
        ],
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.8)
      ..cubicTo(
        size.width * 0.05, size.height * 0.8,
        size.width * 0.1, size.height * 0.27,
        size.width * 0.15, size.height * 0.27,
      )
      ..cubicTo(
        size.width * 0.2, size.height * 0.27,
        size.width * 0.25, size.height * 0.6,
        size.width * 0.3, size.height * 0.6,
      )
      ..cubicTo(
        size.width * 0.35, size.height * 0.6,
        size.width * 0.4, size.height * 0.13,
        size.width * 0.45, size.height * 0.13,
      )
      ..cubicTo(
        size.width * 0.5, size.height * 0.13,
        size.width * 0.55, size.height * 0.67,
        size.width * 0.6, size.height * 0.67,
      )
      ..cubicTo(
        size.width * 0.65, size.height * 0.67,
        size.width * 0.7, size.height * 0.07,
        size.width * 0.75, size.height * 0.07,
      )
      ..cubicTo(
        size.width * 0.8, size.height * 0.07,
        size.width * 0.85, size.height * 0.87,
        size.width * 0.9, size.height * 0.87,
      )
      ..cubicTo(
        size.width * 0.95, size.height * 0.87,
        size.width, size.height * 0.4,
        size.width, size.height * 0.4,
      );

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}