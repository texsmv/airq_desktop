import 'dart:math';

import 'package:airq_ui/app/constants/colors.dart';
import 'package:airq_ui/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:airq_ui/app/ui_utils.dart';
import 'package:airq_ui/app/widgets/iprojection/ipoint.dart';
import 'package:airq_ui/controllers/dataset_controller.dart';
import 'package:airq_ui/models/pollutant_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MultiChartPainter extends CustomPainter {
  final double minValue;
  final double maxValue;
  final List<IPoint> models;
  MultiChartPainter({
    required this.models,
    required this.minValue,
    required this.maxValue,
  });

  late double _width;
  late double _height;
  late double _horizontalSpace;
  late Canvas _canvas;
  Color normalColor = Color.fromRGBO(190, 190, 190, 1);
  int get timeLen => models.first.data.values.values.toList().first.length;
  DatasetController datasetController = Get.find();
  DashboardController dashboardController = Get.find();
  PollutantModel get pollutant => datasetController.projectedPollutant;

  @override
  void paint(Canvas canvas, Size size) {
    _canvas = canvas;
    _width = size.width;
    _height = size.height;
    _horizontalSpace = _width / (timeLen - 1);

    for (var i = 0; i < models.length; i++) {
      if (!models[i].selected) {
        paintModelLine(models[i]);
      }
    }
    for (var i = 0; i < models.length; i++) {
      if (models[i].selected) {
        paintModelLine(models[i]);
      }
    }
  }

  void paintModelLine(IPoint model) {
    Path path = Path();

    List<double> values;
    if (dashboardController.showShape) {
      values = model.data.smoothedValues[pollutant.id]!;
    } else {
      values = model.data.smoothedValues[pollutant.id]!;
    }

    double value = min(values[0], maxValue);
    path.moveTo(0, value2Heigh(value));
    for (var i = 1; i < values.length; i++) {
      // print(model.values[pollutant.id]![i]);
      double value = min(values[i], maxValue);
      value = max(value, minValue);
      path.lineTo(
        i * _horizontalSpace,
        value2Heigh(value),
      );
    }

    late Paint paint;

    if (model.cluster != null) {
      bool isHighlighted;
      if (datasetController.selectedWindow != null &&
          model.data.id == datasetController.selectedWindow!.id) {
        isHighlighted = true;
      } else {
        isHighlighted = false;
      }
      if (dashboardController.selectedPoints.isNotEmpty) {
        if (model.selected) {
          paint = Paint()
            ..color = uiClusterColor(model.cluster!)
                .withOpacity(isHighlighted ? 1 : 0.6)
            ..style = PaintingStyle.stroke
            ..strokeWidth = isHighlighted ? 3.5 : 1.5;
        } else {
          paint = Paint()
            ..color = normalColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = isHighlighted ? 3.5 : 1.5;
        }
      } else {
        paint = Paint()
          ..color = uiClusterColor(model.cluster!)
              .withOpacity(isHighlighted ? 1 : 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isHighlighted ? 3.5 : 1.5;
      }
    } else {
      bool isHighlighted;
      if (datasetController.selectedWindow != null &&
          model.data.id == datasetController.selectedWindow!.id) {
        isHighlighted = true;
      } else {
        isHighlighted = false;
      }
      if (model.selected) {
        paint = Paint()
          ..color = pColorPrimary
          ..style = PaintingStyle.stroke
          ..strokeWidth = isHighlighted ? 3.5 : 1.5;
      } else {
        paint = Paint()
          ..color = normalColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = isHighlighted ? 3.5 : 1.5;
      }
    }

    _canvas.drawPath(
      path,
      paint,
    );
  }

  double value2Heigh(double value) {
    return _height - uiRangeConverter(value, minValue, maxValue, 0, _height);
    // return _height - (value / visSettings.datasetSettings.maxValue * _height);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
