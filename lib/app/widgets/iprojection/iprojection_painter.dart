import 'package:airq_ui/app/constants/colors.dart';
import 'package:airq_ui/app/ui_utils.dart';
import 'package:airq_ui/app/widgets/iprojection/ipoint.dart';
import 'package:airq_ui/app/widgets/iprojection/iprojection_controller.dart';
import 'package:airq_ui/controllers/dataset_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

class IProjectionPainter extends CustomPainter {
  late IProjectionController controller;
  IProjectionPainter({required this.isLocal}) {
    controller = Get.find(tag: isLocal ? 'local' : 'global');
  }
  final bool isLocal;

  late Canvas _canvas;
  late double _width;
  late double _height;

  DatasetController get datasetController => Get.find();

  Paint nodePaint = Paint()
    ..color = Color.fromRGBO(120, 120, 120, 1)
    ..style = PaintingStyle.fill;
  Paint normalFillPaint = Paint()
    ..color = Color.fromRGBO(190, 190, 190, 1)
    ..style = PaintingStyle.fill;
  Paint normalBorderPaint = Paint()
    ..color = Color.fromRGBO(170, 170, 170, 1)
    ..style = PaintingStyle.stroke;
  Paint selectedBorderPaint = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.stroke;
  Paint highlightedBorderPaint = Paint()
    ..color = pColorPrimary
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  @override
  void paint(Canvas canvas, Size size) {
    // print("painting");
    _canvas = canvas;
    _height = size.height;
    _width = size.width;
    for (int i = 0; i < controller.points.length; i++) {
      if (!controller.points[i].selected) {
        plotPoint(controller.points[i], i);
      }
    }
    for (int i = 0; i < controller.points.length; i++) {
      if (controller.points[i].selected) {
        plotPoint(controller.points[i], i);
      }
    }
  }

  void plotPoint(IPoint point, int position) {
    late Paint fillPaint;
    Paint borderPaint;
    if (point.cluster != null) {
      fillPaint = Paint()
        ..color = uiClusterColor(point.cluster!).withOpacity(0.4)
        ..style = PaintingStyle.fill;
    } else {
      fillPaint = normalFillPaint;
    }
    borderPaint = normalBorderPaint;
    if (point.selected) {
      borderPaint = selectedBorderPaint;
    }
    bool isHighlighted;
    if (datasetController.selectedWindow != null &&
        point.data.id == datasetController.selectedWindow!.id) {
      isHighlighted = true;
    } else {
      isHighlighted = false;
    }

    // if (point.canvasCoordinates == null) {
    //   point.computeCanvasCoordinates(_width, _height);
    // }
    Offset canvasCoordinates = computeCanvasCoordinates(
        controller.currentCoordinates[position].dx,
        controller.currentCoordinates[position].dy,
        _width,
        _height);
    if (isLocal) {
      point.canvasLocalCoordinates = canvasCoordinates;
      // print(point.canvasLocalCoordinates);
    } else {
      point.canvasCoordinates = canvasCoordinates;
    }

    double radius = 4;
    if (point.selected) {
      radius = 8;
    }
    if (point.isHighlighted) {
      radius = 12;
    }

    if (isHighlighted) {
      borderPaint = highlightedBorderPaint;
      radius = 10;
    }

    drawMark(isLocal ? point.canvasLocalCoordinates : point.canvasCoordinates,
        radius, fillPaint, point.isOutlier);
    if (point.selected || isHighlighted) {
      // drawMark(isLocal ? point.canvasLocalCoordinates : point.canvasCoordinates,
      //     radius, point.isOutlier ? fillPaint : borderPaint, point.isOutlier);
      drawMark(isLocal ? point.canvasLocalCoordinates : point.canvasCoordinates,
          radius, borderPaint, point.isOutlier,
          isize: 6);
    }
  }

  void drawMark(Offset offset, double radius, Paint paint, bool isOutlier,
      {double isize = 8}) {
    if (isOutlier) {
      // double isize = 8;
      _canvas.drawLine(offset, offset + Offset(isize, isize),
          paint..strokeWidth = radius / 3);
      _canvas.drawLine(offset + Offset(isize, 0), offset + Offset(0, isize),
          paint..strokeWidth = radius / 3);
    } else {
      _canvas.drawCircle(
        offset,
        radius,
        paint,
      );
    }
  }

  Offset computeCanvasCoordinates(
      double dx, double dy, double width, double height) {
    final double x =
        uiRangeConverter(dx, controller.minX, controller.maxX, 0, width);
    final double y = height -
        uiRangeConverter(dy, controller.minY, controller.maxY, 0, height);
    return Offset(x, y);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
    return controller.shouldRepaint;
  }
}
