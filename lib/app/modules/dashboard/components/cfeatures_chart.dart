import 'dart:math';

import 'package:airq_ui/app/constants/colors.dart';
import 'package:airq_ui/app/list_shape_ext.dart';
import 'package:airq_ui/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:airq_ui/app/ui_utils.dart';
import 'package:airq_ui/app/widgets/iprojection/ipoint.dart';
import 'package:airq_ui/controllers/dataset_controller.dart';
import 'package:airq_ui/models/pollutant_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class CFeaturesChart extends StatelessWidget {
  final List<List<double>>? values;
  final List<Color>? colors;
  const CFeaturesChart({
    Key? key,
    required this.values,
    required this.colors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return values != null
        ? CustomPaint(
            painter: CFeaturesChartPainter(
              values: values!,
              cores: colors!,
            ),
          )
        : SizedBox();
  }
}

class CFeaturesChartPainter extends CustomPainter {
  final List<List<double>> values;
  final List<Color> cores;
  CFeaturesChartPainter({
    required this.values,
    required this.cores,
  });

  late double _width;
  late double _height;
  late Canvas _canvas;
  late double _horizontalSpace;
  late double _barWidth;
  late double _minValue;
  late double _maxValue;
  late int _nClusters;
  late int _nTime;

  // int get timeLen => models.first.data.values.values.toList().first.length;
  DatasetController datasetController = Get.find();
  DashboardController dashboardController = Get.find();
  PollutantModel get pollutant => datasetController.projectedPollutant;

  @override
  void paint(Canvas canvas, Size size) {
    _canvas = canvas;
    _width = size.width;
    _height = size.height;

    List<double> allValues = List<double>.from(values.flatten());
    _minValue = allValues.reduce(min);
    _maxValue = allValues.reduce(max);

    _nClusters = values.length;
    _nTime = values.first.length;

    _horizontalSpace = 0;
    // _barWidth = (_width - (_horizontalSpace * (_nClusters - 1))) / _nTime;
    _barWidth = (_width - (_horizontalSpace * (_nClusters - 1))) /
        (_nTime * _nClusters);

    double leftOffset = 0;
    for (var i = 0; i < _nTime; i++) {
      for (var j = 0; j < _nClusters; j++) {
        Paint paint = Paint()
          ..color = cores[j]
          ..style = PaintingStyle.fill;

        Offset begin = Offset(leftOffset, value2Heigh(0));
        Offset end = Offset(leftOffset + _barWidth, value2Heigh(values[j][i]));

        _canvas.drawRect(
          Rect.fromPoints(begin, end),
          paint,
        );

        leftOffset = leftOffset + _barWidth;
      }
      leftOffset + _horizontalSpace;
      Paint paint = Paint()
        ..color = Colors.black.withOpacity(0.5)
        ..style = PaintingStyle.fill;
      // _canvas.drawLine(
      //     Offset(leftOffset, 0), Offset(leftOffset, _height), paint);
    }
    // for (var i = 0; i < models.length; i++) {
    //   if (models[i].selected) {
    //     paintModelLine(models[i]);
    //   }
    // }
  }

  double value2Heigh(double value) {
    return _height - uiRangeConverter(value, _minValue, _maxValue, 0, _height);
    // return _height - (value / visSettings.datasetSettings.maxValue * _height);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
