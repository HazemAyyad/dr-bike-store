import 'package:flutter/material.dart';

class TrianglePainter extends CustomPainter {
  final bool isActive;

  TrianglePainter({required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(size.width, size.height / 2); // Right point (vertex)
    path.lineTo(0, 0); // Top left
    path.lineTo(0, size.height); // Bottom left
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
