import 'package:flutter/cupertino.dart';

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double width = size.width;
    double height = size.height;
    double centerHeight = height / 2;

    Path path = Path();
    path.moveTo(width * 0.25, 0); // Top-left
    path.lineTo(width * 0.75, 0); // Top-right
    path.lineTo(width, centerHeight); // Middle-right
    path.lineTo(width * 0.75, height); // Bottom-right
    path.lineTo(width * 0.25, height); // Bottom-left
    path.lineTo(0, centerHeight); // Middle-left
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class HexagonBorderPainter extends CustomPainter {
  final Color fillColor;   // eklendi
  final Color borderColor;
  final double strokeWidth;

  HexagonBorderPainter({
    required this.fillColor,   // eklendi
    required this.borderColor,
    this.strokeWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Altıgen path oluştur
    final double width = size.width;
    final double height = size.height;
    final double centerHeight = height / 2;

    Path path = Path()
      ..moveTo(width * 0.25, 0)       // Top-left
      ..lineTo(width * 0.75, 0)       // Top-right
      ..lineTo(width, centerHeight)   // Right-center
      ..lineTo(width * 0.75, height)  // Bottom-right
      ..lineTo(width * 0.25, height)  // Bottom-left
      ..lineTo(0, centerHeight)       // Left-center
      ..close();

    // 1) Önce dolguyu boya
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // 2) Sonra dış çizgiyi (stroke) boya
    final strokePaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant HexagonBorderPainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}