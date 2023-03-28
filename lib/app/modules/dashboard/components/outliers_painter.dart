import 'package:airq_ui/app/ui_utils.dart';
import 'package:airq_ui/app/widgets/iprojection/ipoint.dart';
import 'package:airq_ui/app/widgets/iprojection/iprojection_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

class OutliersPainter extends CustomPainter {
  final List<dynamic> coords;
  final List<Color> fillColors;
  final List<Color> borderColors;
  final List<double> radius;
  final List<IPoint> ipoints;
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  OutliersPainter({
    required this.coords,
    required this.fillColors,
    required this.borderColors,
    required this.radius,
    required this.minY,
    required this.maxY,
    required this.minX,
    required this.maxX,
    required this.ipoints,
  });

  late Canvas _canvas;
  late double _width;
  late double _height;
  late int _n;
  @override
  void paint(Canvas canvas, Size size) {
    // print("painting");
    _canvas = canvas;
    _height = size.height;
    _width = size.width;
    _n = fillColors.length;

    for (int i = 0; i < _n; i++) {
      if (!ipoints[i].selected) {
        Paint borderPaint = Paint()
          ..color = borderColors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.1;
        Paint fillPaint = Paint()
          ..color = fillColors[i]
          ..style = PaintingStyle.fill;

        Offset coordinates = computeCanvasCoordinates(
          coords[1][i],
          coords[0][i],
          _width,
          _height,
        );

        _canvas.drawCircle(
          coordinates,
          radius[i],
          fillPaint,
        );
        _canvas.drawCircle(
          coordinates,
          radius[i],
          borderPaint,
        );
      }
    }

    for (int i = 0; i < _n; i++) {
      if (ipoints[i].selected) {
        Paint borderPaint = Paint()
          ..color = borderColors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.1;
        Paint fillPaint = Paint()
          ..color = fillColors[i]
          ..style = PaintingStyle.fill;

        Offset coordinates = computeCanvasCoordinates(
          coords[1][i],
          coords[0][i],
          _width,
          _height,
        );

        _canvas.drawCircle(
          coordinates,
          radius[i],
          fillPaint,
        );
        _canvas.drawCircle(
          coordinates,
          radius[i],
          borderPaint,
        );
      }
    }
  }

  Offset computeCanvasCoordinates(
      double dx, double dy, double width, double height) {
    final double x = uiRangeConverter(dx, minX, maxX, 0, width);
    final double y = height - uiRangeConverter(dy, minY, maxY, 0, height);
    return Offset(x, y);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
    // return controller.shouldRepaint;
  }
}
