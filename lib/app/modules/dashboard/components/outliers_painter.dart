import 'dart:math';

import 'package:airq_ui/app/list_shape_ext.dart';
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
  final bool saveCanvasCoords;
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
    required this.saveCanvasCoords,
  });

  // double get minX => List<double>.from(coords[1]).reduce(min);
  // double get maxX => List<double>.from(coords[1]).reduce(max);
  // double get minY => List<double>.from(coords[0]).reduce(min);
  // double get maxY => List<double>.from(coords[0]).reduce(max);

  late Canvas _canvas;
  late double _width;
  late double _height;
  late int _n;
  @override
  void paint(Canvas canvas, Size size) {
    _canvas = canvas;
    _height = size.height;
    _width = size.width;
    _n = fillColors.length;
    // print("painting");
    // print(uiRangeConverter(minX, minX, maxX, 0, _width));

    // for (int i = 0; i < _n; i++) {
    // print(coords.shape);
    // print(_n);
    // print('min x');
    // print(minX);
    // print('Coords');
    for (int i = 0; i < _n; i++) {
      if (!ipoints[i].selected) {
        // if (coords[1][i] < minX) {
        //   print('Khe');
        // }
        // print(coords[1][i]);
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

        // if (saveCanvasCoords) {
        ipoints[i].canvasCoordinates = coordinates;
        // }

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
