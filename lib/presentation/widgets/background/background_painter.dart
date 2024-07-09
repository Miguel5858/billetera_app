import 'package:flutter/material.dart';

class BackgroundPainter extends CustomPainter {
  final Paint wavePaint;
  final Paint wavePaint2;
  final Paint circlePaint;
  final List<Offset> circleOffsets;
  final List<double> circleRadii;

  BackgroundPainter()
      : wavePaint = Paint()
          ..color = Colors.green.withOpacity(0.3)
          ..style = PaintingStyle.fill,
        wavePaint2 = Paint()
          ..color = Colors.green.withOpacity(0.8)
          ..style = PaintingStyle.fill,
        circlePaint = Paint()
          ..color = Colors.green.withOpacity(0.2)
          ..style = PaintingStyle.fill,
        circleOffsets = [
          Offset(200, 300),
          Offset(400, 700),
          Offset(600, 500),
          Offset(800, 400),
          Offset(1000, 600),
          Offset(1200, 300),
          Offset(300, 600),
          Offset(500, 400),
          Offset(700, 800),
          Offset(900, 500),
          Offset(1100, 300),
          Offset(1300, 600),
          Offset(250, 400),
          Offset(450, 800),
          Offset(650, 300),
          Offset(850, 600),
          Offset(1050, 400),
          Offset(100, 700),
        ],
        circleRadii = [
          40,
          25,
          35,
          20,
          40,
          30,
          35,
          28,
          22,
          37,
          18,
          32,
          27,
          38,
          21,
          33,
          29,
          36,
        ];

  @override
  void paint(Canvas canvas, Size size) {
    // Dibujar ondas superiores
    final path = Path();
    path.moveTo(0, size.height * 0.3);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.35,
        size.width * 0.5, size.height * 0.3);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.25, size.width, size.height * 0.3);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();
    canvas.drawPath(path, wavePaint);

    // Dibujar ondas inferiores más pequeñas
    final path2 = Path();
    path2.moveTo(0, size.height * 0.85);
    path2.quadraticBezierTo(size.width * 0.25, size.height * 0.9,
        size.width * 0.5, size.height * 0.85);
    path2.quadraticBezierTo(
        size.width * 0.75, size.height * 0.8, size.width, size.height * 0.85);
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, wavePaint2);

    // Dibujar curvas
    final curvePath = Path();
    curvePath.moveTo(size.width, size.height);
    curvePath.quadraticBezierTo(
        size.width * 0.75, size.height * 0.75, size.width * 0.5, size.height);
    curvePath.quadraticBezierTo(
        size.width * 0.25, size.height * 1.25, 0, size.height);
    curvePath.lineTo(0, size.height);
    curvePath.close();
    canvas.drawPath(curvePath, wavePaint2);

    // Dibujar figuras abstractas usando posiciones y tamaños fijos
    for (int i = 0; i < circleOffsets.length; i++) {
      canvas.drawCircle(circleOffsets[i], circleRadii[i], circlePaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: CustomPaint(
        size: Size(double.infinity, double.infinity),
        painter: BackgroundPainter(),
      ),
    ),
  ));
}
